
local mswin = require 'exports.mswindows'
local on_host_events = {}

on_host_events[mswin.WM_DESTROY] = function(hwnd, message, wparam, lparam)
	mswin.PostQuitMessage(0)
end

return on_host_events
