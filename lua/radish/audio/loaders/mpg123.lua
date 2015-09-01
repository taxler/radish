
local success, libmpg123 = pcall( require, 'exports.mpg123' )

if not (success and libmpg123) then
	return false
end

-- TODO: make certain this is per-process
libmpg123.mpg123_init()

local ffi = require 'ffi'

return function(path)
	local mpg123 = libmpg123.mpg123_new(nil, nil)
	ffi.gc(mpg123, libmpg123.mpg123_delete)

	if 0 ~= libmpg123.mpg123_open(mpg123, path) then
		ffi.gc(mpg123, nil)
		libmpg123.mpg123_delete(mpg123)
		return nil
	end

	-- clear output formats
	if 0 ~= libmpg123.mpg123_format_none(mpg123) then
		ffi.gc(mpg123, nil)
		libmpg123.mpg123_delete(mpg123)
		return nil
	end

	return function(output)
		local channels = assert(tonumber(output.channels), 'channels must be specified')
		assert(channels == 1 or channels == 2, 'channels must be 1 or 2')

		local enc
		if output.sample_ctype == ffi.typeof 'float' then
			enc = libmpg123.MPG123_ENC_FLOAT_32
		elseif output.sample_ctype == ffi.typeof 'double' then
			enc = libmpg123.MPG123_ENC_FLOAT_64
		elseif output.sample_ctype == ffi.typeof 'int32_t' then
			enc = libmpg123.MPG123_ENC_SIGNED_32
		elseif output.sample_ctype == ffi.typeof 'int16_t' then
			enc = libmpg123.MPG123_ENC_SIGNED_16
		elseif output.sample_ctype == ffi.typeof 'uint8_t' then
			enc = libmpg123.MPG123_ENC_UNSIGNED_8
		elseif output.sample_ctype == ffi.typeof 'uint32_t' then
			enc = libmpg123.MPG123_ENC_UNSIGNED_32
		elseif output.sample_ctype == ffi.typeof 'uint16_t' then
			enc = libmpg123.MPG123_ENC_UNSIGNED_16
		elseif output.sample_ctype == ffi.typeof 'int8_t' then
			enc = libmpg123.MPG123_ENC_SIGNED_8
		else
			-- TODO: support int64_t/uint64_t?
			return nil, 'unsupported sample type'
		end

		if 0 ~= libmpg123.mpg123_format(mpg123, output.sample_rate, output.channels, enc) then
			return nil, 'unable to set output format for mp3'
		end

		local buffer_size = libmpg123.mpg123_outblock(mpg123)
		local buffer = ffi.new('uint8_t[' .. buffer_size .. ']')

		local sample_source = {}

		local out_done = ffi.new 'size_t[1]'
		local frame_size = channels * ffi.sizeof(output.sample_ctype)
		local t_byte_ptr = ffi.typeof('uint8_t*')

		local function write(to_ptr, frame_count)
			to_ptr = ffi.cast(t_byte_ptr, to_ptr)
			local to_end = to_ptr + (frame_count * frame_size)
			while to_ptr < to_end do
				local result = libmpg123.mpg123_read(mpg123, to_ptr, to_end - to_ptr, out_done)
				to_ptr = to_ptr + out_done[0]
				if result ~= 0 then
					if result == libmpg123.MPG123_NEW_FORMAT then
						-- ignore?
					elseif result == libmpg123.MPG123_DONE then
						ffi.gc(mpg123, nil)
						libmpg123.mpg123_delete(mpg123)
						if to_ptr < to_end then
							ffi.fill(to_ptr, to_end - to_ptr)
						end
						write = function(to_ptr, frame_count)
							ffi.fill(to_ptr, frame_count * frame_size)
						end
						return false
					else
						-- TODO: better handling
						error('mpg123 error: ' .. result)
					end
				end
			end
		end

		function sample_source:write(to_ptr, frame_count)
			return write(to_ptr, frame_count)
		end

		return sample_source
	end
end
