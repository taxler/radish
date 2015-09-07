
local bit = require 'bit'
local ffi = require 'ffi'
local mswin = require 'exports.mswindows'
local winstr = require 'exports.mswindows.strings'
local winfiles = require 'exports.mswindows.filesystem'
local winhandles = require 'exports.mswindows.handles'
local on_wait_object_signal = require 'radish.mswindows.on_wait_object_signal'

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

function filewatching.sweep_stepper(path)
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
local function add_change_notifier(path, recursively)
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
		print 'a change was made!'
		if mswin.FindNextChangeNotification(handle) == false then
			print 'creating new notifier'
			add_change_notifier(path, recursively)
			return 'remove'
		end
	end)
	return true
end

function filewatching.watch(path, recursively)
	return add_change_notifier(path, recursively)
end

return filewatching
