
local ffi = require 'ffi'

local success, lib = pcall( ffi.load, 'Mfplat' )

if not success then
	return false
end

local com = require 'exports.mswindows.com'
local guids = require 'exports.mswindows.guids'
require 'exports.mswindows.automation'

com.predef 'IMFSample'
com.predef 'IMFCollection'

ffi.cdef [[

	typedef struct MFT_INPUT_STREAM_INFO {
		int64_t hnsMaxLatency;
		uint32_t dwFlags;
		uint32_t cbSize;
		uint32_t cbMaxLookahead;
		uint32_t cbAlignment;
    } MFT_INPUT_STREAM_INFO;

	typedef struct MFT_OUTPUT_STREAM_INFO {
		uint32_t dwFlags;
		uint32_t cbSize;
		uint32_t cbAlignment;
	} MFT_OUTPUT_STREAM_INFO;

	typedef enum MF_ATTRIBUTE_TYPE {
		MF_ATTRIBUTE_UINT32     = VT_UI4,
		MF_ATTRIBUTE_UINT64     = VT_UI8,
		MF_ATTRIBUTE_DOUBLE     = VT_R8,
		MF_ATTRIBUTE_GUID       = VT_CLSID,
		MF_ATTRIBUTE_STRING     = VT_LPWSTR,
		MF_ATTRIBUTE_BLOB       = VT_VECTOR | VT_UI1,
		MF_ATTRIBUTE_IUNKNOWN   = VT_UNKNOWN
	} MF_ATTRIBUTE_TYPE;

	typedef enum MF_ATTRIBUTES_MATCH_TYPE {
		MF_ATTRIBUTES_MATCH_OUR_ITEMS      = 0,
		MF_ATTRIBUTES_MATCH_THEIR_ITEMS    = 1,
		MF_ATTRIBUTES_MATCH_ALL_ITEMS      = 2,
		MF_ATTRIBUTES_MATCH_INTERSECTION   = 3,
		MF_ATTRIBUTES_MATCH_SMALLER        = 4 
	} MF_ATTRIBUTES_MATCH_TYPE;

	typedef enum MFT_MESSAGE_TYPE {
		MFT_MESSAGE_COMMAND_FLUSH	= 0,
		MFT_MESSAGE_COMMAND_DRAIN	= 1,
		MFT_MESSAGE_SET_D3D_MANAGER	= 2,
		MFT_MESSAGE_DROP_SAMPLES	= 3,
		MFT_MESSAGE_NOTIFY_BEGIN_STREAMING	= 0x10000000,
		MFT_MESSAGE_NOTIFY_END_STREAMING	= 0x10000001,
		MFT_MESSAGE_NOTIFY_END_OF_STREAM	= 0x10000002,
		MFT_MESSAGE_NOTIFY_START_OF_STREAM	= 0x10000003,
		MFT_MESSAGE_COMMAND_MARKER	= 0x20000000
	} MFT_MESSAGE_TYPE;

	typedef struct MFT_OUTPUT_DATA_BUFFER {
		uint32_t dwStreamID;
		IMFSample* pSample;
		uint32_t dwStatus;
		IMFCollection* pEvents;
    } MFT_OUTPUT_DATA_BUFFER;

    enum {
    	MF_SOURCE_READER_FIRST_VIDEO_STREAM = 0xFFFFFFFC,
    	MF_SOURCE_READER_FIRST_AUDIO_STREAM = 0xFFFFFFFD,
    	MF_SOURCE_READER_ALL_STREAMS = 0xFFFFFFFE
	};

	typedef enum MFBYTESTREAM_SEEK_ORIGIN {
		msoBegin,
		msoCurrent
	} MFBYTESTREAM_SEEK_ORIGIN;

	enum {
		MF_MEDIATYPE_EQUAL_MAJOR_TYPES = 1,
		MF_MEDIATYPE_EQUAL_FORMAT_TYPES = 2,
		MF_MEDIATYPE_EQUAL_FORMAT_DATA = 4,
		MF_MEDIATYPE_EQUAL_FORMAT_USER_DATA = 8
	};

]]

com.def {
	{'IMFTransform';
		iid = 'bf94c121-5b05-4e6f-8000-ba598961414d';
		methods = {
			{'GetStreamLimits', [[
				uint32_t* out_input_min,
				uint32_t* out_input_max,
				uint32_t* out_output_min,
				uint32_t* out_output_max]]};
			{'GetStreamCount', 'uint32_t* out_input_count, uint32_t* out_output_count'};
			{'GetStreamIDs', 'uint32_t* out_input_ids, uint32_t* out_ouput_ids'};
			{'GetInputStreamInfo', 'uint32_t input_i, MFT_INPUT_STREAM_INFO* out_info'};
			{'GetOutputStreamInfo', 'uint32_t output_i, MFT_OUTPUT_STREAM_INFO* out_info'};
			{'GetAttributes', 'IMFAttributes** out_attributes'};
			{'GetInputStreamAttributes', 'uint32_t input_id, IMFAttributes** out_attributes'};
			{'GetOutputStreamAttributes', 'uint32_t output_id, IMFAttributes** out_attributes'};
			{'DeleteInputStream', 'uint32_t stream_id'};
			{'AddInputStreams', 'uint32_t count, uint32_t* stream_ids'};
			{'GetInputAvailableType', 'uint32_t input_id, uint32_t type_i, IMFMediaType** out_type'};
			{'GetOutputAvailableType', 'uint32_t output_id, uint32_t type_i, IMFMediaType** out_type'};
			{'SetInputType', 'uint32_t input_id, IMFMediaType*, uint32_t flags'};
			{'SetOutputType', 'uint32_t output_id, IMFMediaType*, uint32_t flags'};
			{'GetInputCurrentType', 'uint32_t input_id, IMFMediaType** out_type'};
			{'GetOutputCurrentType', 'uint32_t output_id, IMFMediaType** out_type'};
			{'GetInputStatus', 'uint32_t input_id, uint32_t* out_flags'};
			{'GetOutputStatus', 'uint32_t* out_flags'};
			{'SetOutputBounds', 'int64_t lower_bound, int64_t upper_bound'};
			{'ProcessEvent', 'uint32_t input_id', 'IMFMediaEvent*'};
			{'ProcessMessage', 'MFT_MESSAGE_TYPE, uintptr_t param'};
			{'ProcessInput', 'uint32_t input_id, IMFSample*, uint32_t flags'};
			{'ProcessOutput', [[
				uint32_t flags,
				uint32_t output_buffer_count,
				MFT_OUTPUT_DATA_BUFFER* output_samples,
				uint32_t* out_status]]};
		};
	};
	{'IMFAttributes';
		iid = '2cd2d921-c447-44a7-a13c-4adabfc247e3';
		methods = {
			{'GetItem', 'const GUID* key, PROPVARIANT* out_value'};
			{'GetItemType', 'const GUID* key, MF_ATTRIBUTE_TYPE* out_type'};
			{'CompareItem', 'const GUID* key, const PROPVARIANT* value, bool32* out_comparison'};
			{'Compare', 'IMFAttributes* theirs, MF_ATTRIBUTES_MATCH_TYPE, bool32* out_comparison'};
			{'GetUINT32', 'const GUID* key, uint32_t* out_value'};
			{'GetUINT64', 'const GUID* key, uint64_t* out_value'};
			{'GetDouble', 'const GUID* key, double* out_value'};
			{'GetGUID', 'const GUID* key, GUID* out_guid'};
			{'GetStringLength', 'const GUID* key, uint32_t* out_length'};
			{'GetString', 'const GUID* key, wchar_t* out_buf, uint32_t buf_size, uint32_t* out_length'};
			{'GetAllocatedString', 'const GUID* key, wchar_t** out_string, uint32_t* out_length'}; -- use CoTaskMemFree
			{'GetBlobSize', 'const GUID* key, uint32_t* out_size'};
			{'GetBlob', 'const GUID* key, uint8_t* out_buf, uint32_t buf_size, uint32_t* out_size'};
			{'GetAllocatedBlob', 'const GUID* key, uint32_t** out_blob, uint32_t* out_size'}; -- use CoTaskMemFree
			{'GetUnknown', 'const GUID* key, const GUID* iid, void** out_object'};
			{'SetItem', 'const GUID* key, const PROPVARIANT*'};
			{'DeleteItem', 'const GUID* key'};
			{'DeleteAllItems'};
			{'SetUINT32', 'const GUID* key, uint32_t value'};
			{'SetUINT64', 'const GUID* key, uint64_t value'};
			{'SetDouble', 'const GUID* key, double value'};
			{'SetGUID', 'const GUID* key, const GUID*'};
			{'SetString', 'const GUID* key, const wchar_t*'};
			{'SetBlob', 'const GUID* key, const uint8_t* blob, uint32_t blob_size'};
			{'SetUnknown', 'const GUID* key, IUnknown*'};
			{'LockStore'};
			{'UnlockStore'};
			{'GetCount', 'uint32_t* out_count'};
			{'GetItemAtIndex', 'uint32_t i, GUID* out_key, PROPVARIANT* out_value'};
			{'CopyAllItems', 'IMFAttributes* destination'};
		};
	};
	{'IMFMediaType', inherits='IMFAttributes';
		iid = '44ae0fa8-ea31-4109-8d2e-4cae4997c555';
		methods = {
			{'GetMajorType', 'GUID* out_guid'};
			{'IsCompressedFormat', 'bool32* out_compressed'};
			{'IsEqual', 'IMFMediaType*, uint32_t* out_flags'};
			{'GetRepresentation', 'GUID, void** out_representation'};
			{'FreeRepresentation', 'GUID, void* representation'};
		};
	};
	{'IMFMediaEvent', inherits='IMFAttributes';
		iid = 'df598932-f10c-4e39-bba2-c308f101daa3';
		methods = {
			{'GetType', 'uint32_t* out_type'};
			{'GetExtendedType', 'GUID* out_type_guid'};
			{'GetStatus', 'int32_t* out_hresult'};
			{'GetValue', 'PROPVARIANT* out_value'};
		};
	};
	{'IMFSample', inherits='IMFAttributes';
		iid = 'c40a00f2-b93a-4d80-ae8c-5a1c634f58e4';
		methods = {
			{'GetSampleFlags', 'uint32_t* out_flags'};
			{'SetSampleFlags', 'uint32_t flags'};
			{'GetSampleTime', 'int64_t* out_time'};
			{'SetSampleTime', 'int64_t time'};
			{'GetSampleDuration', 'int64_t* out_duration'};
			{'SetSampleDuration', 'int64_t duration'};
			{'GetBufferCount', 'uint32_t* out_count'};
			{'GetBufferByIndex', 'uint32_t index, IMFMediaBuffer** out_buffer'};
			{'ConvertToContiguousBuffer', 'IMFMediaBuffer** out_buffer'};
			{'AddBuffer', 'IMFMediaBuffer*'};
			{'RemoveBufferByIndex', 'uint32_t index'};
			{'RemoveAllBuffers'};
			{'GetTotalLength', 'uint32_t* out_length'};
			{'CopyToBuffer', 'IMFMediaBuffer*'};
		};
	};
	{'IMFMediaBuffer';
		iid = '045fa593-8799-42b8-bc8d-8968c6453507';
		methods = {
			{'Lock', 'uint8_t** out_buffer, uint32_t* out_max_length, uint32_t* out_current_length'};
			{'Unlock'};
			{'GetCurrentLength', 'uint32_t* out_length'};
			{'SetCurrentLength', 'uint32_t length'};
			{'GetMaxLength', 'uint32_t* out_length'};
		};
	};
	{'IMFCollection';
		iid = '5bc8a76b-869a-46a3-9b03-fa218a66aebe';
		methods = {
			{'GetElementCount', 'uint32_t* out_elements'};
			{'GetElement', 'uint32_t index, IUnknown** out_element'};
			{'AddElement', 'IUnknown* element'};
			{'RemoveElement', 'uint32_t index, IUnknown** out_element'};
			{'InsertElementAt', 'uint32_t index, IUnknown* element'};
			{'RemoveAllElements'};
		};
	};
	{'IMFSourceReader';
		iid = '70ae66f2-c809-4e4f-8915-bdcb406b7993';
		methods = {
			{'GetStreamSelection', 'uint32_t stream_i, bool32* out_selected'};
			{'SetStreamSelection', 'uint32_t stream_i, bool32 selected'};
			{'GetNativeMediaType', 'uint32_t stream_i, uint32_t mediatype_i, IMFMediaType** out_type'};
			{'GetCurrentMediaType', 'uint32_t stream_i, IMFMediaType** out_type'};
			{'SetCurrentMediaType', 'uint32_t stream_i, uint32_t* reserved, IMFMediaType*'};
			{'SetCurrentPosition', 'const GUID* time_format_guid, const PROPVARIANT* position'};
			{'ReadSample', [[
				uint32_t stream_i,
				uint32_t control_flags,
				uint32_t* out_actual_stream_i,
				uint32_t* out_stream_flags,
				int64_t* out_timestamp,
				IMFSample** out_sample]]};
			{'Flush', 'uint32_t stream_i'};
			{'GetServiceForStream', [[
				uint32_t stream_i,
				const GUID* service_guid,
				const GUID* iid,
				void** out_object]]};
			{'GetPresentationAttribute', [[
				uint32_t stream_i,
				const GUID* attribute_guid,
				PROPVARIANT* out_value]]};
    	};
	};
	{'IMFByteStream';
		iid = 'ad4c1b00-4bf7-422f-9175-756693d9130d';
		methods = {
			{'GetCapabilities', 'uint32_t* out_caps'};
			{'GetLength', 'uint64_t* out_length'};
			{'SetLength', 'uint64_t length'};
			{'GetCurrentPosition', 'uint64_t* out_pos'};
			{'SetCurrentPosition', 'uint64_t pos'};
			{'IsEndOfStream', 'bool32* out_ended'};
			{'Read', 'uint8_t* buf, uint32_t buf_size, uint32_t* out_actual_read'};
			{'BeginRead', 'uint8_t* buf, uint32_t buf_size, IMFAsyncCallback*, IUnknown* state'};
			{'EndRead', 'IMFAsyncResult*, uint32_t* out_read'};
			{'Write', 'const uint8_t* buf, uint32_t buf_size, uint32_t* out_actual_written'};
			{'BeginWrite', 'const uint8_t* buf, uint32_t buf_size, IMFAsyncCallback*, IUnknown* state'};
			{'EndWrite', 'IMFAsyncResult* result, uint32_t* out_written'};
			{'Seek', 'MFBYTESTREAM_SEEK_ORIGIN, int64_t offset, uint32_t flags, uint64_t* out_pos'};
			{'Flush'};
			{'Close'};
		};
	};
	{'IMFAsyncResult';
		iid = 'ac6b7889-0740-4d51-8619-905994a55cc6';
		methods = {
			{'GetState', 'IUnknown** out_state'};
			{'GetStatus'};
			{'SetStatus', 'int32_t hresult'};
			{'GetObject', 'IUnknown** out_object'};
			{'GetStateNoAddRef', ret='IUnknown*'};
		};
	};
	{'IMFAsyncCallback';
		iid = 'a27003cf-2354-4f2a-8d6a-ab7cff15437e';
		methods = {
			{'GetParameters', 'uint32_t* out_flags, uint32_t* out_queue'};
			{'Invoke', 'IMFAsyncResult*'};
		};
	};
}

ffi.cdef [[

	enum {
		MF_SDK_VERSION__VISTA    = 0x0001,
		MF_SDK_VERSION__WINDOWS7 = 0x0002,

		MF_API_VERSION__VISTA    = 0x0070,
		MF_API_VERSION__WINDOWS7 = MF_API_VERSION__VISTA, // seems to be unused after Vista

		MF_VERSION__VISTA    = (MF_SDK_VERSION__VISTA    << 16) | MF_API_VERSION__VISTA,
		MF_VERSION__WINDOWS7 = (MF_SDK_VERSION__WINDOWS7 << 16) | MF_API_VERSION__WINDOWS7,

		MF_SDK_VERSION = MF_SDK_VERSION__WINDOWS7,
		MF_VERSION     = MF_VERSION__WINDOWS7,

		MFSTARTUP_FULL     = 0,
		MFSTARTUP_NOSOCKET = 1,
		MFSTARTUP_LITE     = MFSTARTUP_NOSOCKET
	};

	int32_t MFStartup(uint32_t version, uint32_t flags);
	int32_t MFShutdown();

	int32_t MFCreateMemoryBuffer(uint32_t max_length, IMFMediaBuffer** out_buffer);
	int32_t MFCreateMediaType(IMFMediaType** out_media_type);

	int32_t MFCreateMFByteStreamOnStream(IStream*, IMFByteStream** out_imfstream);

]]

require 'exports.mswindows.errors' {
	MF_E_PLATFORM_NOT_INITIALIZED    = 0xC00D36B0;
	MF_E_BUFFERTOOSMALL              = 0xC00D36B1;
	MF_E_INVALIDREQUEST              = 0xC00D36B2;
	MF_E_INVALIDSTREAMNUMBER         = 0xC00D36B3;
	MF_E_INVALIDMEDIATYPE            = 0xC00D36B4;
	MF_E_NOTACCEPTING                = 0xC00D36B5;
	MF_E_NOT_INITIALIZED             = 0xC00D36B6;
	MF_E_UNSUPPORTED_REPRESENTATION  = 0xC00D36B7;
	MF_E_NO_MORE_TYPES               = 0xC00D36B9;
	MF_E_UNSUPPORTED_SERVICE         = 0xC00D36BA;
	MF_E_UNEXPECTED                  = 0xC00D36BB;
	MF_E_INVALIDNAME                 = 0xC00D36BC;
	MF_E_INVALIDTYPE                 = 0xC00D36BD;
	MF_E_INVALID_FILE_FORMAT         = 0xC00D36BE;
	MF_E_INVALIDINDEX                = 0xC00D36BF;
	MF_E_INVALID_TIMESTAMP           = 0xC00D36C0;
	MF_E_UNSUPPORTED_SCHEME          = 0xC00D36C3;
	MF_E_UNSUPPORTED_BYTESTREAM_TYPE = 0xC00D36C4;
	MF_E_UNSUPPORTED_TIME_FORMAT     = 0xC00D36C5;
	MF_E_NO_SAMPLE_TIMESTAMP         = 0xC00D36C8;
	MF_E_NO_SAMPLE_DURATION          = 0xC00D36C9;
	MF_E_INVALID_STREAM_DATA         = 0xC00D36CB;
	MF_E_RT_UNAVAILABLE              = 0xC00D36CF;
	MF_E_UNSUPPORTED_RATE            = 0xC00D36D0;
	MF_E_THINNING_UNSUPPORTED        = 0xC00D36D1;
	MF_E_REVERSE_UNSUPPORTED         = 0xC00D36D2;
	MF_E_UNSUPPORTED_RATE_TRANSITION = 0xC00D36D3;
	MF_E_RATE_CHANGE_PREEMPTED       = 0xC00D36D4;
	MF_E_NOT_FOUND                   = 0xC00D36D5;
	MF_E_NOT_AVAILABLE               = 0xC00D36D6;
	MF_E_NO_CLOCK                    = 0xC00D36D7;
	MF_S_MULTIPLE_BEGIN              = 0x000D36D8;
	MF_E_MULTIPLE_BEGIN              = 0xC00D36D9;
	MF_E_MULTIPLE_SUBSCRIBERS        = 0xC00D36DA;
	MF_E_TIMER_ORPHANED              = 0xC00D36DB;
	MF_E_STATE_TRANSITION_PENDING    = 0xC00D36DC;
	MF_E_UNSUPPORTED_STATE_TRANSITION = 0xC00D36DD;
	MF_E_UNRECOVERABLE_ERROR_OCCURRED = 0xC00D36DE;
	MF_E_SAMPLE_HAS_TOO_MANY_BUFFERS = 0xC00D36DF;
	MF_E_SAMPLE_NOT_WRITABLE         = 0xC00D36E0;
	MF_E_INVALID_KEY                 = 0xC00D36E2;
	MF_E_BAD_STARTUP_VERSION         = 0xC00D36E3;
	MF_E_UNSUPPORTED_CAPTION         = 0xC00D36E4;
	MF_E_INVALID_POSITION            = 0xC00D36E5;
	MF_E_ATTRIBUTENOTFOUND           = 0xC00D36E6;
	MF_E_PROPERTY_TYPE_NOT_ALLOWED   = 0xC00D36E7;
	MF_E_PROPERTY_TYPE_NOT_SUPPORTED = 0xC00D36E8;
	MF_E_PROPERTY_EMPTY              = 0xC00D36E9;
	MF_E_PROPERTY_NOT_EMPTY          = 0xC00D36EA;
	MF_E_PROPERTY_VECTOR_NOT_ALLOWED = 0xC00D36EB;
	MF_E_PROPERTY_VECTOR_REQUIRED    = 0xC00D36EC;
	MF_E_OPERATION_CANCELLED         = 0xC00D36ED;
	MF_E_BYTESTREAM_NOT_SEEKABLE     = 0xC00D36EE;
	MF_E_DISABLED_IN_SAFEMODE        = 0xC00D36EF;
	MF_E_CANNOT_PARSE_BYTESTREAM     = 0xC00D36F0;
	MF_E_SOURCERESOLVER_MUTUALLY_EXCLUSIVE_FLAGS = 0xC00D36F1;
	MF_E_MEDIAPROC_WRONGSTATE        = 0xC00D36F2;
	MF_E_RT_THROUGHPUT_NOT_AVAILABLE = 0xC00D36F3;
	MF_E_RT_TOO_MANY_CLASSES         = 0xC00D36F4;
	MF_E_RT_WOULDBLOCK               = 0xC00D36F5;
	MF_E_NO_BITPUMP                  = 0xC00D36F6;
	MF_E_RT_OUTOFMEMORY              = 0xC00D36F7;
	MF_E_RT_WORKQUEUE_CLASS_NOT_SPECIFIED = 0xC00D36F8;
	MF_E_INSUFFICIENT_BUFFER         = 0xC00D7170;
	MF_E_CANNOT_CREATE_SINK          = 0xC00D36FA;
	MF_E_BYTESTREAM_UNKNOWN_LENGTH   = 0xC00D36FB;
	MF_E_SESSION_PAUSEWHILESTOPPED   = 0xC00D36FC;
	MF_S_ACTIVATE_REPLACED           = 0x000D36FD;
	MF_E_FORMAT_CHANGE_NOT_SUPPORTED = 0xC00D36FE;
	MF_E_INVALID_WORKQUEUE           = 0xC00D36FF;
	MF_E_DRM_UNSUPPORTED             = 0xC00D3700;
	MF_E_UNAUTHORIZED                = 0xC00D3701;
	MF_E_OUT_OF_RANGE                = 0xC00D3702;
	MF_E_INVALID_CODEC_MERIT         = 0xC00D3703;
	MF_E_HW_MFT_FAILED_START_STREAMING = 0xC00D3704;
	MF_S_ASF_PARSEINPROGRESS         = 0x400D3A98;
	MF_E_ASF_PARSINGINCOMPLETE       = 0xC00D3A98;
	MF_E_ASF_MISSINGDATA             = 0xC00D3A99;
	MF_E_ASF_INVALIDDATA             = 0xC00D3A9A;
	MF_E_ASF_OPAQUEPACKET            = 0xC00D3A9B;
	MF_E_ASF_NOINDEX                 = 0xC00D3A9C;
	MF_E_ASF_OUTOFRANGE              = 0xC00D3A9D;
	MF_E_ASF_INDEXNOTLOADED          = 0xC00D3A9E;    
	MF_E_ASF_TOO_MANY_PAYLOADS       = 0xC00D3A9F;    
	MF_E_ASF_UNSUPPORTED_STREAM_TYPE = 0xC00D3AA0;    
	MF_E_ASF_DROPPED_PACKET          = 0xC00D3AA1;    
	MF_E_NO_EVENTS_AVAILABLE         = 0xC00D3E80;
	MF_E_INVALID_STATE_TRANSITION    = 0xC00D3E82;
	MF_E_END_OF_STREAM               = 0xC00D3E84;
	MF_E_SHUTDOWN                    = 0xC00D3E85;
	MF_E_MP3_NOTFOUND                = 0xC00D3E86;
	MF_E_MP3_OUTOFDATA               = 0xC00D3E87;
	MF_E_MP3_NOTMP3                  = 0xC00D3E88;
	MF_E_MP3_NOTSUPPORTED            = 0xC00D3E89;
	MF_E_NO_DURATION                 = 0xC00D3E8A;
	MF_E_INVALID_FORMAT              = 0xC00D3E8C;
	MF_E_PROPERTY_NOT_FOUND          = 0xC00D3E8D;
	MF_E_PROPERTY_READ_ONLY          = 0xC00D3E8E;
	MF_E_PROPERTY_NOT_ALLOWED        = 0xC00D3E8F;
	MF_E_MEDIA_SOURCE_NOT_STARTED    = 0xC00D3E91;
	MF_E_UNSUPPORTED_FORMAT          = 0xC00D3E98;
	MF_E_MP3_BAD_CRC                 = 0xC00D3E99;
	MF_E_NOT_PROTECTED               = 0xC00D3E9A;
	MF_E_MEDIA_SOURCE_WRONGSTATE     = 0xC00D3E9B;
	MF_E_MEDIA_SOURCE_NO_STREAMS_SELECTED = 0xC00D3E9C;
	MF_E_CANNOT_FIND_KEYFRAME_SAMPLE = 0xC00D3E9D;
	MF_E_UNSUPPORTED_CHARACTERISTICS = 0xC00D3E9E;
	MF_E_NO_AUDIO_RECORDING_DEVICE   = 0xC00D3E9F;
	MF_E_AUDIO_RECORDING_DEVICE_IN_USE = 0xC00D3EA0;
	MF_E_AUDIO_RECORDING_DEVICE_INVALIDATED = 0xC00D3EA1;
	MF_E_VIDEO_RECORDING_DEVICE_INVALIDATED = 0xC00D3EA2;
	MF_E_VIDEO_RECORDING_DEVICE_PREEMPTED = 0xC00D3EA3;
	MF_E_NETWORK_RESOURCE_FAILURE    = 0xC00D4268;
	MF_E_NET_WRITE                   = 0xC00D4269;
	MF_E_NET_READ                    = 0xC00D426A;
	MF_E_NET_REQUIRE_NETWORK         = 0xC00D426B;
	MF_E_NET_REQUIRE_ASYNC           = 0xC00D426C;
	MF_E_NET_BWLEVEL_NOT_SUPPORTED   = 0xC00D426D;
	MF_E_NET_STREAMGROUPS_NOT_SUPPORTED = 0xC00D426E;
	MF_E_NET_MANUALSS_NOT_SUPPORTED  = 0xC00D426F;
	MF_E_NET_INVALID_PRESENTATION_DESCRIPTOR = 0xC00D4270;
	MF_E_NET_CACHESTREAM_NOT_FOUND   = 0xC00D4271;
	MF_I_MANUAL_PROXY                = 0x400D4272;
	MF_E_NET_REQUIRE_INPUT           = 0xC00D4274;
	MF_E_NET_REDIRECT                = 0xC00D4275;
	MF_E_NET_REDIRECT_TO_PROXY       = 0xC00D4276;
	MF_E_NET_TOO_MANY_REDIRECTS      = 0xC00D4277;
	MF_E_NET_TIMEOUT                 = 0xC00D4278;
	MF_E_NET_CLIENT_CLOSE            = 0xC00D4279;
	MF_E_NET_BAD_CONTROL_DATA        = 0xC00D427A;
	MF_E_NET_INCOMPATIBLE_SERVER     = 0xC00D427B;
	MF_E_NET_UNSAFE_URL              = 0xC00D427C;
	MF_E_NET_CACHE_NO_DATA           = 0xC00D427D;
	MF_E_NET_EOL                     = 0xC00D427E;
	MF_E_NET_BAD_REQUEST             = 0xC00D427F;
	MF_E_NET_INTERNAL_SERVER_ERROR   = 0xC00D4280;
	MF_E_NET_SESSION_NOT_FOUND       = 0xC00D4281;
	MF_E_NET_NOCONNECTION            = 0xC00D4282;
	MF_E_NET_CONNECTION_FAILURE      = 0xC00D4283;
	MF_E_NET_INCOMPATIBLE_PUSHSERVER = 0xC00D4284;
	MF_E_NET_SERVER_ACCESSDENIED     = 0xC00D4285;
	MF_E_NET_PROXY_ACCESSDENIED      = 0xC00D4286;
	MF_E_NET_CANNOTCONNECT           = 0xC00D4287;
	MF_E_NET_INVALID_PUSH_TEMPLATE   = 0xC00D4288;
	MF_E_NET_INVALID_PUSH_PUBLISHING_POINT = 0xC00D4289;
	MF_E_NET_BUSY                    = 0xC00D428A;
	MF_E_NET_RESOURCE_GONE           = 0xC00D428B;
	MF_E_NET_ERROR_FROM_PROXY        = 0xC00D428C;
	MF_E_NET_PROXY_TIMEOUT           = 0xC00D428D;
	MF_E_NET_SERVER_UNAVAILABLE      = 0xC00D428E;
	MF_E_NET_TOO_MUCH_DATA           = 0xC00D428F;
	MF_E_NET_SESSION_INVALID         = 0xC00D4290;
	MF_E_OFFLINE_MODE                = 0xC00D4291;
	MF_E_NET_UDP_BLOCKED             = 0xC00D4292;
	MF_E_NET_UNSUPPORTED_CONFIGURATION = 0xC00D4293;
	MF_E_NET_PROTOCOL_DISABLED       = 0xC00D4294;
	MF_E_ALREADY_INITIALIZED         = 0xC00D4650;
	MF_E_BANDWIDTH_OVERRUN           = 0xC00D4651;
	MF_E_LATE_SAMPLE                 = 0xC00D4652;
	MF_E_FLUSH_NEEDED                = 0xC00D4653;
	MF_E_INVALID_PROFILE             = 0xC00D4654;
	MF_E_INDEX_NOT_COMMITTED         = 0xC00D4655;
	MF_E_NO_INDEX                    = 0xC00D4656;
	MF_E_CANNOT_INDEX_IN_PLACE       = 0xC00D4657;
	MF_E_MISSING_ASF_LEAKYBUCKET     = 0xC00D4658;
	MF_E_INVALID_ASF_STREAMID        = 0xC00D4659;
	MF_E_STREAMSINK_REMOVED          = 0xC00D4A38;
	MF_E_STREAMSINKS_OUT_OF_SYNC     = 0xC00D4A3A;
	MF_E_STREAMSINKS_FIXED           = 0xC00D4A3B;
	MF_E_STREAMSINK_EXISTS           = 0xC00D4A3C;
	MF_E_SAMPLEALLOCATOR_CANCELED    = 0xC00D4A3D;
	MF_E_SAMPLEALLOCATOR_EMPTY       = 0xC00D4A3E;
	MF_E_SINK_ALREADYSTOPPED         = 0xC00D4A3F;
	MF_E_ASF_FILESINK_BITRATE_UNKNOWN = 0xC00D4A40;
	MF_E_SINK_NO_STREAMS             = 0xC00D4A41;
	MF_S_SINK_NOT_FINALIZED          = 0x000D4A42;
	MF_E_METADATA_TOO_LONG           = 0xC00D4A43;
	MF_E_SINK_NO_SAMPLES_PROCESSED   = 0xC00D4A44;
	MF_E_VIDEO_REN_NO_PROCAMP_HW     = 0xC00D4E20;
	MF_E_VIDEO_REN_NO_DEINTERLACE_HW = 0xC00D4E21;
	MF_E_VIDEO_REN_COPYPROT_FAILED   = 0xC00D4E22;
	MF_E_VIDEO_REN_SURFACE_NOT_SHARED = 0xC00D4E23;
	MF_E_VIDEO_DEVICE_LOCKED         = 0xC00D4E24;
	MF_E_NEW_VIDEO_DEVICE            = 0xC00D4E25;
	MF_E_NO_VIDEO_SAMPLE_AVAILABLE   = 0xC00D4E26;
	MF_E_NO_AUDIO_PLAYBACK_DEVICE    = 0xC00D4E84;
	MF_E_AUDIO_PLAYBACK_DEVICE_IN_USE = 0xC00D4E85;
	MF_E_AUDIO_PLAYBACK_DEVICE_INVALIDATED = 0xC00D4E86;
	MF_E_AUDIO_SERVICE_NOT_RUNNING   = 0xC00D4E87;
	MF_E_TOPO_INVALID_OPTIONAL_NODE  = 0xC00D520E;
	MF_E_TOPO_CANNOT_FIND_DECRYPTOR  = 0xC00D5211;
	MF_E_TOPO_CODEC_NOT_FOUND        = 0xC00D5212;
	MF_E_TOPO_CANNOT_CONNECT         = 0xC00D5213;
	MF_E_TOPO_UNSUPPORTED            = 0xC00D5214;
	MF_E_TOPO_INVALID_TIME_ATTRIBUTES = 0xC00D5215;
	MF_E_TOPO_LOOPS_IN_TOPOLOGY      = 0xC00D5216;
	MF_E_TOPO_MISSING_PRESENTATION_DESCRIPTOR = 0xC00D5217;
	MF_E_TOPO_MISSING_STREAM_DESCRIPTOR = 0xC00D5218;
	MF_E_TOPO_STREAM_DESCRIPTOR_NOT_SELECTED = 0xC00D5219;
	MF_E_TOPO_MISSING_SOURCE         = 0xC00D521A;
	MF_E_TOPO_SINK_ACTIVATES_UNSUPPORTED = 0xC00D521B;
	MF_E_SEQUENCER_UNKNOWN_SEGMENT_ID = 0xC00D61AC;
	MF_S_SEQUENCER_CONTEXT_CANCELED  = 0x000D61AD;
	MF_E_NO_SOURCE_IN_CACHE          = 0xC00D61AE;
	MF_S_SEQUENCER_SEGMENT_AT_END_OF_STREAM = 0x000D61AF;
	MF_E_TRANSFORM_TYPE_NOT_SET      = 0xC00D6D60;
	MF_E_TRANSFORM_STREAM_CHANGE     = 0xC00D6D61;
	MF_E_TRANSFORM_INPUT_REMAINING   = 0xC00D6D62;
	MF_E_TRANSFORM_PROFILE_MISSING   = 0xC00D6D63;
	MF_E_TRANSFORM_PROFILE_INVALID_OR_CORRUPT = 0xC00D6D64;
	MF_E_TRANSFORM_PROFILE_TRUNCATED = 0xC00D6D65;
	MF_E_TRANSFORM_PROPERTY_PID_NOT_RECOGNIZED = 0xC00D6D66;
	MF_E_TRANSFORM_PROPERTY_VARIANT_TYPE_WRONG = 0xC00D6D67;
	MF_E_TRANSFORM_PROPERTY_NOT_WRITEABLE = 0xC00D6D68;
	MF_E_TRANSFORM_PROPERTY_ARRAY_VALUE_WRONG_NUM_DIM = 0xC00D6D69;
	MF_E_TRANSFORM_PROPERTY_VALUE_SIZE_WRONG = 0xC00D6D6A;
	MF_E_TRANSFORM_PROPERTY_VALUE_OUT_OF_RANGE = 0xC00D6D6B;
	MF_E_TRANSFORM_PROPERTY_VALUE_INCOMPATIBLE = 0xC00D6D6C;
	MF_E_TRANSFORM_NOT_POSSIBLE_FOR_CURRENT_OUTPUT_MEDIATYPE = 0xC00D6D6D;
	MF_E_TRANSFORM_NOT_POSSIBLE_FOR_CURRENT_INPUT_MEDIATYPE = 0xC00D6D6E;
	MF_E_TRANSFORM_NOT_POSSIBLE_FOR_CURRENT_MEDIATYPE_COMBINATION = 0xC00D6D6F;
	MF_E_TRANSFORM_CONFLICTS_WITH_OTHER_CURRENTLY_ENABLED_FEATURES = 0xC00D6D70;
	MF_E_TRANSFORM_NEED_MORE_INPUT   = 0xC00D6D72;
	MF_E_TRANSFORM_NOT_POSSIBLE_FOR_CURRENT_SPKR_CONFIG = 0xC00D6D73;
	MF_E_TRANSFORM_CANNOT_CHANGE_MEDIATYPE_WHILE_PROCESSING = 0xC00D6D74;
	MF_S_TRANSFORM_DO_NOT_PROPAGATE_EVENT = 0x000D6D75;
	MF_E_UNSUPPORTED_D3D_TYPE        = 0xC00D6D76;
	MF_E_TRANSFORM_ASYNC_LOCKED      = 0xC00D6D77;
	MF_E_TRANSFORM_CANNOT_INITIALIZE_ACM_DRIVER = 0xC00D6D78;
	MF_E_LICENSE_INCORRECT_RIGHTS    = 0xC00D7148;
	MF_E_LICENSE_OUTOFDATE           = 0xC00D7149;
	MF_E_LICENSE_REQUIRED            = 0xC00D714A;
	MF_E_DRM_HARDWARE_INCONSISTENT   = 0xC00D714B;
	MF_E_NO_CONTENT_PROTECTION_MANAGER = 0xC00D714C;
	MF_E_LICENSE_RESTORE_NO_RIGHTS   = 0xC00D714D;
	MF_E_BACKUP_RESTRICTED_LICENSE   = 0xC00D714E;
	MF_E_LICENSE_RESTORE_NEEDS_INDIVIDUALIZATION = 0xC00D714F;
	MF_S_PROTECTION_NOT_REQUIRED     = 0x000D7150;
	MF_E_COMPONENT_REVOKED           = 0xC00D7151;
	MF_E_TRUST_DISABLED              = 0xC00D7152;
	MF_E_WMDRMOTA_NO_ACTION          = 0xC00D7153;
	MF_E_WMDRMOTA_ACTION_ALREADY_SET = 0xC00D7154;
	MF_E_WMDRMOTA_DRM_HEADER_NOT_AVAILABLE = 0xC00D7155;
	MF_E_WMDRMOTA_DRM_ENCRYPTION_SCHEME_NOT_SUPPORTED = 0xC00D7156;
	MF_E_WMDRMOTA_ACTION_MISMATCH    = 0xC00D7157;
	MF_E_WMDRMOTA_INVALID_POLICY     = 0xC00D7158;
	MF_E_POLICY_UNSUPPORTED          = 0xC00D7159;
	MF_E_OPL_NOT_SUPPORTED           = 0xC00D715A;
	MF_E_TOPOLOGY_VERIFICATION_FAILED = 0xC00D715B;
	MF_E_SIGNATURE_VERIFICATION_FAILED = 0xC00D715C;
	MF_E_DEBUGGING_NOT_ALLOWED       = 0xC00D715D;
	MF_E_CODE_EXPIRED                = 0xC00D715E;
	MF_E_GRL_VERSION_TOO_LOW         = 0xC00D715F;
	MF_E_GRL_RENEWAL_NOT_FOUND       = 0xC00D7160;
	MF_E_GRL_EXTENSIBLE_ENTRY_NOT_FOUND = 0xC00D7161;
	MF_E_KERNEL_UNTRUSTED            = 0xC00D7162;
	MF_E_PEAUTH_UNTRUSTED            = 0xC00D7163;
	MF_E_NON_PE_PROCESS              = 0xC00D7165;
	MF_E_REBOOT_REQUIRED             = 0xC00D7167;
	MF_S_WAIT_FOR_POLICY_SET         = 0x000D7168;
	MF_S_VIDEO_DISABLED_WITH_UNKNOWN_SOFTWARE_OUTPUT = 0x000D7169;
	MF_E_GRL_INVALID_FORMAT          = 0xC00D716A;
	MF_E_GRL_UNRECOGNIZED_FORMAT     = 0xC00D716B;
	MF_E_ALL_PROCESS_RESTART_REQUIRED = 0xC00D716C;
	MF_E_PROCESS_RESTART_REQUIRED    = 0xC00D716D;
	MF_E_USERMODE_UNTRUSTED          = 0xC00D716E;
	MF_E_PEAUTH_SESSION_NOT_STARTED  = 0xC00D716F;
	MF_E_PEAUTH_PUBLICKEY_REVOKED    = 0xC00D7171;
	MF_E_GRL_ABSENT                  = 0xC00D7172;
	MF_S_PE_TRUSTED                  = 0x000D7173;
	MF_E_PE_UNTRUSTED                = 0xC00D7174;
	MF_E_PEAUTH_NOT_STARTED          = 0xC00D7175;
	MF_E_INCOMPATIBLE_SAMPLE_PROTECTION = 0xC00D7176;
	MF_E_PE_SESSIONS_MAXED           = 0xC00D7177;
	MF_E_HIGH_SECURITY_LEVEL_CONTENT_NOT_ALLOWED = 0xC00D7178;
	MF_E_TEST_SIGNED_COMPONENTS_NOT_ALLOWED = 0xC00D7179;
	MF_E_ITA_UNSUPPORTED_ACTION      = 0xC00D717A;
	MF_E_ITA_ERROR_PARSING_SAP_PARAMETERS = 0xC00D717B;
	MF_E_POLICY_MGR_ACTION_OUTOFBOUNDS = 0xC00D717C;
	MF_E_BAD_OPL_STRUCTURE_FORMAT    = 0xC00D717D;
	MF_E_ITA_UNRECOGNIZED_ANALOG_VIDEO_PROTECTION_GUID = 0xC00D717E;
	MF_E_NO_PMP_HOST                 = 0xC00D717F;
	MF_E_ITA_OPL_DATA_NOT_INITIALIZED = 0xC00D7180;
	MF_E_ITA_UNRECOGNIZED_ANALOG_VIDEO_OUTPUT = 0xC00D7181;
	MF_E_ITA_UNRECOGNIZED_DIGITAL_VIDEO_OUTPUT = 0xC00D7182;
	MF_E_RESOLUTION_REQUIRES_PMP_CREATION_CALLBACK = 0xC00D7183;
	MF_E_INVALID_AKE_CHANNEL_PARAMETERS = 0xC00D7184;
	MF_E_CONTENT_PROTECTION_SYSTEM_NOT_ENABLED = 0xC00D7185;
	MF_E_UNSUPPORTED_CONTENT_PROTECTION_SYSTEM = 0xC00D7186;
	MF_E_DRM_MIGRATION_NOT_SUPPORTED = 0xC00D7187;
	MF_E_CLOCK_INVALID_CONTINUITY_KEY = 0xC00D9C40;
	MF_E_CLOCK_NO_TIME_SOURCE        = 0xC00D9C41;
	MF_E_CLOCK_STATE_ALREADY_SET     = 0xC00D9C42;
	MF_E_CLOCK_NOT_SIMPLE            = 0xC00D9C43;
	MF_S_CLOCK_STOPPED               = 0x000D9C44;
	MF_E_NO_MORE_DROP_MODES          = 0xC00DA028;
	MF_E_NO_MORE_QUALITY_LEVELS      = 0xC00DA029;
	MF_E_DROPTIME_NOT_SUPPORTED      = 0xC00DA02A;
	MF_E_QUALITYKNOB_WAIT_LONGER     = 0xC00DA02B;
	MF_E_QM_INVALIDSTATE             = 0xC00DA02C;
	MF_E_TRANSCODE_NO_CONTAINERTYPE  = 0xC00DA410;
	MF_E_TRANSCODE_PROFILE_NO_MATCHING_STREAMS = 0xC00DA411;
	MF_E_TRANSCODE_NO_MATCHING_ENCODER = 0xC00DA412;
	MF_E_TRANSCODE_INVALID_PROFILE   = 0xC00DA413;
	MF_E_ALLOCATOR_NOT_INITIALIZED   = 0xC00DA7F8;
	MF_E_ALLOCATOR_NOT_COMMITED      = 0xC00DA7F9;
	MF_E_ALLOCATOR_ALREADY_COMMITED  = 0xC00DA7FA;
	MF_E_STREAM_ERROR                = 0xC00DA7FB;
	MF_E_INVALID_STREAM_STATE        = 0xC00DA7FC;
	MF_E_HW_STREAM_NOT_CONNECTED     = 0xC00DA7FD;
	MF_E_NO_CAPTURE_DEVICES_AVAILABLE = 0xC00DABE0;
	MF_E_CAPTURE_SINK_OUTPUT_NOT_SET = 0xC00DABE1;
	MF_E_CAPTURE_SINK_MIRROR_ERROR   = 0xC00DABE2;
	MF_E_CAPTURE_SINK_ROTATE_ERROR   = 0xC00DABE3;
	MF_E_CAPTURE_ENGINE_INVALID_OP   = 0xC00DABE4;
	MF_E_CAPTURE_ENGINE_ALL_EFFECTS_REMOVED = 0xC00DABE5;
	MF_E_CAPTURE_SOURCE_NO_INDEPENDENT_PHOTO_STREAM_PRESENT = 0xC00DABE6;
	MF_E_CAPTURE_SOURCE_NO_VIDEO_STREAM_PRESENT = 0xC00DABE7;
	MF_E_CAPTURE_SOURCE_NO_AUDIO_STREAM_PRESENT = 0xC00DABE8;
}

return lib
