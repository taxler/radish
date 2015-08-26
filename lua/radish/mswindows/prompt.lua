
local ffi = require 'ffi'
local selflib = require 'radish.mswindows.exports'
local on_host_events = require 'radish.mswindows.on_host_events'
local winstr = require 'exports.mswindows.strings'

local prompt = {}

local selfstate = selflib.radish_get_state()

local responders = {}

function prompt.alert(msg, responder, harsh)
	local text = winstr.wide(msg)
	local id
	if responder == nil then
		id = 0
	else
		id = #responders + 1
		responders[id] = responder
	end
	local alert = ffi.new('radish_dialog', {
		type = selflib.RADISH_DIALOG_ALERT;
		alert = {
			text = text;
		};
		id = id;
		harsh = not not harsh;
	})
	selflib.radish_request_dialog(selfstate, alert)
end

function prompt.confirm(msg, responder, harsh, can_cancel)
	local text = winstr.wide(msg)
	local id
	if responder == nil then
		id = 0
	else
		id = #responders + 1
		responders[id] = responder
	end
	local dialog = ffi.new('radish_dialog', {
		type = selflib.RADISH_DIALOG_CONFIRM;
		confirm = {
			text = text;
			can_cancel = can_cancel;
			harsh = harsh;
		};
		id = id;
	})
	selflib.radish_request_dialog(selfstate, dialog)
end

on_host_events[selflib.WMRADISH_DIALOG_RESPONSE] = function(hwnd, message, wparam, lparam)
	local dialog = ffi.cast('radish_dialog*', lparam)
	local id = dialog.id
	if id ~= nil then
		local responder = responders[id]
		responders[id] = nil
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

return prompt
