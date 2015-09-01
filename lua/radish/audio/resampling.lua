
local ffi = require 'ffi'
local otr = require 'exports.xiph.opus.resampler'

local resampling = {}

function resampling.make_resampler(sample_source, output)
	-- TODO: support mono
	local from_channels = sample_source.channels
	local to_channels = output.channels
	assert(from_channels == 2 and to_channels == 2, 'channels must be 2')

	-- TODO: support other sample types
	assert(
		sample_source.sample_ctype == ffi.typeof 'float'
		and output.sample_ctype == ffi.typeof 'float',
		'sample type must be float')

	local out_err = ffi.new 'int[1]'

	local resampler = otr.opustools_resampler_init(
		2,
		sample_source.sample_rate,
		output.sample_rate,
		otr.OPUSTOOLS_RESAMPLER_QUALITY_DESKTOP,
		out_err)

	if out_err[0] ~= 0 then
		error('failed to create audio resampler, error code ' .. out_err[0])
	end

	ffi.gc(resampler, otr.opustools_resampler_destroy)

	local resampled_source = {}

	local t_sample_array = ffi.typeof('$[?]', sample_source.sample_ctype)

	local last_buffer
	local last_buffer_frame_count = -1
	local function get_from_buffer(frame_count)
		if last_buffer_frame_count < frame_count then
			last_buffer = t_sample_array(frame_count * from_channels)
			last_buffer_frame_count = frame_count
		end
		return last_buffer
	end

	local from_hz = sample_source.sample_rate
	local to_hz = output.sample_rate

	local ref_in = ffi.new 'uint32_t[1]'
	local ref_out = ffi.new 'uint32_t[1]'
	function resampled_source:write(to_samples, to_frame_count)
		local from_frame_count = math.ceil( (to_frame_count * from_hz) / to_hz )
		local from_samples = get_from_buffer(from_frame_count)

		local write_result = sample_source:write(from_samples, from_frame_count)

		local from_end = from_samples + from_frame_count * from_channels
		local   to_end =   to_samples +   to_frame_count *   to_channels

		repeat
			ref_in[0] = (from_end - from_samples) / from_channels
			ref_out[0] = (to_end - to_samples) / to_channels
			local resample_result = otr.opustools_resampler_process_interleaved_float(
				resampler,
				from_samples,
				ref_in,
				to_samples,
				ref_out)
			if resample_result ~= 0 then
				-- TODO: better error handling
				error('resampling error')
			end
			from_samples = from_samples + ref_in[0] * from_channels
			to_samples = to_samples + ref_out[0] * to_channels
		until to_samples == to_end or from_samples == from_end
		return write_result
	end

	return resampled_source
end

return resampling
