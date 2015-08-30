
local mswin = require 'exports.mswindows'
local ffi = require 'ffi'
local on_wait_object_signal = require 'radish.mswindows.on_wait_object_signal'
local on_other_events = require 'radish.mswindows.on_other_events'
local selflib = require 'radish.mswindows.exports'
local selfstate = selflib.radish_get_state()
local audio = require 'radish.mswindows.audio'

local volume_factor = 1.0
local panning_angle = 0.0

local audio_thread = {}

if false then
	local com = require 'exports.mswindows.com'
	local strusto = require 'exports.mswindows.structuredstorage'
	local shlwapi = require 'exports.mswindows.shell.lightweight'
	local checks = require 'exports.mswindows.checks'
	local subtypes = require 'exports.mswindows.media.subtypes'
	local audio_foundation = require 'radish.mswindows.audio.foundation'

	function audio_thread.load_mp3(path)

		local stream = assert(com.check_out('IStream*', function(out_stream)
			return shlwapi.SHCreateStreamOnFileEx(
				winstr.wide(path),
				strusto.STGM_READ,
				mswin.FILE_ATTRIBUTE_NORMAL,
				false,
				nil,
				out_stream)
		end))

		local source_reader = assert(audio_foundation.make_source_reader_for_istream(stream))

		local decode_transform = assert(audio_foundation.make_mp3_decode_transform_for_source_reader(source_reader))

		local nearest_i, exact = assert(audio_foundation.transform_find_nearest_output_type(decode_transform,
			subtypes.MEDIASUBTYPE_IEEE_FLOAT, 2, 48000, 32))

		local nearest = assert(audio_foundation.transform_get_output_type_by_index(decode_transform, nearest_i))

		assert(audio_foundation.transform_set_output_type(decode_transform, nearest))

		local sample_provider = coroutine.wrap(function(fill_ptr, fill_len)
			local decoded_stream_info = ffi.new 'MFT_OUTPUT_STREAM_INFO'
			assert( 0 == decode_transform:GetOutputStreamInfo(0, decoded_stream_info) )
			local decoded_sample = assert(audio_foundation.make_sample())
			local decode_buffer = assert(audio_foundation.make_buffer(decoded_stream_info.cbSize))
			assert(audio_foundation.buffer_set_length(buffer, 0))
			assert(audio_foundation.sample_add_buffer(sample, buffer))
			local output_data_buffer = ffi.new('MFT_OUTPUT_DATA_BUFFER', {
				dwStreamID = 0;
				pSample = sample;
			})
			assert(audio_foundation.transform_start(decode_transform))

			--[=[
			local out_flags = ffi.new 'uint32_t[1]'
			local out_length = ffi.new 'uint32_t[1]'
			local out_status = ffi.new 'uint32_t[1]'
			local out_timestamp = ffi.new 'int64_t[1]'
			local out_ptr = ffi.new 'uint8_t*[1]'
			local out_sample = ffi.new 'IMFSample*[1]'
			local out_mbuffer = ffi.new 'IMFMediaBuffer*[1]'
			while true do
				local hresult = reader:ReadSample(
					mfplat.MF_SOURCE_READER_FIRST_AUDIO_STREAM,
					0,
					nil, -- out_stream_index,
					out_flags,
					out_timestamp,
					out_sample)

				if hresult ~= 0 then
					break
				end

				local encoded_sample = com.gc( out_sample[0] )
				hresult = decode_transform:ProcessInput(0, encoded_sample, 0)
				
				output_data_buffer.dwStatus = 0
				output_data_buffer.pEvents = 0

				do
					hresult = decode_transform:ProcessOutput(0, 1, output_data_buffer, out_status)

					--assert(hr ~= mfplat.MF_E_TRANSFORM_STREAM_CHANGE)

					-- Mp3 decoder seems not to tell us there is more data for output...
					--assert(OutputDataBuffer.dwStatus ~= mfplat.MFT_OUTPUT_DATA_BUFFER_INCOMPLETE)

					if hresult == 0 then
						assert(0 == buffer:GetCurrentLength(out_length))

						assert(0 == sample:ConvertToContiguousBuffer(out_mbuffer))
						assert(0 == out_mbuffer[0]:Lock(out_data, nil, out_length))

						local length = out_length[0]
						local data = out_data[0]
						while length > 0 do
							local copying = math.min(fill_len, length)
							ffi.copy(fill_ptr, data, copying)
							fill_ptr = fill_ptr + copying
							fill_len = fill_len - copying
							if fill_len == 0 then
								fill_len, fill_ptr = coroutine.yield(true)
							end
							data = data + copying
							length = length - copying
						end

						uiFileLength = uiFileLength + dwLength

						LOG_HRESULT(hr = pResultBuffer:Unlock())
					end

					assert( 0 == pOutputBuffer:SetCurrentLength(0) )

					com.release( mbuffer, encoded_sample )
				until hr ~= 0
			end
			--]=]

			audio_foundation.transform_stop(decode_transform)
		end)

		if not exact then

			local in_type = nearest
			local out_type = assert( audio_foundation.make_audio_type(subtypes.MEDIASUBTYPE_IEEE_FLOAT, 2, 48000, 32) )

			local resample_transform = assert( audio_foundation.make_audio_resampler_transform(in_type, out_type) )

			local sample = assert( audio_foundation.make_sample() )

			assert( audio_foundation.transform_start(resample_transform) )

			-- TODO

			assert( audio_foundation.transform_stop(resample_transform) )
		end

		--com.release( stream )
	end
end

do -- audio processing
	local out_padding_count = ffi.new 'uint32_t[1]'
	local out_buffer = ffi.new 'uint8_t*[1]'
	local AUDCLNT_BUFFERFLAGS_SILENT = 2

	local sqrt_2_over_2 = math.sqrt(2) / 2

	local sin, cos = math.sin, math.cos

	local function fill_audio_buffer(padding)
		local available_frames = audio.buffer_size
		if padding then
			assert(0 == audio.client:GetCurrentPadding(out_padding_count))
			available_frames = available_frames - out_padding_count[0]
		end
		assert(0 == audio.render_client:GetBuffer(available_frames, out_buffer))
		local buffer = out_buffer[0]
		local buf_floats = ffi.cast('float*', buffer)
		local left_factor = volume_factor * sqrt_2_over_2 * (cos(panning_angle) + sin(panning_angle))
		local right_factor = volume_factor * sqrt_2_over_2 * (cos(panning_angle) - sin(panning_angle))
		for i = 0, (available_frames * audio.frame_bytes)/4 - 1, 2 do
			local sample = (math.random() * 2) - 1
			buf_floats[i] = left_factor * sample
			buf_floats[i+1] = right_factor * sample
		end
		local written_frames = available_frames
		local flags = 0
		assert(0 == audio.render_client:ReleaseBuffer(written_frames, flags))
	end

	fill_audio_buffer(false)

	on_wait_object_signal(audio.event_handle, function()
		fill_audio_buffer(true)
	end)
end

function print(...)
	local buf = {...}
	for i = 1, #buf do
		buf[i] = tostring(buf[i])
	end
	buf = table.concat(buf, '\t')
	selflib.radish_send_thread(selfstate.parent_thread_id, buf, #buf)
end

do -- message processing
	local function on_data(data)
		local new_volume = tonumber(data:match('^set_volume%((.-)%)$'))
		local new_panning = tonumber(data:match('^set_panning%((.-)%)$'))
		if new_volume then
			-- http://www.dr-lex.be/info-stuff/volumecontrols.html
			local new_volume_factor = new_volume / 10 -- scale of 0 to 10; steps of 10% smallest that most people can differentiate
			new_volume_factor = math.exp(new_volume_factor * math.log(1000)) / 1000 -- reverse logarithmic nature of volume
			if new_volume < 1 then
				-- make sure 0 really is 0, with smooth fit for near-zero
				new_volume_factor = new_volume_factor * new_volume
			end
			volume_factor = new_volume_factor
		elseif new_panning then
			panning_angle = new_panning * (math.pi / 4) -- -1..+1 -> -45deg..+45deg
		else
			print('unknown command: ' .. data)
		end
	end

	on_other_events[selflib.WMRADISH_THREAD_SEND_DATA] = function(_, message, wparam, lparam)
		local buf = ffi.cast('radish_buffer*', lparam)
		local data = ffi.string(buf.data, buf.length)
		on_data(data)
		print(audio.sample_rate)
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
