
local success, gme = pcall( require, 'exports.game_music_emu' )

if not (success and gme) then
	return false
end

local ffi = require 'ffi'
local bit = require 'bit'

return function(path)
	return function(output)
		local channels = assert(tonumber(output.channels), 'channels must be specified')
		local out_emu = ffi.new 'Music_Emu*[1]'
		local err = gme.gme_open_file(path, out_emu, output.sample_rate)
		if err ~= nil then
			return nil, ffi.string(err)
		end
		local emu = ffi.gc(out_emu[0], gme.gme_delete)

		-- TODO: support mono output
		if channels ~= 2 then
			ffi.gc(emu, nil)
			gme.gme_delete(emu)
			return nil, 'only stereo output is currently supported'
		end

		-- TODO: support track switching
		local err = gme.gme_start_track(emu, 0)
		if err ~= nil then
			ffi.gc(emu, nil)
			gme.gme_delete(emu)
			return nil, ffi.string(err)
		end

		local sample_source = {}

		local native_frame_size = ffi.sizeof 'short' * channels
		local function write_native(to_ptr, frame_count)
			local err = gme.gme_play(emu, frame_count * channels, to_ptr)
			if gme.gme_track_ended(emu) ~= 0 then
				ffi.gc(emu, nil)
				gme.gme_delete(emu)
				emu = nil
				write_native = function(to_ptr, frame_count)
					ffi.fill(to_ptr, frame_count * native_frame_size)
					return true
				end
				return true
			end
			return false
		end

		if output.sample_bits == 16 and output.sample_ctype == ffi.typeof 'int16_t' then

			function sample_source:write(out_ptr, frame_count)
				return write_native(out_ptr, frame_count)
			end

		else
			local last_buffer
			local last_buffer_frame_count = -1
			local function get_buffer(frame_count)
				local buffer
				if last_buffer_frame_count >= frame_count then
					buffer = last_buffer
				else
					buffer = ffi.new('short[' .. (frame_count * channels) .. ']')
					last_buffer = buffer
					last_buffer_frame_count = frame_count
				end
				return buffer
			end
			local convert_sample do
				local bits = output.sample_bits or ffi.sizeof(output.sample_ctype) * 8
				if output.sample_ctype == ffi.typeof 'float' or output.sample_ctype == ffi.typeof 'double' then
					assert(bits == ffi.sizeof(output.sample_ctype) * 8, 'invalid number of bits for float/double samples')
					convert_sample = function(v)  return v / 0x8000  end
				elseif output.sample_ctype == ffi.typeof 'uint8_t' or output.sample_ctype == ffi.typeof 'uint16_t'
						or output.sample_ctype == ffi.typeof 'uint32_t' or output.sample_ctype == ffi.typeof 'uint64_t' then
					local max_value = 1
					for i = 1, bits - 1 do
						max_value = bit.bor(bit.lshift(max_value, 1), 1)
					end
					convert_sample = function(v)  return ((v + 0x8000) * max_size) / 0xffff end
				elseif output.sample_ctype == ffi.typeof 'int8_t' or output.sample_ctype == ffi.typeof 'int16_t'
						or output.sample_ctype == ffi.typeof 'int32_t' or output.sample_ctype == ffi.typeof 'int64_t' then
					local half_size = bit.lshift(1, bits-1)
					convert_sample = function(v)  return (v * half_size) / 0x8000 end
				else
					error('unsupported sound sample format: ' .. tostring(output.sample_ctype))
				end
			end

			function sample_source:write(to_ptr, frame_count)
				local buffer = get_buffer(frame_count)
				local result = write_native(buffer, frame_count)
				for i = 0, (frame_count * channels)-1 do
					to_ptr[i] = convert_sample( buffer[i] )
				end
				return result
			end

		end

		return sample_source
	end
end
