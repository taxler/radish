
local lib = require 'exports.dumb'

local ffi = require 'ffi'

ffi.cdef [[

	/*  _______         ____    __         ___    ___
	 * \    _  \       \    /  \  /       \   \  /   /       '   '  '
	 *  |  | \  \       |  |    ||         |   \/   |         .      .
	 *  |  |  |  |      |  |    ||         ||\  /|  |
	 *  |  |  |  |      |  |    ||         || \/ |  |         '  '  '
	 *  |  |  |  |      |  |    ||         ||    |  |         .      .
	 *  |  |_/  /        \  \__//          ||    |  |
	 * /_______/ynamic    \____/niversal  /__\  /____\usic   /|  .  . ibliotheque
	 *                                                      /  \
	 *                                                     / .  \
	 * dumb.h - The user header file for DUMB.            / / \  \
	 *                                                   | <  /   \_
	 * Include this file in any of your files in         |  \/ /\   /
	 * which you wish to use the DUMB functions           \_  /  > /
	 * and variables.                                       | \ / /
	 *                                                      |  ' /
	 * Allegro users, you will probably want aldumb.h.       \__/
	 */

	enum {
		DUMB_RQ_ALIASING = 0,
		DUMB_RQ_BLEP     = 1,
		DUMB_RQ_LINEAR   = 2,
		DUMB_RQ_BLAM     = 3,
		DUMB_RQ_CUBIC    = 4,
		DUMB_RQ_FIR      = 5,
		DUMB_RQ_N_LEVELS = 6
	};

	typedef struct DUMB_RESAMPLER DUMB_RESAMPLER;

	typedef void (*DUMB_RESAMPLE_PICKUP)(DUMB_RESAMPLER*, void* data);

	typedef struct DUMB_RESAMPLER {
		void* src;
		long pos;
		int subpos;
		long start, end;
		int dir;
		DUMB_RESAMPLE_PICKUP pickup;
		void* pickup_data;
		int quality;

		/* Everything below this point is internal: do not use. */
		union {
			int x24[3 * 2];
			short x16[3 * 2];
			signed char x8[3 * 2];
		} x;
		int overshot;
	    double fir_resampler_ratio;
	    void* fir_resampler[2];
	} DUMB_RESAMPLER;

	typedef struct DUMB_VOLUME_RAMP_INFO {
		float volume;
		float delta;
		float target;
		float mix;
	    unsigned char declick_stage;
	} DUMB_VOLUME_RAMP_INFO;

	extern int dumb_resampling_quality;

	void dumb_reset_resampler(DUMB_RESAMPLER*,
		int* src,
		int src_channels,
		long pos,
		long start,
		long end,
		int quality);
	DUMB_RESAMPLER* dumb_start_resampler(
		int* src,
		int src_channels,
		long pos,
		long start,
		long end,
		int quality);
	long dumb_resample_1_1(DUMB_RESAMPLER*,
		int* dst,
		long dst_size,
		DUMB_VOLUME_RAMP_INFO* volume,
		float delta);
	long dumb_resample_1_2(DUMB_RESAMPLER*,
		int* dst,
		long dst_size,
		DUMB_VOLUME_RAMP_INFO* volume_left,
		DUMB_VOLUME_RAMP_INFO* volume_right,
		float delta);
	long dumb_resample_2_1(DUMB_RESAMPLER*,
		int* dst,
		long dst_size,
		DUMB_VOLUME_RAMP_INFO* volume_left,
		DUMB_VOLUME_RAMP_INFO* volume_right,
		float delta);
	long dumb_resample_2_2(DUMB_RESAMPLER*,
		int* dst,
		long dst_size,
		DUMB_VOLUME_RAMP_INFO* volume_left,
		DUMB_VOLUME_RAMP_INFO* volume_right,
		float delta);
	void dumb_resample_get_current_sample_1_1(DUMB_RESAMPLER*,
		DUMB_VOLUME_RAMP_INFO* volume,
		int* dst);
	void dumb_resample_get_current_sample_1_2(DUMB_RESAMPLER*,
		DUMB_VOLUME_RAMP_INFO* volume_left,
		DUMB_VOLUME_RAMP_INFO* volume_right,
		int* dst);
	void dumb_resample_get_current_sample_2_1(DUMB_RESAMPLER*,
		DUMB_VOLUME_RAMP_INFO* volume_left,
		DUMB_VOLUME_RAMP_INFO* volume_right,
		int* dst);
	void dumb_resample_get_current_sample_2_2(DUMB_RESAMPLER*,
		DUMB_VOLUME_RAMP_INFO* volume_left,
		DUMB_VOLUME_RAMP_INFO* volume_right,
		int* dst);
	void dumb_end_resampler(DUMB_RESAMPLER*);

	void dumb_reset_resampler_16(DUMB_RESAMPLER*,
		short* src,
		int src_channels,
		long pos,
		long start,
		long end,
		int quality);
	DUMB_RESAMPLER* dumb_start_resampler_16(
		short* src,
		int src_channels,
		long pos,
		long start,
		long end,
		int quality);
	long dumb_resample_16_1_1(DUMB_RESAMPLER*,
		int* dst,
		long dst_size,
		DUMB_VOLUME_RAMP_INFO* volume,
		float delta);
	long dumb_resample_16_1_2(DUMB_RESAMPLER*,
		int* dst,
		long dst_size,
		DUMB_VOLUME_RAMP_INFO* volume_left,
		DUMB_VOLUME_RAMP_INFO* volume_right,
		float delta);
	long dumb_resample_16_2_1(DUMB_RESAMPLER*,
		int* dst,
		long dst_size,
		DUMB_VOLUME_RAMP_INFO* volume_left,
		DUMB_VOLUME_RAMP_INFO* volume_right,
		float delta);
	long dumb_resample_16_2_2(DUMB_RESAMPLER*,
		int* dst,
		long dst_size,
		DUMB_VOLUME_RAMP_INFO* volume_left,
		DUMB_VOLUME_RAMP_INFO* volume_right,
		float delta);
	void dumb_resample_get_current_sample_16_1_1(DUMB_RESAMPLER*,
		DUMB_VOLUME_RAMP_INFO* volume,
		int* dst);
	void dumb_resample_get_current_sample_16_1_2(DUMB_RESAMPLER*,
		DUMB_VOLUME_RAMP_INFO* volume_left,
		DUMB_VOLUME_RAMP_INFO* volume_right,
		int* dst);
	void dumb_resample_get_current_sample_16_2_1(DUMB_RESAMPLER*,
		DUMB_VOLUME_RAMP_INFO* volume_left,
		DUMB_VOLUME_RAMP_INFO* volume_right,
		int* dst);
	void dumb_resample_get_current_sample_16_2_2(DUMB_RESAMPLER*,
		DUMB_VOLUME_RAMP_INFO* volume_left,
		DUMB_VOLUME_RAMP_INFO* volume_right,
		int* dst);
	void dumb_end_resampler_16(DUMB_RESAMPLER*);

	void dumb_reset_resampler_8(DUMB_RESAMPLER*,
		signed char* src,
		int src_channels,
		long pos,
		long start,
		long end,
		int quality);
	DUMB_RESAMPLER* dumb_start_resampler_8(
		signed char* src,
		int src_channels,
		long pos,
		long start,
		long end,
		int quality);
	long dumb_resample_8_1_1(DUMB_RESAMPLER*,
		int* dst,
		long dst_size,
		DUMB_VOLUME_RAMP_INFO* volume,
		float delta);
	long dumb_resample_8_1_2(DUMB_RESAMPLER*,
		int* dst,
		long dst_size,
		DUMB_VOLUME_RAMP_INFO* volume_left,
		DUMB_VOLUME_RAMP_INFO* volume_right,
		float delta);
	long dumb_resample_8_2_1(DUMB_RESAMPLER*,
		int* dst,
		long dst_size,
		DUMB_VOLUME_RAMP_INFO* volume_left,
		DUMB_VOLUME_RAMP_INFO* volume_right,
		float delta);
	long dumb_resample_8_2_2(DUMB_RESAMPLER*,
		int* dst,
		long dst_size,
		DUMB_VOLUME_RAMP_INFO* volume_left,
		DUMB_VOLUME_RAMP_INFO* volume_right,
		float delta);
	void dumb_resample_get_current_sample_8_1_1(DUMB_RESAMPLER*,
		DUMB_VOLUME_RAMP_INFO* volume,
		int* dst);
	void dumb_resample_get_current_sample_8_1_2(DUMB_RESAMPLER*,
		DUMB_VOLUME_RAMP_INFO* volume_left,
		DUMB_VOLUME_RAMP_INFO* volume_right,
		int* dst);
	void dumb_resample_get_current_sample_8_2_1(DUMB_RESAMPLER*,
		DUMB_VOLUME_RAMP_INFO* volume_left,
		DUMB_VOLUME_RAMP_INFO* volume_right,
		int* dst);
	void dumb_resample_get_current_sample_8_2_2(DUMB_RESAMPLER*,
		DUMB_VOLUME_RAMP_INFO* volume_left,
		DUMB_VOLUME_RAMP_INFO* volume_right,
		int* dst);
	void dumb_end_resampler_8(DUMB_RESAMPLER*);

	void dumb_reset_resampler_n(
		int n,
		DUMB_RESAMPLER*,
		void* src,
		int src_channels,
		long pos,
		long start,
		long end,
		int quality);
	DUMB_RESAMPLER* dumb_start_resampler_n(
		int n,
		void* src,
		int src_channels,
		long pos,
		long start,
		long end,
		int quality);
	long dumb_resample_n_1_1(
		int n,
		DUMB_RESAMPLER*,
		int* dst,
		long dst_size,
		DUMB_VOLUME_RAMP_INFO* volume,
		float delta);
	long dumb_resample_n_1_2(
		int n,
		DUMB_RESAMPLER*,
		int* dst,
		long dst_size,
		DUMB_VOLUME_RAMP_INFO* volume_left,
		DUMB_VOLUME_RAMP_INFO* volume_right,
		float delta);
	long dumb_resample_n_2_1(
		int n,
		DUMB_RESAMPLER*,
		int* dst,
		long dst_size,
		DUMB_VOLUME_RAMP_INFO* volume_left,
		DUMB_VOLUME_RAMP_INFO* volume_right,
		float delta);
	long dumb_resample_n_2_2(
		int n,
		DUMB_RESAMPLER*,
		int* dst,
		long dst_size,
		DUMB_VOLUME_RAMP_INFO* volume_left,
		DUMB_VOLUME_RAMP_INFO* volume_right,
		float delta);
	void dumb_resample_get_current_sample_n_1_1(
		int n,
		DUMB_RESAMPLER*,
		DUMB_VOLUME_RAMP_INFO* volume,
		int* dst);
	void dumb_resample_get_current_sample_n_1_2(
		int n,
		DUMB_RESAMPLER*,
		DUMB_VOLUME_RAMP_INFO* volume_left,
		DUMB_VOLUME_RAMP_INFO* volume_right,
		int* dst);
	void dumb_resample_get_current_sample_n_2_1(
		int n,
		DUMB_RESAMPLER*,
		DUMB_VOLUME_RAMP_INFO* volume_left,
		DUMB_VOLUME_RAMP_INFO* volume_right,
		int* dst);
	void dumb_resample_get_current_sample_n_2_2(
		int n,
		DUMB_RESAMPLER*,
		DUMB_VOLUME_RAMP_INFO* volume_left,
		DUMB_VOLUME_RAMP_INFO* volume_right,
		int* dst);
	void dumb_end_resampler_n(int n, DUMB_RESAMPLER*);

]]

return lib
