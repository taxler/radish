
local ffi = require 'ffi'
local crt = require 'exports.crt'
local mswin = require 'exports.mswindows'
local selflib = require 'radish.mswindows.exports'

local boot = {}

local selfstate = selflib.radish_get_state()

local _print = print
function print(...)
	if mswin.AllocConsole() then
		crt.freopen('CONOUT$', 'w', ffi.cast('FILE*', io.stdout))
	end
	print = _print
	return _print(...)
end

local function each_event(with_windows)
	if with_windows then
		return function()
			selflib.radish_wait_message(selfstate)
			if selfstate.msg.message == mswin.WM_DESTROY
			and selfstate.msg.hwnd == selfstate.host_window.hwnd then
				return
			end
			return selfstate.msg.hwnd, selfstate.msg.message, selfstate.msg.wParam, selfstate.msg.lParam
		end
	else
		error 'TODO'
	end
end

function boot.main_loop()
	for hwnd, message, wparam, lparam in each_event(true) do
	end
end

return boot
