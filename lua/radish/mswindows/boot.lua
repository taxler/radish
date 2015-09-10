
local bit = require 'bit'
local ffi = require 'ffi'
local crt = require 'exports.crt'
local mswin = require 'exports.mswindows'
local winkeys = require 'exports.mswindows.keys'
local winstr = require 'exports.mswindows.strings'
local winmenus = require 'exports.mswindows.menus'
local selflib = require 'radish.mswindows.exports'
local prompt = require 'radish.mswindows.prompt'
local on_host_events = require 'radish.mswindows.on_host_events'
local on_other_events = require 'radish.mswindows.on_other_events'
local on_thread_events = require 'radish.mswindows.on_thread_events'
local task_client = require 'radish.mswindows.task.client'
local filewatching = require 'radish.mswindows.filewatching'

local boot = {}

local selfstate = selflib.radish_get_state()

local _print = print
function print(...)
	if mswin.AllocConsole() then
		crt.freopen('CONOUT$', 'w', ffi.cast('FILE*', io.stdout))
		local console_hwnd = mswin.GetConsoleWindow()
		mswin.ShowWindow(console_hwnd, mswin.SW_HIDE)
		mswin.SetWindowLongPtrW(
			console_hwnd,
			mswin.GWL_HWNDPARENT,
			ffi.cast('intptr_t', selfstate.host_window.hwnd))
		mswin.SetWindowLongPtrW(
			console_hwnd,
			mswin.GWL_EXSTYLE,
			bit.bor( mswin.WS_EX_LAYERED ))
		mswin.SetLayeredWindowAttributes(
			console_hwnd,
			0,
			180,
			mswin.LWA_ALPHA)
		mswin.EnableMenuItem(
			mswin.GetSystemMenu(console_hwnd, false),
			mswin.SC_CLOSE,
			bit.bor( winmenus.MF_BYCOMMAND, winmenus.MF_GRAYED, winmenus.MF_DISABLED ))
		mswin.ShowWindow(console_hwnd, mswin.SW_SHOWNOACTIVATE)
	end
	print = _print
	return _print(...)
end

on_host_events[mswin.WM_CLOSE] = function(hwnd, message, wparam, lparam)
	prompt.confirm('Are you sure you want to quit?', function(response)
		if response == true then
			mswin.PostMessageW(
				selfstate.host_window.hwnd,
				selflib.WMRADISH_DESTROY_WINDOW_REQUEST,
				0,
				0)
		end
	end)
end

on_host_events[mswin.WM_DESTROY] = function(hwnd, message, wparam, lparam)
	mswin.PostQuitMessage(0)
end

local audio_thread = on_thread_events.spawn_thread('audio_thread.lua')

function audio_thread:on_terminated(error_message)
	print('audio thread terminated')
	if error_message ~= nil then
		print('audio thread error: ' .. error_message)
	end
end

function audio_thread:on_ready()
	print 'audio thread ready!'
end

function audio_thread:on_message(data)
	print('received message from audio thread: ' .. data)
end

on_host_events[mswin.WM_LBUTTONDOWN] = function(hwnd, message, wparam, lparam)
	local message = 'set_volume(' .. math.random(0,10) .. ')'
	print('sending audio thread: ' .. message)
	audio_thread:send_message(message)
end

local task_worker = task_client.spawn_worker()

function task_worker:on_response(...)
	print('response from worker', ...)
end

function task_worker:on_terminated(error_message)
	print('worker thread terminated')
	if error_message ~= nil then
		print('worker thread error: ' .. error_message)
	end
end

on_host_events[mswin.WM_RBUTTONDOWN] = function(hwnd, message, wparam, lparam)
end

selfstate.update_timeout = 25
function filewatching.on_new(path)
	print('new', path)
end
function filewatching.on_modified(path)
	print('mod', path)
end
function filewatching.on_deleted(path)
	print('del', path)
end
filewatching.begin('universe', task_worker)

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

local accelerator_keys = {}
accelerator_keys[#accelerator_keys + 1] = {
	fVirt = bit.bor( winkeys.FVIRTKEY, winkeys.FALT );
	key = winkeys.VK_RETURN;
	cmd = selflib.SCRADISH_TOGGLE_FULLSCREEN;
}
accelerator_keys[#accelerator_keys + 1] = {
	fVirt = winkeys.FVIRTKEY;
	key = winkeys.VK_F11;
	cmd = selflib.SCRADISH_TOGGLE_FULLSCREEN;
}

selfstate.accelerator_table = winkeys.CreateAcceleratorTableW(
	ffi.new('ACCEL[' .. #accelerator_keys .. ']', accelerator_keys),
	#accelerator_keys)

on_host_events[mswin.WM_CREATE] = function(hwnd, message, wparam, lparam)
	local system_menu = winmenus.GetSystemMenu(hwnd, false)
	winmenus.AppendMenuW(system_menu, winmenus.MF_SEPARATOR, 0, nil)
	winmenus.AppendMenuW(system_menu, winmenus.MF_STRING,
		selflib.SCRADISH_TOGGLE_FULLSCREEN,
		winstr.wide 'Toggle Fullscreen\tAlt+Enter')
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

function boot.main_loop()
	for hwnd, message, wparam, lparam in each_event() do
		local handler
		if hwnd == selfstate.host_window.hwnd then
			handler = on_host_events[message]
		else
			handler = on_other_events[message]
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
