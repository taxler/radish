
local mswin = require 'exports.mswindows'
local ffi = require 'ffi'
local selflib = require 'radish.mswindows.exports'
local selfstate = selflib.radish_get_state()

local test_thread = {}

local function each_event()
	return function()
		selflib.radish_wait_message(selfstate)
		-- break the loop on WM_QUIT
		if selfstate.msg.message == mswin.WM_QUIT then
			return
		end
		return selfstate.msg.message, selfstate.msg.wParam, selfstate.msg.lParam
	end
end

local function send_data(data)
	selflib.radish_send_thread(selfstate.parent_thread_id, data, #data)
end

local function on_data(data)
	send_data(string.reverse(data))
end

local on_thread_events = {}

on_thread_events[selflib.WMRADISH_THREAD_SEND_DATA] = function(message, wparam, lparam)
	local buf = ffi.cast('radish_buffer*', lparam)
	local data = ffi.string(buf.data, buf.length)
	on_data(data)
end

function test_thread.main_loop()
	for message, wparam, lparam in each_event() do
		local handler = on_thread_events[message]
		if handler ~= nil then
			local result = handler(message, wparam, lparam)
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

return test_thread
