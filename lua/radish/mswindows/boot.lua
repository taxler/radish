
local ffi = require 'ffi'
local crt = require 'exports.crt'
local mswin = require 'exports.mswindows'
local winstr = require 'exports.mswindows.strings'
local selflib = require 'radish.mswindows.exports'
local prompt = require 'radish.mswindows.prompt'
local on_host_events = require 'radish.mswindows.on_host_events'

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

on_host_events[mswin.WM_KEYDOWN] = function(hwnd, message, wparam, lparam)
	prompt.confirm("Hello World?", function(response)
		if response == true then
			prompt.alert "Clicked Yes"
		elseif response == false then
			prompt.alert "Clicked No"
		elseif response == nil then
			prompt.alert "Clicked Cancel"
		end
	end, true)
end

function boot.main_loop()
	for hwnd, message, wparam, lparam in each_event(true) do
		local handler
		if hwnd == selfstate.host_window.hwnd then
			handler = on_host_events[message]
		end
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

return boot
