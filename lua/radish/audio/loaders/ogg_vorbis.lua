
local ffi = require 'ffi'
local success, ov = pcall( require, 'exports.xiph.vorbis.file' )

if not (success and ov) then
	return false
end

local function from_ogf(ogf)
	return function(output)
		local info = ov.ov_info(ogf, -1)
		local channels = info.channels
		local sample_source = {sample_rate = info.rate, channels = channels, sample_ctype = ffi.typeof 'float'}

		local frame_size = ffi.sizeof(output.sample_ctype) * output.channels

		local out_data = ffi.new 'float**[1]'
		local ref_sec = ffi.new 'int[1]'
		local function write(to_samples, frame_count)
			local n = 0
			repeat
				local actual_count = ov.ov_read_float(ogf, out_data, frame_count, ref_sec)
				n = n + 1
				if actual_count == 0 then
					ffi.gc(ogf, nil)
					ov.ov_clear(ogf)
					ogf = nil
					write = function(to_samples, frame_count)
						ffi.fill(to_samples, frame_count * frame_size)
						return true
					end
					return write(to_samples, frame_count)
				elseif actual_count < 0 then
					-- TODO: better error handling
					error('error code ' .. actual_count .. ' playing ogg vorbis audio file')
				else
					for c = 0, channels-1 do
						for i = 0, actual_count-1 do
							to_samples[i*channels + c] = out_data[0][c][i]
						end
					end
					to_samples = to_samples + actual_count * channels
					frame_count = frame_count - actual_count
				end
			until frame_count == 0
			return false
		end

		function sample_source:write(to_frames, to_frame_count)
			return write(to_frames, to_frame_count)
		end

		if sample_source.sample_rate ~= output.sample_rate then
			local resampling = require 'radish.audio.resampling'
			return resampling.make_resampler(sample_source, output)
		else
			return sample_source
		end
	end
end

return function(path)
	local ogf = ffi.new 'OggVorbis_File'
	if 0 ~= ov.ov_fopen(path, ogf) then
		return nil, 'unable to load ogg'
	end
	ffi.gc(ogf, ov.ov_clear)
	return from_ogf(ogf)
end
