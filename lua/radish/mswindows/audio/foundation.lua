-- audio functionality based on windows media foundation

local mfplat = require 'exports.mswindows.media.foundation'

if mfplat == false then
	return false
end

-- unfortunately we need the Windows 7 version just to be
-- able to open an IMFByteStream on an existing IStream
if 0 ~= mfplat.MFStartup(mfplat.MF_VERSION__WINDOWS7, mfplat.MFSTARTUP_LITE) then
	return false
end

local bit = require 'bit'
local ffi = require 'ffi'
local com = require 'exports.mswindows.com'

local mfreadwrite = require 'exports.mswindows.media.foundation.readwrite'
local mfattributes = require 'exports.mswindows.media.foundation.attributes'
local winerr = require 'exports.mswindows.errors'
local mfmtypes = require 'exports.mswindows.media.foundation.media_types'
local subtypes = require 'exports.mswindows.media.subtypes'
local mp3_decoder = require 'exports.mswindows.media.mp3_decoder'
local audio_resampler = require 'exports.mswindows.media.foundation.audio_resampler'

local audio_foundation = {}

function audio_foundation.make_source_reader_for_istream(istream)
	if istream == nil or not ffi.istype('IStream*', istream) then
		return nil, 'not passed an IStream*'
	end
	local out_reader = ffi.new 'IMFSourceReader*[1]'
	local create_reader_hresult do
		local imfstream do
			local out_imfstream = ffi.new 'IMFByteStream*[1]'
			if 0 ~= mfplat.MFCreateMFByteStreamOnStream(istream, out_imfstream) then
				return nil, 'failure to create IMFByteStream* from IStream*'
			end
			imfstream = com.gc( out_imfstream[0] )
		end
		create_reader_hresult = mfreadwrite.MFCreateSourceReaderFromByteStream(
			imfstream,
			attributes,
			out_reader)
		imfstream = com.release( imfstream )
	end
	if create_reader_hresult ~= 0 then
		return nil, 'failure to create IMFSourceReader* for IMFByteStream*'
	end
	return com.gc( out_reader[0] )
end

function audio_foundation.source_reader_get_media_type(reader)
	local out_media_type = ffi.new 'IMFMediaType*[1]'
	if 0 ~= reader:GetNativeMediaType(0, 0, out_media_type) then
		return nil, 'failure to get native media type for IMFSourceReader*'
	end
	return com.gc(out_media_type[0])
end

function audio_foundation.media_type_has_subtype(media_type, subtype_guid)
	local guid = ffi.new 'GUID'
	if 0 ~= media_type:GetGUID(mfattributes.MF_MT_SUBTYPE, guid) then
		return false
	end
	return guid == subtype_guid
end

function audio_foundation.make_mp3_decode_transform_for_source_reader(reader)
	local message = 'unknown error'
	local decoder, mtype

	decoder, message = com.new(mp3_decoder.class_id, 'IMFTransform')
	if decoder == nil then
		goto failed
	end

	mtype, message = audio_foundation.source_reader_get_media_type(reader)
	if mtype == nil then
		goto failed
	end

	if not audio_foundation.media_type_has_subtype(mtype, subtypes.MEDIASUBTYPE_MP3) then
		message = 'stream data is not MP3 audio'
		goto failed
	end

	if 0 ~= reader:SetCurrentMediaType(0, nil, mtype) then
		message = 'failure to SetCurrentMediaType on IMFSourceReader*'
		goto failed
	end

	if 0 ~= decoder:SetInputType(0, mtype, 0) then
		message = 'failure to SetInputType on mp3 decoder IMFTransform'
		goto failed
	end

	do -- success
		com.release( mtype )
		return decoder
	end

	::failed::
	com.release( decoder, mtype )
	return nil, message
end

function audio_foundation.audio_type_get_components(audio_type)
	local subtype_guid, channels, sample_rate, bits_per_sample
	subtype_guid = ffi.new 'GUID'
	if 0 ~= audio_type:GetGUID(mfattributes.MF_MT_SUBTYPE, subtype_guid) then
		subtype_guid = nil
	end
	local out_uint32 = ffi.new 'uint32_t[1]'
	if 0 == audio_type:GetUINT32(mfattributes.MF_MT_AUDIO_NUM_CHANNELS, out_uint32) then
		channels = out_uint32[0]
	end
	if 0 == audio_type:GetUINT32(mfattributes.MF_MT_AUDIO_SAMPLES_PER_SECOND, out_uint32) then
		sample_rate = out_uint32[0]
	end
	if 0 == audio_type:GetUINT32(mfattributes.MF_MT_AUDIO_BITS_PER_SAMPLE, out_uint32) then
		bits_per_sample = out_uint32[0]
	end
	return subtype_guid, channels, sample_rate, bits_per_sample
end

function audio_foundation.make_audio_type(subtype_guid, channels, sample_rate, bits_per_sample)
	local mtype do
		local out_mtype = ffi.new 'IMFMediaType*[1]'
		if 0 ~= mfplat.MFCreateMediaType(out_mtype) then
			return nil, 'failure to MFCreateMediaType'
		end
		mtype = com.gc( out_mtype[0] )
	end
	local set_guids = {
		MF_MT_MAJOR_TYPE = mfmtypes.MFMediaType_Audio;
		MF_MT_SUBTYPE = subtype_guid;
	}
	local set_uint32s = {
		MF_MT_AUDIO_NUM_CHANNELS = channels;
		MF_MT_AUDIO_SAMPLES_PER_SECOND = sample_rate;
		MF_MT_AUDIO_BLOCK_ALIGNMENT = channels * (bits_per_sample / 8);
		MF_MT_AUDIO_AVG_BYTES_PER_SECOND = channels * (bits_per_sample / 8) * sample_rate;
		MF_MT_AUDIO_BITS_PER_SAMPLE = bits_per_sample;
		MF_MT_ALL_SAMPLES_INDEPENDENT = true;
	}
	local message = 'unknown error'
	for attribute_name, value_guid in pairs(set_guids) do
		local attribute_guid = mfattributes[attribute_name]
		if type(attribute_guid) == 'nil' then
			message = 'unknown attribute ' .. attribute_name
			goto failed
		end
		if 0 ~= mtype:SetGUID(attribute_guid, value_guid) then
			message = 'unable to set GUID attribute ' .. attribute_name
			goto failed
		end
	end
	for attribute_name, value_uint32 in pairs(set_uint32s) do
		local attribute_guid = mfattributes[attribute_name]
		if type(attribute_guid) == 'nil' then
			message = 'unknown attribute ' .. attribute_name
			goto failed
		end
		if 0 ~= mtype:SetUINT32(attribute_guid, value_uint32) then
			message = 'unable to set UINT32 attribute ' .. attribute_name
			goto failed
		end
	end
	do -- success
		return mtype
	end
	::failed::
	com.release( mtype )
	return nil, message
end

function audio_foundation.transform_get_output_type_by_index(transform, index)
	local out_mtype = ffi.new 'IMFMediaType*[1]'
	if 0 ~= transform:GetOutputAvailableType(0, index, out_mtype) then
		return nil, 'out of range'
	end
	return com.gc( out_mtype[0] )
end

function audio_foundation.transform_find_nearest_output_type(transform,
		desired_subtype, desired_channels, desired_sample_rate, desired_bits_per_sample)
	local out_mtype = ffi.new 'IMFMediaType*[1]'
	-- initialize nearest with the first
	if 0 ~= transform:GetOutputAvailableType(0, 0, out_mtype) then
		return nil, 'no output types found at all'
	end
	local nearest = com.gc( out_mtype[0] )
	-- check for identical
	local nearest_subtype, nearest_channels, nearest_sample_rate, nearest_bits_per_sample
		= audio_foundation.audio_type_get_components(nearest)
	nearest = com.release( nearest )
	if desired_subtype == nearest_subtype and desired_channels == nearest_channels
	and desired_sample_rate == nearest_sample_rate and desired_bits_per_sample == nearest_bits_per_sample then
		return 0, true
	end
	-- loop setup
	local subtype_guid = ffi.new 'GUID'
	local out_uint32 = ffi.new 'uint32_t[1]'
	local i = 0
	local nearest_i = i
	-- loop
	while true do
		i = i + 1
		out_mtype[0] = nil
		if 0 ~= transform:GetOutputAvailableType(0, i, out_mtype) then
			if out_mtype[0] ~= nil then
				out_mtype[0]:Release()
			end
			break
		end
		local current = com.gc( out_mtype[0] )
		local current_subtype, current_channels, current_sample_rate, current_bits_per_sample
			= audio_foundation.audio_type_get_components(current)
		current = com.release(current)
		if desired_subtype == current_subtype and desired_channels == current_channels
		and desired_sample_rate == current_sample_rate and desired_bits_per_sample == current_bits_per_sample then
			return i, true
		end
		if (nearest_channels ~= desired_channels and current_channels == desired_channels)
		or (current_sample_rate * current_bits_per_sample) > (nearest_sample_rate * nearest_bits_per_sample) then
			nearest_i = i
			nearest_subtype, nearest_channels, nearest_sample_rate, nearest_bits_per_sample
			= current_subtype, current_channels, current_sample_rate, current_bits_per_sample
		end
	end
	return nearest_i, false
end

function audio_foundation.make_audio_resampler_transform(in_media_type, out_media_type)
	local message = 'unknown error'
	local resampler_base, resampler_transform, resampler_props
	local hresult
	
	resampler_base, message = com.new(audio_resampler.class_id)
	if resampler_base == nil then
		goto failed
	end

	resampler_props, message = com.cast('IWMResamplerProps', resampler_base)
	if resampler_props == nil then
		goto failed
	end

	if 0 ~= resampler_props:SetHalfFilterLength(60) then
		message = 'failed to SetHalfFilterLength on IWMResamplerProps'
		goto failed
	end

	resampler_transform, message = com.cast('IMFTransform', resampler_base)
	if resampler_transform == nil then
		goto failed
	end

	if 0 ~= resampler_transform:SetInputType(0, in_media_type, 0) then
		message = 'failed to SetInputType on IMFTransform'
		goto failed
	end

	hresult = resampler_transform:SetOutputType(0, out_media_type, 0)
	if 0 ~= hresult then
		message = 'failed to SetOutputType on IMFTransform: ' .. winerr[hresult]
		goto failed
	end

	do -- success
		com.release( resampler_base, resampler_props )
		return resampler_transform
	end
	::failed::
	com.release( resampler_base, resampler_transform, resampler_props )
	return nil, message
end

function audio_foundation.transform_set_output_type(transform, mtype)
	if 0 ~= transform:SetOutputType(0, mtype, 0) then
		return false, 'failed to SetOutputType on IMFTransform*'
	end
	return true
end

function audio_foundation.transform_start(transform)
	if 0 ~= transform:ProcessMessage(mfplat.MFT_MESSAGE_COMMAND_FLUSH, 0) then
		return false, 'MFT_MESSAGE_COMMAND_FLUSH failed'
	end
	if 0 ~= transform:ProcessMessage(mfplat.MFT_MESSAGE_NOTIFY_BEGIN_STREAMING, 0) then
		return false, 'MFT_MESSAGE_NOTIFY_BEGIN_STREAMING failed'
	end
	if 0 ~= transform:ProcessMessage(mfplat.MFT_MESSAGE_NOTIFY_START_OF_STREAM, 0) then
		return false, 'MFT_MESSAGE_NOTIFY_START_OF_STREAM failed'
	end
	return true
end

function audio_foundation.transform_stop(transform)
	if 0 ~= transform:ProcessMessage(mfplat.MFT_MESSAGE_NOTIFY_END_OF_STREAM, 0) then
		return false, 'MFT_MESSAGE_NOTIFY_END_OF_STREAM failed'
	end
	if 0 ~= transform:ProcessMessage(mfplat.MFT_MESSAGE_COMMAND_DRAIN, 0) then
		return false, 'MFT_MESSAGE_COMMAND_DRAIN failed'
	end
	-- we should check ProcessOutput... perhaps there is audio frame?
	return true
end

function audio_foundation.make_sample()
	local out_sample = ffi.new 'IMFSample*[1]'
	if 0 ~= mfplat.MFCreateSample(out_sample) then
		return nil, 'unable to create sample'
	end
	return com.gc( out_sample[0] )
end

function audio_foundation.make_buffer(size)
	local out_buffer = ffi.new 'IMFMediaBuffer*[1]'
	if 0 ~= mfplat.MFCreateMemoryBuffer(size, out_buffer) then
		return nil, 'failed to create memory buffer'
	end
	return com.gc( out_buffer[0] )
end

function audio_foundation.buffer_set_length(buffer, size)
	if 0 ~= buffer:SetCurrentLength(size) then
		return false, 'unable to set buffer length'
	end
	return true
end

function audio_foundation.sample_add_buffer(sample, buffer)
	if 0 ~= sample:AddBuffer(buffer) then
		return false, 'unable to add buffer to sample'
	end
	return true
end

function audio_foundation.make_sample_for_bytes(bytes_ptr, bytes_count)
	local message = 'unknown error'
	local out_locked, out_sample
	local buffer, sample

	buffer, message = audio_foundation.make_buffer(bytes_count)
	if buffer == nil then
		goto failed
	end

	out_locked = ffi.new 'uint8_t*[1]'
	if 0 ~= buffer:Lock(out_locked, nil, nil) then
		message = 'failed to lock memory buffer'
		goto failed
	end

	ffi.copy(out_locked[0], bytes_ptr, bytes_count)

	if 0 ~= buffer:Unlock() then
		message = 'failed to unlock memory buffer'
		goto failed
	end

	if 0 ~= buffer:SetCurrentLength(bytes_count) then
		message = 'failed to set memory buffer length'
		goto failed
	end

	out_sample = ffi.new 'IMFSample*[1]'
	if 0 ~= mfplay.MFCreateSample(out_sample) then
		message = 'failed to create sample'
		goto failed
	end
	sample = com.gc( out_sample[0] )

	if 0 ~= sample:AddBuffer(buffer) then
		message = 'failed to add buffer to sample'
		goto failed
	end

	do -- success
		com.release( buffer )
		return sample
	end
	::failed::
	com.release( buffer, sample )
	return nil, message
end

function audio_foundation.transform_process_input(transform, sample)
	local hr = transform:ProcessInput(0, sample, 0)
	if hr == 0 then
		return true
	end
	return false, 'failed to process sample'
end



return audio_foundation
