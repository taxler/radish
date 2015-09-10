
local ffi = require 'ffi'
local mswin = require 'exports.mswindows'
local winstr = require 'exports.mswindows.strings'
local selflib = require 'radish.mswindows.exports'
local selfstate = selflib.radish_get_state()
local comms = require 'radish.mswindows.task.comms'
local on_other_events = require 'radish.mswindows.on_other_events'
local on_thread_events = require 'radish.mswindows.on_thread_events'

local worker_thread = {}

local function send_back(...)
	local v = comms.serialize(...)
	selflib.radish_send_thread(selfstate.parent_thread_id, v, #v)
end

local on_command = {}

local function handle_command(name, ...)
	local handler = on_command[name]
	if handler == nil then
		send_back('unknown_command', name)
	else
		handler(...)
	end
end

function on_command.echo(...)
	send_back(...)
end

local pending_commands = {}

local function file_op_aux(mode, from_path, to_path, id)
	local fop = selflib.radish_begin_progressing_file_op(
		selfstate,
		mode,
		winstr.wide(from_path),
		winstr.wide(to_path),
		0) -- do not fail if the file exists
	while selflib.radish_continue_progressing_file_op(fop) do
		local message = selfstate.msg.message
		if message == selflib.WMRADISH_FILE_OP_PROGRESS then
			if id ~= nil then
				send_back('progress', id, fop.total_bytes_transferred, fop.total_file_size)
			end
		elseif message == selflib.WMRADISH_FILE_OP_COMPLETE then
			if id ~= nil then
				send_back('complete', id)
			end
			break
		elseif message == selflib.WMRADISH_THREAD_SEND_DATA then
			-- TODO: differentiate commands that affect current operation
			-- (e.g. cancel) from commands that start a whole new operation
			local buf = ffi.cast('radish_buffer*', selfstate.msg.lParam)
			pending_commands[#pending_commands + 1] = ffi.string(buf.data, buf.length)
		else
			local handler = on_other_events[message]
			if handler ~= nil then
				handler(
					selfstate.msg.hwnd,
					message,
					selfstate.msg.wParam,
					selfstate.msg.lParam)
			end
		end
	end
	selflib.radish_free_progressing_file_op(fop)
end

function on_command.copy_file(from_path, to_path, id)
	return file_op_aux(selflib.PROGRESSING_COPY, from_path, to_path, id)
end

function on_command.move_file(from_path, to_path, id)
	return file_op_aux(selflib.PROGRESSING_MOVE, from_path, to_path, id)
end

on_other_events[selflib.WMRADISH_THREAD_SEND_DATA] = function(_, message, wparam, lparam)
	local buf = ffi.cast('radish_buffer*', lparam)
	local chunk = ffi.string(buf.data, buf.length)
	handle_command(comms.deserialize(chunk))
end

local function each_event()
	return function()
		selflib.radish_wait_message(selfstate)
		-- break the loop on WM_QUIT
		if selfstate.msg.message == mswin.WM_QUIT then
			return
		end
		return selfstate.msg.hwnd, selfstate.msg.message, selfstate.msg.wParam, selfstate.msg.lParam
	end
end

function worker_thread.main_loop()
	for hwnd, message, wparam, lparam in each_event() do
		local handler = on_other_events[message]
		if handler ~= nil then
			local result = handler(hwnd, message, wparam, lparam)
			if result ~= 'default' then
				selfstate.msg.message = selflib.WMRADISH_HANDLED
				if type(result) == 'boolean' then
					selfstate.msg.lParam = result and 1 or 0
				else
					selfstate.msg.lParam = tonumber(result) or 0
				end
			end
		end
		while pending_commands[1] ~= nil do
			local command = table.remove(pending_commands, 1)
			handle_command(comms.deserialize(command))
		end
	end
end

return worker_thread
