
local bit = require 'bit'
local ffi = require 'ffi'
local mswin = require 'exports.mswindows'
local winstr = require 'exports.mswindows.strings'
local winfiles = require 'exports.mswindows.filesystem'
local winhandles = require 'exports.mswindows.handles'
local on_wait_object_signal = require 'radish.mswindows.on_wait_object_signal'
local on_update = require 'radish.mswindows.on_update'
local sqlite3 = require 'exports.sqlite3'; require 'exports.sqlite3.methods'

local filewatching = {}

local function sweep_aux(path)
	local search = winfiles.dir( path )
	if search == nil or winhandles.is_invalid( search.handle ) then
		return 'invalid'
	end
	coroutine.yield('start', path)
	repeat
		local type, name = search:peek()
		if type == 'file' then
			local size = search:get_size()
			local last_modified = search:get_when_last_modified()
			if coroutine.yield('file', path, name, size, last_modified) == 'stop' then
				search:destroy()
				return 'stop'
			end
		elseif type == 'folder' and name ~= '.' and name ~= '..' then
			if sweep_aux(path .. '/' .. name) == 'stop' then
				search:destroy()
				return 'stop'
			end
		end
	until search:move_next() == false
	coroutine.yield('end', path)
end

local function sweep_stepper_coroproc(path)
	coroutine.yield()
	while true do
		local result = sweep_aux(path)
		if result == 'invalid' then
			error('invalid path: ' .. path)
		elseif result == 'stop' then
			break
		end
	end
end

function filewatching.make_sweep_stepper(path)
	local x = coroutine.wrap(sweep_stepper_coroproc)
	x(path)
	return x
end

function filewatching.stop_sweep_stepper(stepper)
	stepper('stop')
end

local function full_sweep_coroproc(path)
	coroutine.yield()
	local result = sweep_aux(path)
	if result == 'invalid' then
		error('invalid path: ' .. path)
	end
end

function filewatching.full_sweep(path)
	local x = coroutine.wrap(full_sweep_coroproc)
	x(path)
	return x
end

-- TODO: cancel sweep-scanner on notify and until a fixed time period (100ms?)
--   has elapsed since last change notification, do a full sweep and
--   restart the sweep-scanner
local function add_change_notifier(path, recursively, callback)
	local universe_folder_change_notifier = mswin.FindFirstChangeNotificationW(
		winstr.wide(path),
		recursively,
		bit.bor(
			mswin.FILE_NOTIFY_CHANGE_FILE_NAME,
			mswin.FILE_NOTIFY_CHANGE_DIR_NAME,
			mswin.FILE_NOTIFY_CHANGE_SIZE,
			mswin.FILE_NOTIFY_CHANGE_LAST_WRITE))
	if universe_folder_change_notifier == nil
	or winhandles.is_invalid(universe_folder_change_notifier) then
		return false
	end
	on_wait_object_signal:add(universe_folder_change_notifier, function(handle)
		if callback() == 'stop' then
			return 'remove'
		end
		if mswin.FindNextChangeNotification(handle) == false then
			add_change_notifier(path, recursively, callback)
			return 'remove'
		end
	end)
	return true
end

function filewatching.watch(path, recursively, callback)
	return add_change_notifier(path, recursively, callback)
end

function filewatching.on_new(path)
end

function filewatching.on_modified(path)
end

function filewatching.on_deleted(path)
end

function filewatching.begin(path)
	assert( winfiles.ensure_folder('undo_history'), 'unable to create undo_history folder' )
	local db do
		local out_db = ffi.new 'sqlite3*[1]'
		local create_result = sqlite3.sqlite3_open('undo_history/changes.db', out_db)
		assert(create_result == sqlite3.SQLITE_OK, 'unable to create changes.db')
		db = out_db[0]
		--ffi.gc(db, sqlite3.sqlite3_close_v2)
	end

	local function exec(sql)
		assert(db:exec(sql, nil, nil, nil) == sqlite3.SQLITE_OK, 'failed to setup changes.db')
	end

	exec [[

		CREATE TABLE IF NOT EXISTS path_change (
			id INTEGER PRIMARY KEY AUTOINCREMENT,
			folder TEXT,
			filename TEXT,
			mode TEXT CHECK( mode IN ('new', 'mod', 'del') ),
			recorded_at TEXT,
			last_modified TEXT,
			size INTEGER
		);

		CREATE INDEX IF NOT EXISTS path_change_by_path ON path_change(folder, filename);

		CREATE VIEW IF NOT EXISTS path_current
		AS
		SELECT id, folder, filename, mode, recorded_at, last_modified, size
		FROM path_change pc1
		WHERE mode IN ('new', 'mod') AND NOT EXISTS (
			SELECT 1 FROM path_change pc2
			WHERE pc2.id > pc1.id
				AND pc2.folder = pc1.folder
				AND pc2.filename = pc1.filename);

		CREATE TABLE IF NOT EXISTS temp.path_current (
			folder TEXT,
			filename TEXT,
			recorded_at TEXT,
			last_modified TEXT,
			size INTEGER
		);

	]]

	local out_stmt = ffi.new 'sqlite3_stmt*[1]'
	local function stmt(sql)
		local prepare_result = db:prepare_v2(sql, #sql + 1, out_stmt, nil)
		assert(prepare_result == sqlite3.SQLITE_OK, 'unable to prepare statement')
		local stmt = out_stmt[0]
		--ffi.gc(stmt, sqlite3.sqlite3_finalize)
		return stmt
	end
	local function textcol(stmt, i)
		local v = stmt:column_text(i)
		if v == nil then
			return nil
		end
		return ffi.string(v, stmt:column_bytes(i))
	end
	local function bindtext(stmt, i, str)
		if str == nil then
			return stmt:bind_null(i)
		else
			return stmt:bind_text(i, str, #str, nil)
		end
	end
	-- args: folder, filename, last_modified, size
	local insert_stmt = stmt [[

		INSERT INTO temp.path_current (folder, filename, recorded_at, last_modified, size)
		VALUES (?, ?, strftime('%Y-%m-%dT%H:%M:%SZ', 'now', 'utc'), ?, ?)

	]]
	-- args: folder, filename, mode, recorded_at, last_modified, size
	--  when mode is 'del', last_modified & size are NULL
	local record_change_stmt = stmt [[

		INSERT INTO main.path_change (folder, filename, mode, recorded_at, last_modified, size)
		VALUES (?, ?, ?, ?, ?, ?)

	]]
	-- args: folder (NULL for all)
	local clear_stmt = stmt [[

		DELETE FROM temp.path_current
		WHERE (?1 IS NULL) OR (folder = ?1)

	]]
	-- args: folder (NULL for all)
	local each_new_change_stmt = stmt [[

		SELECT
			mpc.folder,
			mpc.filename,
			'del' AS mode,
			strftime('%Y-%m-%dT%H:%M:%SZ', 'now', 'utc') AS recorded_at,
			NULL AS last_modified,
			NULL AS size
		FROM main.path_current mpc
		WHERE ((?1 IS NULL) OR (mpc.folder = ?1)) AND NOT EXISTS (
			SELECT 1 FROM temp.path_current tpc
			WHERE (tpc.folder = mpc.folder) AND (tpc.filename = mpc.filename))

		UNION ALL

		SELECT
			tpc.folder,
			tpc.filename,
			'new' AS mode,
			tpc.recorded_at,
			tpc.last_modified,
			tpc.size
		FROM temp.path_current tpc
		WHERE ((?1 IS NULL) OR (tpc.folder = ?1)) AND NOT EXISTS (
			SELECT 1 FROM main.path_current mpc
			WHERE (mpc.folder = tpc.folder) AND (mpc.filename = tpc.filename))

		UNION ALL

		SELECT
			tpc.folder,
			tpc.filename,
			'mod' AS mode,
			tpc.recorded_at,
			tpc.last_modified,
			tpc.size
		FROM temp.path_current tpc
		INNER JOIN main.path_current mpc
			ON (tpc.folder = mpc.folder) AND (mpc.filename = tpc.filename)
		WHERE (tpc.size != mpc.size) OR (tpc.last_modified != mpc.last_modified)

	]]
	local sweep_step, sweep_update
	local function do_sweep()
		if sweep_step ~= nil then
			filewatching.stop_sweep_stepper(sweep_step)
			sweep_step = nil
		end
		if sweep_update ~= nil then
			on_update.kill(sweep_update)
			sweep_update = nil
		end
		local count = 0

		exec [[ BEGIN TRANSACTION ]]

		assert( sqlite3.SQLITE_OK == clear_stmt:bind_null(1) )
		assert( sqlite3.SQLITE_DONE == clear_stmt:step() )
		assert( sqlite3.SQLITE_OK == clear_stmt:reset() )

		collectgarbage()

		for mode, folder, filename, size, last_modified in filewatching.full_sweep('universe') do
			count = count + 1
			if mode == 'file' then
				assert( sqlite3.SQLITE_OK == bindtext(insert_stmt, 1, folder) )
				assert( sqlite3.SQLITE_OK == bindtext(insert_stmt, 2, filename) )
				assert( sqlite3.SQLITE_OK == bindtext(insert_stmt, 3, last_modified) )
				assert( sqlite3.SQLITE_OK == insert_stmt:bind_int64(4, size) )
				assert( sqlite3.SQLITE_DONE == insert_stmt:step() )
				assert( sqlite3.SQLITE_OK == insert_stmt:reset() )
			end
		end

		local function flush_changes(folder)
			if folder == nil then
				assert( sqlite3.SQLITE_OK == each_new_change_stmt:bind_null(1) )
			else
				assert( sqlite3.SQLITE_OK == each_new_change_stmt:bind_text(1, folder, #folder, nil) )
			end
			while true do
				local step_result = each_new_change_stmt:step()
				if step_result == sqlite3.SQLITE_DONE then
					break
				elseif step_result ~= sqlite3.SQLITE_ROW then
					error('error fetching each_new_change_stmt row')
				end
				for i = 1, 6 do
					assert( sqlite3.SQLITE_OK == record_change_stmt:bind_value(
						i, each_new_change_stmt:column_value(i - 1)) )
				end
				assert( sqlite3.SQLITE_DONE == record_change_stmt:step() )
				assert( sqlite3.SQLITE_OK == record_change_stmt:reset() )
				local folder = textcol(each_new_change_stmt, 0)
				local filename = textcol(each_new_change_stmt, 1)
				local mode = textcol(each_new_change_stmt, 2)
				if mode == 'mod' then
					filewatching.on_modified(folder..'/'..filename)
				elseif mode == 'new' then
					filewatching.on_new(folder..'/'..filename)
				elseif mode == 'del' then
					filewatching.on_deleted(folder..'/'..filename)
				end
			end
			assert( sqlite3.SQLITE_OK == each_new_change_stmt:reset() )

			if folder == nil then
				assert( sqlite3.SQLITE_OK == clear_stmt:bind_null(1) )
			else
				assert( sqlite3.SQLITE_OK == clear_stmt:bind_text(1, folder, #folder, nil) )
			end
			assert( sqlite3.SQLITE_DONE == clear_stmt:step() )
			assert( sqlite3.SQLITE_OK == clear_stmt:reset() )
		end

		flush_changes(nil)

		exec [[ COMMIT TRANSACTION ]]

		-- update 5 times a second
		local step_hz = 5
		local step_ms = 1000 / step_hz
		-- aim to cover all in about 5 seconds, to a maximum of 500/second
		local step_count = math.max(1, math.min(100, math.floor(count / (step_hz * 5))))

		sweep_step = assert(filewatching.make_sweep_stepper('universe'))
		sweep_update = on_update.after(1000, function(pause)
			while true do
				exec [[ BEGIN TRANSACTION ]]
				for i = 1, step_count do
					local type, folder, filename, size, last_modified = sweep_step()
					if type == 'file' then
						assert( sqlite3.SQLITE_OK == insert_stmt:bind_text(1, folder, #folder, nil) )
						assert( sqlite3.SQLITE_OK == insert_stmt:bind_text(2, filename, #filename, nil) )
						assert( sqlite3.SQLITE_OK == insert_stmt:bind_text(3, last_modified, #last_modified, nil) )
						assert( sqlite3.SQLITE_OK == insert_stmt:bind_int64(4, size) )
						assert( sqlite3.SQLITE_DONE == insert_stmt:step() )
						assert( sqlite3.SQLITE_OK == insert_stmt:reset() )
					elseif type == 'end' then
						flush_changes(folder)
					end
				end
				exec [[ COMMIT TRANSACTION ]]
				pause(step_ms)
			end
		end)
	end
	do_sweep()

	local filenotify_update
	filewatching.watch('universe', true, function()
		if sweep_update ~= nil then
			on_update.kill(sweep_update)
			sweep_update = nil
		end
		if sweep_step ~= nil then
			filewatching.stop_sweep_stepper(sweep_step)
			sweep_step = nil
		end
		if filenotify_update ~= nil then
			on_update.kill(filenotify_update)
			filenotify_update = nil
		end
		filenotify_update = on_update.after(150, do_sweep)
	end)
end

return filewatching
