
local ffi = require 'ffi'

ffi.cdef [[

	enum {
		OPUSTOOLS_RESAMPLER_ERR_SUCCESS      = 0,
		OPUSTOOLS_RESAMPLER_ERR_ALLOC_FAILED = 1,
		OPUSTOOLS_RESAMPLER_ERR_BAD_STATE    = 2,
		OPUSTOOLS_RESAMPLER_ERR_INVALID_ARG  = 3,
		OPUSTOOLS_RESAMPLER_ERR_PTR_OVERLAP  = 4,
		OPUSTOOLS_RESAMPLER_ERR_MAX_ERROR,

		OPUSTOOLS_RESAMPLER_QUALITY_MAX     = 10,
		OPUSTOOLS_RESAMPLER_QUALITY_MIN     = 0,
		OPUSTOOLS_RESAMPLER_QUALITY_DEFAULT = 4,
		OPUSTOOLS_RESAMPLER_QUALITY_VOIP    = 3,
		OPUSTOOLS_RESAMPLER_QUALITY_DESKTOP = 5
	};

	typedef struct OpusToolsResamplerState OpusToolsResamplerState;

	OpusToolsResamplerState* opustools_resampler_init(
		uint32_t nb_channels,
		uint32_t input_rate,
		uint32_t output_rate,
		int quality, // 0 to 10, 10 is best
		int *err);
	OpusToolsResamplerState *opustools_resampler_init_frac(
		uint32_t nb_channels,
		uint32_t ratio_num,
		uint32_t ratio_den,
		uint32_t input_rate,
		uint32_t output_rate,
		int quality,
		int *err);
	void opustools_resampler_destroy(OpusToolsResamplerState*);
	int opustools_resampler_process_float(
		OpusToolsResamplerState*,
		uint32_t channel_index,
		const float* input,
		uint32_t* ref_input_len,
		float* output,
		uint32_t* ref_output_len);
	int opustools_resampler_process_int(
		OpusToolsResamplerState*,
		uint32_t channel_index,
		const int16_t* input,
		uint32_t* ref_input_len,
		int16_t* output,
		uint32_t* ref_output_len);
	int opustools_resampler_process_interleaved_float(
		OpusToolsResamplerState*,
		const float *input,
		uint32_t* ref_input_len,
		float* output,
		uint32_t* ref_output_len);
	int opustools_resampler_process_interleaved_int(
		OpusToolsResamplerState*,
		const int16_t* input,
		uint32_t* ref_input_len,
		int16_t* output,
		uint32_t* ref_output_len);
	int opustools_resampler_set_rate(OpusToolsResamplerState*, uint32_t input_rate, uint32_t output_rate);
	void opustools_resampler_get_rate(OpusToolsResamplerState*, uint32_t* out_input_rate, uint32_t* out_output_rate);
	int opustools_resampler_set_rate_frac(
		OpusToolsResamplerState*,
		uint32_t ratio_num,
		uint32_t ratio_den,
		uint32_t input_rate,
		uint32_t output_rate);
	void opustools_resampler_get_ratio(OpusToolsResamplerState*, uint32_t* out_ratio_num, uint32_t* out_ratio_den);
	int opustools_resampler_set_quality(OpusToolsResamplerState*, int quality);
	void opustools_resampler_get_quality(OpusToolsResamplerState*, int* out_quality);
	void opustools_resampler_set_input_stride(OpusToolsResamplerState*, uint32_t stride);
	void opustools_resampler_get_input_stride(OpusToolsResamplerState*, uint32_t* out_stride);
	void opustools_resampler_set_output_stride(OpusToolsResamplerState*, uint32_t stride);
	void opustools_resampler_get_output_stride(OpusToolsResamplerState*, uint32_t* out_stride);
	int opustools_resampler_get_input_latency(OpusToolsResamplerState*);
	int opustools_resampler_get_output_latency(OpusToolsResamplerState*);
	int opustools_resampler_skip_zeros(OpusToolsResamplerState*);
	int opustools_resampler_reset_mem(OpusToolsResamplerState*);
	const char* opustools_resampler_strerror(int err);

]]

return ffi.C
