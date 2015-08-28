
local ffi = require 'ffi'
local com = require 'exports.mswindows.com'
local coreaudio = require 'exports.mswindows.media.coreaudio'
local mmd = require 'exports.mswindows.media.coreaudio.multimediadevice'
local mswin = require 'exports.mswindows'
local winstr = require 'exports.mswindows.strings'
local ole32 = require 'exports.mswindows.automation'
local winmedia = require 'exports.mswindows.media'
local winchecks = require 'exports.mswindows.checks'

local audio = {}

audio.device_enumerator = assert(com.new(
	mmd.enumerator_class_id,
	mmd.enumerator_interface_name))

audio.endpoint = assert(com.check_out('IMMDevice*', function(out_endpoint)
	return audio.device_enumerator:GetDefaultAudioEndpoint(
		coreaudio.eRender,
		coreaudio.eConsole,
		out_endpoint)
end))

audio.client = assert(com.check_out('IAudioClient*', function(out_client)
	return audio.endpoint:Activate(
		com.iidof 'IAudioClient',
		ole32.CLSCTX_ALL,
		nil,
		ffi.cast('void**', out_client))
end))

audio.mix_format = assert(winchecks.out('WAVEFORMATEX*', function(out_mix_format)
	-- TODO: handle AUDCLNT_E_DEVICE_INVALIDATED etc
	return audio.client:GetMixFormat(out_mix_format)
end))

if audio.mix_format.wFormatTag == winmedia.WAVE_FORMAT_EXTENSIBLE then
	audio.mix_format_extended = ffi.cast('WAVEFORMATEXTENSIBLE*', audio.mix_format)
end

audio.frame_bytes = audio.mix_format.nChannels * (audio.mix_format.wBitsPerSample / 8)

audio.device_period = assert(winchecks.out('int64_t', function(out_device_period)
	return audio.client:GetDevicePeriod(nil, out_device_period)
end))

audio.session_guid = nil

assert(winchecks.success(
	audio.client:Initialize(
		coreaudio.AUDCLNT_SHAREMODE_SHARED,
		coreaudio.AUDCLNT_STREAMFLAGS_EVENTCALLBACK,
		audio.device_period,
		0, -- always zero in non-exclusive mode
		audio.mix_format,
		audio.session_guid)
))

audio.event_handle = mswin.CreateEventW(nil, false, false, nil)

assert(audio.event_handle ~= nil, 'unable to create event')

assert(winchecks.success(
	audio.client:SetEventHandle(audio.event_handle)
))

audio.buffer_size = assert(winchecks.out('uint32_t', function(out_buffer_size)
	return audio.client:GetBufferSize(out_buffer_size)
end))

audio.render_client = assert(com.check_out('IAudioRenderClient*', function(out_render_client)
	return audio.client:GetService(com.iidof 'IAudioRenderClient', ffi.cast('void**', out_render_client))
end))

do
	local success, avrt = pcall( require, 'exports.mswindows.media.realtime' )
	if success then
		local out_index = ffi.new 'uint32_t[1]'
		local handle = avrt.AvSetMmThreadCharacteristicsW(winstr.wide 'Audio', out_index)
		if handle ~= nil then
			audio.realtime_task_handle = handle
			audio.realtime_task_index = out_index[0]
		end
	end
end

-- multimedia class scheduler: arvt.AvSetMmThreadCharacteristicsW("Audio", ...) ?

assert(winchecks.success(
	audio.client:Start()
))

return audio
