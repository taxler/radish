
require 'exports.crt'

local ffi = require 'ffi'

ffi.cdef [[

	void dumb_exit();

]]

-- attempt to load statically-linked version, otherwise try dynamically-linked
local lib
if pcall(function()  assert(ffi.C.dumb_exit ~= nil)  end) then
	lib = ffi.C
else
	lib = ffi.load 'dumb'
end

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
		DUMB_MAJOR_VERSION    = 1,
		DUMB_MINOR_VERSION    = 0,
		DUMB_REVISION_VERSION = 0,

		DUMB_VERSION = (DUMB_MAJOR_VERSION*10000 + DUMB_MINOR_VERSION*100 + DUMB_REVISION_VERSION),

		/*
		#define DUMB_VERSION_STR "1.0.0"

		#define DUMB_NAME "DUMB v" DUMB_VERSION_STR
		*/

		DUMB_YEAR  = 2015,
		DUMB_MONTH = 1,
		DUMB_DAY   = 17,

		/*
		#define DUMB_YEAR_STR2  "15"
		#define DUMB_YEAR_STR4  "2015"
		#define DUMB_MONTH_STR1 "1"
		#define DUMB_DAY_STR1   "17"

		#if DUMB_MONTH < 10
		#define DUMB_MONTH_STR2 "0" DUMB_MONTH_STR1
		#else
		#define DUMB_MONTH_STR2 DUMB_MONTH_STR1
		#endif

		#if DUMB_DAY < 10
		#define DUMB_DAY_STR2 "0" DUMB_DAY_STR1
		#else
		#define DUMB_DAY_STR2 DUMB_DAY_STR1
		#endif
		*/

		/* WARNING: The month and day were inadvertently swapped in the v0.8 release.
		 *          Please do not compare this constant against any date in 2002. In
		 *          any case, DUMB_VERSION is probably more useful for this purpose.
		 */
		DUMB_DATE = (DUMB_YEAR*10000 + DUMB_MONTH*100 + DUMB_DAY),

		/*
		#define DUMB_DATE_STR DUMB_DAY_STR1 "." DUMB_MONTH_STR1 "." DUMB_YEAR_STR4
		*/

		/*
		#define DUMB_ID(a,b,c,d) (((unsigned int)(a) << 24) | \
		                          ((unsigned int)(b) << 16) | \
		                          ((unsigned int)(c) <<  8) | \
		                          ((unsigned int)(d)      ))
		*/

		DUH_SIGNATURE = ('D' << 24) | ('U' << 16) | ('H' << 8) | '!'

	};

	int dumb_atexit(void (*proc)());

	/* File Input Functions */

	typedef struct DUMBFILE_SYSTEM {
		void *(*open)(const char* filename);
		int (*skip)(void* f, long n);
		int (*getc)(void* f);
		long (*getnc)(char* ptr, long n, void* f);
		void (*close)(void* f);
	    int (*seek)(void* f, long n);
	    long (*get_size)(void* f);
	} DUMBFILE_SYSTEM;

	typedef struct DUMBFILE DUMBFILE;

	void register_dumbfile_system(const DUMBFILE_SYSTEM* dfs);
	DUMBFILE* dumbfile_open(const char* filename);
	DUMBFILE* dumbfile_open_ex(void* file, const DUMBFILE_SYSTEM* dfs);
	long dumbfile_pos(DUMBFILE*);
	int dumbfile_skip(DUMBFILE*, long n);

	enum {
		DFS_SEEK_SET = 0,
		DFS_SEEK_CUR = 1,
		DFS_SEEK_END = 2
	};

	int dumbfile_getc(DUMBFILE*);
	int dumbfile_igetw(DUMBFILE*);
	int dumbfile_mgetw(DUMBFILE*);
	long dumbfile_igetl(DUMBFILE*);
	long dumbfile_mgetl(DUMBFILE*);
	unsigned long dumbfile_cgetul(DUMBFILE*);
	signed long dumbfile_cgetsl(DUMBFILE*);
	long dumbfile_getnc(char* ptr, long n, DUMBFILE*);
	int dumbfile_error(DUMBFILE*);
	int dumbfile_close(DUMBFILE*);
	void dumb_register_stdfiles();
	DUMBFILE* dumbfile_open_stdfile(FILE* p);
	DUMBFILE* dumbfile_open_memory(const char* data, long size);
	typedef struct DUH DUH;

	void unload_duh(DUH*);
	DUH* load_duh(const char* filename);
	DUH* read_duh(DUMBFILE*);
	long duh_get_length(DUH*);
	const char* duh_get_tag(DUH*, const char* key);

	typedef struct DUH_SIGRENDERER DUH_SIGRENDERER;

	DUH_SIGRENDERER* duh_start_sigrenderer(DUH*, int sig, int n_channels, long pos);

	typedef void (*DUH_SIGRENDERER_SAMPLE_ANALYSER_CALLBACK)(
		void* data,
		const int* const* samples,
		int n_channels,
		long length);
	void duh_sigrenderer_set_sample_analyser_callback(
		DUH_SIGRENDERER*,
		DUH_SIGRENDERER_SAMPLE_ANALYSER_CALLBACK callback, void* data);
	int duh_sigrenderer_get_n_channels(DUH_SIGRENDERER*);
	long duh_sigrenderer_get_position(DUH_SIGRENDERER*);

	void duh_sigrenderer_set_sigparam(DUH_SIGRENDERER*, unsigned char id, long value);
	long duh_sigrenderer_generate_samples(
		DUH_SIGRENDERER*,
		float volume, float delta,
		long size, int **samples);
	void duh_sigrenderer_get_current_sample(DUH_SIGRENDERER*, float volume, int* samples);
	void duh_end_sigrenderer(DUH_SIGRENDERER*);

	long duh_render(
		DUH_SIGRENDERER*,
		int bits, int unsign,
		float volume, float delta,
		long size, void* sptr);

	/* Impulse Tracker Support */

	int dumb_it_max_to_mix;

	typedef struct DUMB_IT_SIGDATA DUMB_IT_SIGDATA;
	typedef struct DUMB_IT_SIGRENDERER DUMB_IT_SIGRENDERER;

	DUMB_IT_SIGDATA* duh_get_it_sigdata(DUH*);
	DUH_SIGRENDERER* duh_encapsulate_it_sigrenderer(DUMB_IT_SIGRENDERER*, int n_channels, long pos);
	DUMB_IT_SIGRENDERER* duh_get_it_sigrenderer(DUH_SIGRENDERER*);
	typedef int (*dumb_scan_callback)(void*, int, long);
	DUH_SIGRENDERER* dumb_it_start_at_order(DUH*, int n_channels, int startorder);

	enum {
	    DUMB_IT_RAMP_NONE = 0,
	    DUMB_IT_RAMP_ONOFF_ONLY = 1,
	    DUMB_IT_RAMP_FULL = 2
	};

	void dumb_it_set_loop_callback(DUMB_IT_SIGRENDERER*, int (*callback)(void* data), void* data);
	void dumb_it_set_xm_speed_zero_callback(DUMB_IT_SIGRENDERER*, int (*callback)(void* data), void* data);
	void dumb_it_set_midi_callback(
		DUMB_IT_SIGRENDERER*,
		int (*callback)(void* data, int channel, unsigned char midi_byte),
		void* data);
	int dumb_it_callback_terminate(void* data);
	int dumb_it_callback_midi_block(void* data, int channel, unsigned char midi_byte);

	/* dumb_*_mod*: restrict_ |= 1-Don't read 15 sample files / 2-Use old pattern counting method */
	DUH* dumb_load_it(const char* filename);
	DUH* dumb_load_xm(const char* filename);
	DUH* dumb_load_s3m(const char* filename);
	DUH* dumb_load_mod(const char* filename, int restrict_);

	DUH* dumb_read_it(DUMBFILE*);
	DUH* dumb_read_xm(DUMBFILE*);
	DUH* dumb_read_s3m(DUMBFILE*);
	DUH* dumb_read_mod(DUMBFILE*, int restrict_);

	DUH* dumb_load_it_quick(const char* filename);
	DUH* dumb_load_xm_quick(const char* filename);
	DUH* dumb_load_s3m_quick(const char* filename);
	DUH* dumb_load_mod_quick(const char* filename, int restrict_);

	DUH* dumb_read_it_quick(DUMBFILE*);
	DUH* dumb_read_xm_quick(DUMBFILE*);
	DUH* dumb_read_s3m_quick(DUMBFILE*);
	DUH* dumb_read_mod_quick(DUMBFILE*, int restrict_);

	long dumb_it_build_checkpoints(DUMB_IT_SIGDATA*, int startorder);
	void dumb_it_do_initial_runthrough(DUH*);
	const unsigned char* dumb_it_sd_get_song_message(DUMB_IT_SIGDATA*);
	int dumb_it_sd_get_n_orders(DUMB_IT_SIGDATA*);
	int dumb_it_sd_get_n_samples(DUMB_IT_SIGDATA*);
	int dumb_it_sd_get_n_instruments(DUMB_IT_SIGDATA*);

	const unsigned char* dumb_it_sd_get_sample_name(DUMB_IT_SIGDATA*, int i);
	const unsigned char* dumb_it_sd_get_sample_filename(DUMB_IT_SIGDATA*, int i);
	const unsigned char* dumb_it_sd_get_instrument_name(DUMB_IT_SIGDATA*, int i);
	const unsigned char* dumb_it_sd_get_instrument_filename(DUMB_IT_SIGDATA*, int i);
	int dumb_it_sd_get_initial_global_volume(DUMB_IT_SIGDATA*);
	void dumb_it_sd_set_initial_global_volume(DUMB_IT_SIGDATA*, int gv);
	int dumb_it_sd_get_mixing_volume(DUMB_IT_SIGDATA*);
	void dumb_it_sd_set_mixing_volume(DUMB_IT_SIGDATA*, int mv);
	int dumb_it_sd_get_initial_speed(DUMB_IT_SIGDATA*);
	void dumb_it_sd_set_initial_speed(DUMB_IT_SIGDATA*, int speed);
	int dumb_it_sd_get_initial_tempo(DUMB_IT_SIGDATA*);
	void dumb_it_sd_set_initial_tempo(DUMB_IT_SIGDATA*, int tempo);
	int dumb_it_sd_get_initial_channel_volume(DUMB_IT_SIGDATA*, int channel);
	void dumb_it_sd_set_initial_channel_volume(DUMB_IT_SIGDATA*, int channel, int volume);
	int dumb_it_sr_get_current_order(DUMB_IT_SIGRENDERER*);
	int dumb_it_sr_get_current_row(DUMB_IT_SIGRENDERER*);
	int dumb_it_sr_get_global_volume(DUMB_IT_SIGRENDERER*);
	void dumb_it_sr_set_global_volume(DUMB_IT_SIGRENDERER*, int gv);
	int dumb_it_sr_get_tempo(DUMB_IT_SIGRENDERER*);
	void dumb_it_sr_set_tempo(DUMB_IT_SIGRENDERER*, int tempo);
	int dumb_it_sr_get_speed(DUMB_IT_SIGRENDERER*);
	void dumb_it_sr_set_speed(DUMB_IT_SIGRENDERER*, int speed);

	enum {
		DUMB_IT_N_CHANNELS = 64,
		DUMB_IT_N_NNA_CHANNELS = 192,
		DUMB_IT_TOTAL_CHANNELS = DUMB_IT_N_CHANNELS + DUMB_IT_N_NNA_CHANNELS
	};

	/* Channels passed to any of these functions are 0-based */
	int dumb_it_sr_get_channel_volume(DUMB_IT_SIGRENDERER*, int channel);
	void dumb_it_sr_set_channel_volume(DUMB_IT_SIGRENDERER*, int channel, int volume);

	int dumb_it_sr_get_channel_muted(DUMB_IT_SIGRENDERER*, int channel);
	void dumb_it_sr_set_channel_muted(DUMB_IT_SIGRENDERER*, int channel, int muted);

	typedef struct DUMB_IT_CHANNEL_STATE {
		int channel; /* 0-based; meaningful for NNA channels */
		int sample; /* 1-based; 0 if nothing playing, then other fields undef */
		int freq; /* in Hz */
		float volume; /* 1.0 maximum; affected by ALL factors, inc. mixing vol */
		unsigned char pan; /* 0-64, 100 for surround */
		signed char subpan; /* use (pan + subpan/256.0f) or ((pan<<8)+subpan) */
		unsigned char filter_cutoff;    /* 0-127    cutoff=127 AND resonance=0 */
		unsigned char filter_subcutoff; /* 0-255      -> no filters (subcutoff */
		unsigned char filter_resonance; /* 0-127        always 0 in this case) */
		/* subcutoff only changes from zero if filter envelopes are in use. The
		 * calculation (filter_cutoff + filter_subcutoff/256.0f) gives a more
		 * accurate filter cutoff measurement as a float. It would often be more
		 * useful to use a scaled int such as ((cutoff<<8) + subcutoff).
		 */
	} DUMB_IT_CHANNEL_STATE;

	/* Values of 64 or more will access NNA channels here. */
	void dumb_it_sr_get_channel_state(DUMB_IT_SIGRENDERER*, int channel, DUMB_IT_CHANNEL_STATE*);

	/* Signal Design Helper Values */

	/* Use pow(DUMB_SEMITONE_BASE, n) to get the 'delta' value to transpose up by
	 * n semitones. To transpose down, use negative n.
	 */
	//#define DUMB_SEMITONE_BASE 1.059463094359295309843105314939748495817

	/* Use pow(DUMB_QUARTERTONE_BASE, n) to get the 'delta' value to transpose up
	 * by n quartertones. To transpose down, use negative n.
	 */
	//#define DUMB_QUARTERTONE_BASE 1.029302236643492074463779317738953977823

	/* Use pow(DUMB_PITCH_BASE, n) to get the 'delta' value to transpose up by n
	 * units. In this case, 256 units represent one semitone; 3072 units
	 * represent one octave. These units are used by the sequence signal (SEQU).
	 */
	//#define DUMB_PITCH_BASE 1.000225659305069791926712241547647863626


	/* Signal Design Function Types */

	typedef void sigdata_t;
	typedef void sigrenderer_t;

	typedef sigdata_t* (*DUH_LOAD_SIGDATA)(DUH*, DUMBFILE* file);

	typedef sigrenderer_t* (*DUH_START_SIGRENDERER)(DUH*, sigdata_t*, int n_channels, long pos);

	typedef void (*DUH_SIGRENDERER_SET_SIGPARAM)(sigrenderer_t*, unsigned char id, long value);

	typedef long (*DUH_SIGRENDERER_GENERATE_SAMPLES)(
		sigrenderer_t*,
		float volume, float delta,
		long size, int** samples);
	typedef void (*DUH_SIGRENDERER_GET_CURRENT_SAMPLE)(
		sigrenderer_t*,
		float volume,
		int* samples);
	typedef long (*DUH_SIGRENDERER_GET_POSITION)(sigrenderer_t*);
	typedef void (*DUH_END_SIGRENDERER)(sigrenderer_t*);
	typedef void (*DUH_UNLOAD_SIGDATA)(sigdata_t*);

	/* Signal Design Function Registration */

	typedef struct DUH_SIGTYPE_DESC {
		long type;
		DUH_LOAD_SIGDATA                   load_sigdata;
		DUH_START_SIGRENDERER              start_sigrenderer;
		DUH_SIGRENDERER_SET_SIGPARAM       sigrenderer_set_sigparam;
		DUH_SIGRENDERER_GENERATE_SAMPLES   sigrenderer_generate_samples;
		DUH_SIGRENDERER_GET_CURRENT_SAMPLE sigrenderer_get_current_sample;
		DUH_SIGRENDERER_GET_POSITION       sigrenderer_get_position;
		DUH_END_SIGRENDERER                end_sigrenderer;
		DUH_UNLOAD_SIGDATA                 unload_sigdata;
	} DUH_SIGTYPE_DESC;

	void dumb_register_sigtype(DUH_SIGTYPE_DESC* desc);

	// Decide where to put these functions; new heading?
	sigdata_t* duh_get_raw_sigdata(DUH*, int sig, long type);

	DUH_SIGRENDERER* duh_encapsulate_raw_sigrenderer(sigrenderer_t* vsigrenderer, DUH_SIGTYPE_DESC* desc, int n_channels, long pos);
	sigrenderer_t* duh_get_raw_sigrenderer(DUH_SIGRENDERER*, long type);

	/* Standard Signal Types */
	//void dumb_register_sigtype_sample();

	/* Sample Buffer Allocation Helpers */
	int** allocate_sample_buffer(int n_channels, long length);
	void destroy_sample_buffer(int** samples);

	void dumb_silence(int* samples, long length); // helper

	/* Click Removal Helpers */

	typedef struct DUMB_CLICK_REMOVER DUMB_CLICK_REMOVER;

	DUMB_CLICK_REMOVER* dumb_create_click_remover();
	void dumb_record_click(DUMB_CLICK_REMOVER* cr, long pos, int step);
	void dumb_remove_clicks(DUMB_CLICK_REMOVER* cr, int* samples, long length, int step, float halflife);
	int dumb_click_remover_get_offset(DUMB_CLICK_REMOVER* cr);
	void dumb_destroy_click_remover(DUMB_CLICK_REMOVER* cr);

	DUMB_CLICK_REMOVER** dumb_create_click_remover_array(int n);
	void dumb_record_click_array(int n, DUMB_CLICK_REMOVER** cr, long pos, int* step);
	void dumb_record_click_negative_array(int n, DUMB_CLICK_REMOVER** cr, long pos, int* step);
	void dumb_remove_clicks_array(int n, DUMB_CLICK_REMOVER** cr, int** samples, long length, float halflife);
	void dumb_click_remover_get_offset_array(int n, DUMB_CLICK_REMOVER** cr, int* offset);
	void dumb_destroy_click_remover_array(int n, DUMB_CLICK_REMOVER** cr);



	DUH* make_duh(
		long length,
		int n_tags,
		const char* const tag[][2],
		int n_signals,
		DUH_SIGTYPE_DESC* desc[],
		sigdata_t*[]);

	void duh_set_length(DUH*, long length);

]]

return lib
