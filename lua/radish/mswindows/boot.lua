
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
local on_update = require 'radish.mswindows.on_update'
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

local audio_thread_id = selflib.radish_create_thread(winstr.wide 'AUDIO_THREAD.LUA')
local audio_thread_ready = false

on_other_events[selflib.WMRADISH_THREAD_TERMINATED] = function(hwnd, message, wparam, lparam)
	if wparam == audio_thread_id then
		local dead_state = ffi.cast('radish_state*', lparam)
		print('audio thread terminated')
		if dead_state.error ~= nil then
			print('audio thread error: ' .. winstr.utf8(dead_state.error))
		end
		audio_thread_ready = false
		audio_thread_id = nil
	else
		print('thread terminated but not audio thread? (expecting ' .. audio_thread_id .. ' got ' .. wparam .. ')')
	end
end

on_other_events[selflib.WMRADISH_THREAD_READY] = function(hwnd, message, wparam, lparam)
	if wparam == audio_thread_id then
		print 'audio thread ready!'
		audio_thread_ready = true
	else
		print('thread ready but not audio thread? (expecting ' .. audio_thread_id .. ' got ' .. wparam .. ')')
	end
end

on_other_events[selflib.WMRADISH_THREAD_SEND_DATA] = function(hwnd, message, wparam, lparam)
	if wparam == audio_thread_id then
		local buf = ffi.cast('radish_buffer*', lparam)
		local data = ffi.string(buf.data, buf.length)
		print('received message from audio thread: ' .. string.format('%q', data))
	else
		print('received message but not from audio thread? (expecting ' .. audio_thread_id .. ' got ' .. wparam .. ')')
	end
end

on_host_events[mswin.WM_LBUTTONDOWN] = function(hwnd, message, wparam, lparam)
	if audio_thread_ready then
		local message = 'set_volume(' .. math.random(0,10) .. ')'
		print('sending audio thread: ' .. message)
		selflib.radish_send_thread(audio_thread_id, message, #message)
	end
end

on_host_events[mswin.WM_RBUTTONDOWN] = function(hwnd, message, wparam, lparam)
end

selfstate.update_timeout = 25
local sweep_step, sweep_update
local function do_sweep()
	if sweep_step ~= nil then
		filewatching.stop_sweep_stepper(sweep_step)
		sweep_step = nil
	end
	if sweep_update ~= nil then
		on_update.kill(sweep_update)
		sweep_update = nil
	end
	local count = 0
	for type, folder, filename, size, last_modified in filewatching.full_sweep('universe') do
		count = count + 1
	end
	print('full sweep count', count)
	sweep_step = assert(filewatching.make_sweep_stepper('universe'))
	sweep_update = on_update.after(1000, function(pause)
		while true do
			for i = 1, 100 do
				local type, folder, filename, size, last_modified = sweep_step()
				if type == 'end' and folder == 'universe' then
					print 'completed soft sweep'
				end
			end
			pause(200)
		end
	end)
end
do_sweep()
local filenotify_update
filewatching.watch('universe', true, function()
	if sweep_update ~= nil then
		on_update.kill(sweep_update)
		sweep_update = nil
	end
	if sweep_step ~= nil then
		filewatching.stop_sweep_stepper(sweep_step)
		sweep_step = nil
	end
	if filenotify_update ~= nil then
		on_update.kill(filenotify_update)
		filenotify_update = nil
	end
	filenotify_update = on_update.after(150, do_sweep)
end)


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
