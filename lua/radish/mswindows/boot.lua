
local selflib = require 'radish.mswindows.exports'

local boot = {}

local selfstate = selflib.radish_get_state()

local function each_event(with_windows)
	if with_windows then
		return function()
			selflib.radish_wait_message(selfstate)
			if selfstate.msg.message == selflib.WMRADISH_TERMINATE then
				return
			end
			return selfstate.msg.hwnd, selfstate.msg.message, selfstate.msg.wParam, selfstate.msg.lParam
		end
	else
		return function()
			selflib.radish_wait_message(selfstate)
			if selfstate.msg.message == selflib.WMRADISH_TERMINATE then
				return nil
			end
			return selfstate.msg.message, selfstate.msg.wParam, selfstate.msg.lParam
		end
	end
end

function boot.main_loop()
	error 'Hello world!'
	for hwnd, message, wparam, lparam in each_event(true) do

	end
end

function boot.thread_loop()
	for message, wparam, lparam in each_event(false) do
	end
end

return boot
