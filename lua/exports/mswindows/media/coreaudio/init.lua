
local ffi = require 'ffi'
local com = require 'exports.mswindows.com'
require 'exports.mswindows.automation'

ffi.cdef [[

	typedef enum {
	    eRender,
	    eCapture,
	    eAll
	} EDataFlow;

	typedef enum {
	    eConsole,
	    eMultimedia,
	    eCommunications
	} ERole;

	enum {
	    AUDCLNT_BUFFERFLAGS_DATA_DISCONTINUITY = 0x1,
	    AUDCLNT_BUFFERFLAGS_SILENT = 0x2,
	    AUDCLNT_BUFFERFLAGS_TIMESTAMP_ERROR = 0x4,

		AUDCLNT_STREAMFLAGS_CROSSPROCESS = 0x00010000,
		AUDCLNT_STREAMFLAGS_LOOPBACK = 0x00020000,
		AUDCLNT_STREAMFLAGS_EVENTCALLBACK = 0x00040000,
		AUDCLNT_STREAMFLAGS_NOPERSIST = 0x00080000,
		AUDCLNT_STREAMFLAGS_RATEADJUST = 0x00100000,
		AUDCLNT_STREAMFLAGS_AUTOCONVERTPCM = 0x80000000
	};

	typedef enum {
		AUDCLNT_SHAREMODE_SHARED,
		AUDCLNT_SHAREMODE_EXCLUSIVE
	} AUDCLNT_SHAREMODE;

	]]

com.def {
	{'IMMDeviceEnumerator';
		iid='a95664d2-9614-4f35-a746-de8db63617e6';
		methods = {
			{'EnumAudioEndpoints', 'EDataFlow, uint32_t state_mask, IMMDeviceCollection** out_collection'};
			{'GetDefaultAudioEndpoint', 'EDataFlow, ERole, IMMDevice** out_endpoint'};
			{'GetDevice', 'const wchar_t* id, IMMDevice** out_device'};
			{'RegisterEndpointNotificationCallback', 'IMMNotificationClient*'};
			{'UnregisterEndpointNotificationCallback', 'IMMNotificationClient*'};
		};
	};
	{'IMMDeviceCollection';
		iid='0bd7a1be-7a1a-44db-8397-cc5392387b5e';
		methods = {
			{'GetCount', 'uint32_t* out_count'};
			{'Item', 'uint32_t index, IMMDevice** out_device'};
		};
	};
	{'IMMDevice';
		iid='d666063f-1587-4e43-81f1-b948e807363f';
		methods = {
			{'Activate', 'const GUID* iid, uint32_t clsctx, PROPVARIANT* params, void** out_object'};
			{'OpenPropertyStore', 'uint32_t storage_access_mode, IPropertyStore** out_store'};
			{'GetId', 'wchar_t** out_name'}; -- free with CoTaskMemFree
			{'GetState', 'uint32_t* out_state'};
		};
	};
	{'IMMNotificationClient';
		methods = {
		    {'OnDeviceStateChanged', 'const wchar_t* device_id, uint32_t new_state'};
		    {'OnDeviceAdded', 'const wchar_t* device_id'};
		    {'OnDeviceRemoved', 'const wchar_t* device_id'};
		    {'OnDefaultDeviceChanged', 'EDataFlow, ERole, const wchar_t* device_id'};
		    {'OnPropertyValueChanged', 'const wchar_t* device_id, const PROPERTYKEY'};
		};
		iid = '7991eec9-7e89-4d85-8390-6c703cec60c0';
	};
	{'IAudioClient';
		--[[ use IMMDevice.Activate() ]]
		iid='1cb9ad4c-dbfa-4c32-b178-c2f568a703b2';
		methods = {
			{'Initialize', [[
				AUDCLNT_SHAREMODE,
				uint32_t stream_flags,
				int64_t buffer_duration,
				int64_t periodicity,
				const WAVEFORMATEX*,
				const GUID* audio_session_guid
			]]};
			{'GetBufferSize', [[uint32_t* out_buffer_frame_count]]};
			{'GetStreamLatency', 'int64_t* out_latency'};
			{'GetCurrentPadding', 'uint32_t* out_padding_frame_count'};
			{'IsFormatSupported',
				'AUDCLNT_SHAREMODE, const WAVEFORMATEX*, WAVEFORMATEX** out_closest_match'};
			{'GetMixFormat', 'WAVEFORMATEX** out_format'};
			{'GetDevicePeriod', [[
				int64_t* out_default_period,
				int64_t* out_minimum_period]]};
			{'Start'};
			{'Stop'};
			{'Reset'};
			{'SetEventHandle', 'void* handle'};
			{'GetService', 'const GUID* iid, void** out_service'};
		};
	};
	{'IAudioRenderClient';
		methods = {
			{'GetBuffer', 'uint32_t frames_requested, uint8_t** out_ptr'};
			{'ReleaseBuffer', 'uint32_t frames_written, uint32_t flags'};
		};
		iid='f294acfc-3146-4483-a7bf-addca7c260e2';
	};
	--IID_IAudioEndpointVolume
	--IID_IAudioMeterInformation
	--IID_IAudioSessionManager
	--IID_IAudioSessionManager2
	--IID_IBaseFilter
	--IID_IDeviceTopology
	--IID_IDirectSound
	--IID_IDirectSound8
	--IID_IDirectSoundCapture
	--IID_IDirectSoundCapture8
	--IID_IMFTrustedOutput
}

return ffi.C
