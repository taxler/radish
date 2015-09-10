
local ffi = require 'ffi'
local mswin = require 'exports.mswindows'
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
	end
end

return worker_thread
