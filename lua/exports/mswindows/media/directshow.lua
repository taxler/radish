
local ffi = require 'ffi'
local com = require 'exports.mswindows.com'

ffi.cdef [[

	typedef struct DMO_MEDIA_TYPE {
		GUID majortype;
		GUID subtype;
		bool32 bFixedSizeSamples;
		bool32 bTemporalCompression;
		uint32_t lSampleSize;
		GUID formattype;
		IUnknown* pUnk;
		uint32_t cbFormat; // size of pbFormat
		uint8_t* pbFormat;
	} DMO_MEDIA_TYPE;

]]

com.def {
	{"IMediaObject";
		iid = 'd8ad0f58-5494-4102-97c5-ec798e59bcf4';
		methods = {
			{'GetStreamCount', 'uint32_t* out_input_count, uint32_t* out_output_count'};
			{'GetInputStreamInfo', 'uint32_t input_i, uint32_t* out_flags'};
			{'GetOutputStreamInfo', 'uint32_t output_i, uint32_t* out_flags'};
			-- Get(*)Type: returns 1 (S_FALSE) on out-of-range
			{'GetInputType', 'uint32_t input_i, uint32_t type_i, DMO_MEDIA_TYPE* out_pmt'};
			{'GetOutputType', 'uint32_t output_i, uint32_t type_i, DMO_MEDIA_TYPE* out_pmt'};
			{'SetInputType', 'uint32_t input_i, const DMO_MEDIA_TYPE*, uint32_t flags'};
			{'SetOutputType', 'uint32_t input_i, const DMO_MEDIA_TYPE*, uint32_t flags'};
			-- Get(*)CurrentType: returns 1 (S_FALSE) if SetType not called
			{'GetInputCurrentType', 'uint32_t input_i, DMO_MEDIA_TYPE* out_pmt'};
			{'GetOutputCurrentType', 'uint32_t input_i, DMO_MEDIA_TYPE* out_pmt'};
			{'GetInputSizeInfo', [[
				uint32_t input_i,
				uint32_t* out_quantum_size,
				uint32_t* out_max_lookahead,
				uint32_t* out_buffer_alignment]]};
			{'GetOutputSizeInfo', [[
				uint32_t output_i,
				uint32_t* out_quantum_size,
				uint32_t* out_buffer_alignment]]};
			{'GetInputMaxLatency', 'uint32_t input_i, int64_t* out_max_latency'};
			{'SetInputMaxLatency', 'uint32_t input_t, int64_t max_latency'};
			{'Flush'};
			{'Discontinuity', 'uint32_t input_i'};
			{'AllocateStreamingResources'};
			{'FreeStreamingResources'};
			{'GetInputStatus', 'uint32_t input_i, uint32_t* out_flags'};
			{'ProcessInput', [[
				uint32_t input_i,
				IMediaBuffer*, /* not null */
				uint32_t flags, /* DMO_INPUT_DATA_BUFFERF_XXX */
				int64_t timestamp, /* valid if flag set */
				int64_t time_length /* valid if flag set */ ]]};
			{'ProcessOutput', [[
				uint32_t flags, // DMO_PROCESS_OUTPUT_FLAGS
				uint32_t buffer_count, // returned by GetStreamCount()
				DMO_OUTPUT_DATA_BUFFER* buffers, /* one per stream */
				uint32_t must_be_zero]]};
			{'Lock', 'int32_t block'}; -- 1 for true, 0 for false
		};
	};
}
