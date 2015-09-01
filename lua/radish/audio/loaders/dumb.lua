
local success, dumb = pcall( require, 'exports.dumb' )

if not (success and dumb) then
	return false
end

local bit = require 'bit'
local ffi = require 'ffi'

dumb.dumb_register_stdfiles()

local function from_duh(duh)
	return function(output)
		local channels = assert(tonumber(output.channels), 'channels must be specified')
		assert(channels == 1 or channels == 2, 'channels must be 1 or 2')
		local sigrenderer = dumb.duh_start_sigrenderer(
			duh,
			0,
			channels,
			0)
		ffi.gc(sigrenderer, dumb.duh_end_sigrenderer)
		local sample_source = {duh=duh}
		local hz, delta, volume
		function sample_source:set_hz(new_hz)
			new_hz = assert(tonumber(new_hz), 'hz must be a number')
			assert(new_hz > 0, 'hz must be greater than zero')
			hz = new_hz
			delta = 65536 / new_hz
		end
		function sample_source:get_hz()
			return hz
		end
		sample_source:set_hz(assert(tonumber(output.sample_rate), 'hz not specified'))
		local volume = 1
		function sample_source:set_volume(new_volume)
			new_volume = assert(tonumber(new_volume), 'volume must be a number')
			volume = new_volume
		end
		function sample_source:get_volume()
			return volume
		end
		local last_buffer
		local last_buffer_frame_count = -1
		local function get_buffer(frame_count)
			local buffer
			if last_buffer_frame_count >= frame_count then
				buffer = last_buffer
			else
				buffer = dumb.allocate_sample_buffer(channels, frame_count)
				ffi.gc(buffer, dumb.destroy_sample_buffer)
				if last_buffer ~= nil then
					ffi.gc(last_buffer, nil)
					dumb.destroy_sample_buffer(last_buffer)
				end
				last_buffer = buffer
				last_buffer_frame_count = frame_count
			end
			dumb.dumb_silence(buffer[0], channels * frame_count)
			return buffer
		end
		local NATIVE_FRAME_SIZE = ffi.sizeof('int') * channels
		local function get_native(frame_count)
			local buffer = get_buffer(frame_count)
			local written = dumb.duh_sigrenderer_generate_samples(
				sigrenderer,
				volume,
				delta,
				frame_count,
				buffer)
			if written < frame_count then
				ffi.gc(sigrenderer, nil)
				dumb.duh_end_sigrenderer(sigrenderer)
				sigrenderer = nil
				self.duh = nil
				get_native = function()
					return nil, 0
				end
				return nil, 0
			end
			return buffer[0], written
		end
		if output.sample_ctype == ffi.typeof 'int' and output.sample_bits == 24 then
			function sample_source:write(to_ptr, frame_count)
				local from_ptr, actual_count = get_native(frame_count)
				if from_ptr ~= nil then
					ffi.copy(to_ptr, from_ptr, frame_count * NATIVE_FRAME_SIZE)
				end
				if actual_count < frame_count then
					ffi.fill(
						to_ptr + (actual_count * channels),
						(frame_count - actual_count) * NATIVE_FRAME_SIZE)
					return true
				end
				return false
			end
		else
			local frame_size = ffi.sizeof(output.sample_ctype) * channels

			local convert_sample do
				local bits = output.sample_bits or ffi.sizeof(output.sample_ctype) * 8
				if output.sample_ctype == ffi.typeof 'float' or output.sample_ctype == ffi.typeof 'double' then
					assert(bits == ffi.sizeof(output.sample_ctype) * 8, 'invalid number of bits for float/double samples')
					convert_sample = function(v)  return v / 0x800000  end
				elseif output.sample_ctype == ffi.typeof 'uint8_t' or output.sample_ctype == ffi.typeof 'uint16_t'
						or output.sample_ctype == ffi.typeof 'uint32_t' or output.sample_ctype == ffi.typeof 'uint64_t' then
					local max_value = 1
					for i = 1, bits - 1 do
						max_value = bit.bor(bit.lshift(max_value, 1), 1)
					end
					convert_sample = function(v)  return ((v + 0x800000) * max_size) / 0xffffff end
				elseif output.sample_ctype == ffi.typeof 'int8_t' or output.sample_ctype == ffi.typeof 'int16_t'
						or output.sample_ctype == ffi.typeof 'int32_t' or output.sample_ctype == ffi.typeof 'int64_t' then
					local half_size = bit.lshift(1, bits-1)
					convert_sample = function(v)  return (v * half_size) / 0x800000 end
				else
					error('unsupported sound sample format: ' .. tostring(output.sample_ctype))
				end
			end

			function sample_source:write(to_ptr, frame_count)
				local from_ptr, actual_count = get_native(frame_count)
				if from_ptr ~= nil then
					for i = 0, (frame_count * channels)-1 do
						to_ptr[i] = convert_sample(from_ptr[i])
					end
				end
				if actual_count < frame_count then
					ffi.fill(
						to_ptr + (actual_count * channels),
						(frame_count - len) * frame_size)
					return true
				end
				return false
			end
		end
		return sample_source
	end
end

return function(path)
	local ext = path:match('[^%.]+$')
	if ext == nil then
		return nil
	end
	ext = string.lower(ext)
	local duh = nil
	if ext == 'mod' then
		duh = dumb.dumb_load_mod(path, 0)
	elseif ext == 'it' then
		duh = dumb.dumb_load_it(path)
	elseif ext == 's3m' then
		duh = dumb.dumb_load_s3m(path)
	elseif ext == 'xm' then
		duh = dumb.dumb_load_xm(path)
	end
	if duh == nil then
		return nil
	end
	ffi.gc(duh, dumb.unload_duh)
	return from_duh(duh)
end
