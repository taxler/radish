
local ffi = require 'ffi'
local crt = require 'exports.crt'
local mswin = require 'exports.mswindows'
local selflib = require 'radish.mswindows.exports'
local winstr = require 'exports.mswindows.strings'

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

local dialog_responders = {}

local function alert(msg, responder)
	local text = winstr.wide(msg)
	local id
	if responder == nil then
		id = 0
	else
		id = #dialog_responders + 1
		dialog_responders[id] = responder
	end
	local alert = ffi.new('radish_dialog', {
		type = selflib.RADISH_DIALOG_ALERT;
		alert = {
			text = text;
		};
		id = id;
	})
	selflib.radish_request_dialog(selfstate, alert)
end

local function confirm(msg, responder, can_cancel)
	local text = winstr.wide(msg)
	local id
	if responder == nil then
		id = 0
	else
		id = #dialog_responders + 1
		dialog_responders[id] = responder
	end
	local dialog = ffi.new('radish_dialog', {
		type = selflib.RADISH_DIALOG_CONFIRM;
		confirm = {
			text = text;
			can_cancel = can_cancel;
		};
		id = id;
	})
	selflib.radish_request_dialog(selfstate, dialog)
end

function boot.main_loop()
	for hwnd, message, wparam, lparam in each_event(true) do
		if message == mswin.WM_KEYDOWN then
			confirm("Hello World?", function(response)
				if response == true then
					print "Clicked Yes"
				elseif response == false then
					print "Clicked No"
				elseif response == nil then
					print "Clicked Cancel"
				end
			end, true)
		elseif message == selflib.WMRADISH_DIALOG_RESPONSE then
			local dialog = ffi.cast('radish_dialog*', lparam)
			local id = dialog.id
			if id ~= nil then
				local responder = dialog_responders[id]
				dialog_responders[id] = nil
				if responder ~= nil then
					if dialog.type == selflib.RADISH_DIALOG_CONFIRM then
						if dialog.confirm.response == string.byte('y') then
							responder(true)
						elseif dialog.confirm.response == string.byte('n') then
							responder(false)
						else
							responder(nil)
						end
					else
						responder()
					end
				end
			end
		end
	end
end

return boot
