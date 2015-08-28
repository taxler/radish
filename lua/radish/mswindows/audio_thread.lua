
local mswin = require 'exports.mswindows'
local ffi = require 'ffi'
local on_wait_object_signals = require 'radish.mswindows.on_wait_object_signals'
local on_other_events = require 'radish.mswindows.on_other_events'
local selflib = require 'radish.mswindows.exports'
local selfstate = selflib.radish_get_state()

local volume = 1.0

local audio_thread = {}

do -- audio processing
	local audio = require 'radish.mswindows.audio'

	local out_padding_count = ffi.new 'uint32_t[1]'
	local out_buffer = ffi.new 'uint8_t*[1]'
	local AUDCLNT_BUFFERFLAGS_SILENT = 2

	local function fill_audio_buffer(padding)
		local available_frames = audio.buffer_size
		if padding then
			assert(0 == audio.client:GetCurrentPadding(out_padding_count))
			available_frames = available_frames - out_padding_count[0]
		end
		assert(0 == audio.render_client:GetBuffer(available_frames, out_buffer))
		local buffer = out_buffer[0]
		local buf_floats = ffi.cast('float*', buffer)
		for i = 0, (available_frames * audio.frame_bytes)/4 - 1, 2 do
			buf_floats[i] = volume * ((math.random() * 2) - 1)
			buf_floats[i+1] = buf_floats[i]
		end
		local written_frames = available_frames
		local flags = 0
		assert(0 == audio.render_client:ReleaseBuffer(written_frames, flags))
	end

	fill_audio_buffer(false)

	on_wait_object_signals:add(audio.event_handle, function()
		fill_audio_buffer(true)
	end)
end

do -- message processing
	local function send_data(data)
		selflib.radish_send_thread(selfstate.parent_thread_id, data, #data)
	end

	local function on_data(data)
		local new_volume = tonumber(data:match('^set_volume%((.-)%)$'))
		if new_volume then
			volume = new_volume
		else
			send_data('unknown command: ' .. data)
		end
	end

	on_other_events[selflib.WMRADISH_THREAD_SEND_DATA] = function(_, message, wparam, lparam)
		local buf = ffi.cast('radish_buffer*', lparam)
		local data = ffi.string(buf.data, buf.length)
		on_data(data)
	end
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

function audio_thread.main_loop()
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

return audio_thread
