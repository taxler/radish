
local ffi = require 'ffi'

ffi.cdef [[

	enum {
		gme_info_only = -1,
		gme_max_field = 255
	};

	typedef const char* gme_err_t;

	typedef struct Music_Emu Music_Emu;
	typedef struct track_info_t {
		long track_count;
		
		/* times in milliseconds; -1 if unknown */
		long length;
		long intro_length;
		long loop_length;
		
		/* empty string if not available */
		char system    [256];
		char game      [256];
		char song      [256];
		char author    [256];
		char copyright [256];
		char comment   [256];
		char dumper    [256];
	} track_info_t;

	typedef struct gme_equalizer_t {
		double treble; /* -50.0 = muffled, 0 = flat, +5.0 = extra-crisp */
		long   bass;   /* 1 = full bass, 90 = average, 16000 = almost no bass */
	} gme_equalizer_t;

	gme_err_t gme_open_file(const char* path, Music_Emu** out, long sample_rate);
	int gme_track_count(Music_Emu const*);
	gme_err_t gme_start_track(Music_Emu*, int index);
	gme_err_t gme_play(Music_Emu*, long count, short* out);
	void gme_delete(Music_Emu*);
	void gme_set_fade(Music_Emu*, long start_msec);
	int gme_track_ended(Music_Emu const*);
	long gme_tell(Music_Emu const*);
	gme_err_t gme_seek(Music_Emu*, long msec);
	const char* gme_warning(Music_Emu*);
	gme_err_t gme_load_m3u(Music_Emu*, const char* path);
	//void gme_clear_playlist(Music_Emu*);
	gme_err_t gme_track_info(Music_Emu const*, track_info_t* out, int track);
	void gme_set_stereo_depth(Music_Emu*, double depth);
	void gme_ignore_silence(Music_Emu*, int ignore);
	void gme_set_tempo(Music_Emu*, double tempo);
	int gme_voice_count(Music_Emu const*);
	const char** gme_voice_names(Music_Emu const*);
	void gme_mute_voice(Music_Emu*, int index, int mute);
	void gme_mute_voices(Music_Emu*, int muting_mask);
	gme_equalizer_t gme_equalizer(Music_Emu const*);
	void gme_set_equalizer(Music_Emu*, gme_equalizer_t const* eq);
	typedef struct gme_type_t_ const* gme_type_t;
	struct gme_type_t_ {
		const char* system;         /* name of system this music file type is generally for */
		int track_count;            /* non-zero for formats with a fixed number of tracks */
		Music_Emu* (*new_emu)();    /* Create new emulator for this type (useful in C++ only) */
		Music_Emu* (*new_info)();   /* Create new info reader for this type */
		
		/* internal */
		const char* extension_;
		int flags_;
	};

	struct gme_type_t_ const gme_ay_type [], gme_gbs_type [], gme_gym_type [],
			gme_hes_type [], gme_kss_type [], gme_nsf_type [], gme_nsfe_type [],
			gme_sap_type [], gme_spc_type [], gme_vgm_type [], gme_vgz_type [];

	gme_type_t gme_type(Music_Emu const*);
	gme_type_t const* gme_type_list();
	const char gme_wrong_file_type [];
	gme_err_t gme_open_data(void const* data, long size, Music_Emu** out, long sample_rate);
	const char* gme_identify_header(void const* header);
	gme_type_t gme_identify_extension(const char* path_or_extension);
	gme_err_t gme_identify_file(const char* path, gme_type_t* type_out);
	Music_Emu* gme_new_emu(gme_type_t, long sample_rate);
	gme_err_t gme_load_file(Music_Emu*, const char* path);
	gme_err_t gme_load_data(Music_Emu*, void const* data, long size);
	typedef gme_err_t (*gme_reader_t)(void* your_data, void* out, long count);
	gme_err_t gme_load_custom(Music_Emu*, gme_reader_t, long file_size, void* your_data);
	gme_err_t gme_load_m3u_data(Music_Emu*, void const* data, long size);
	void  gme_set_user_data(Music_Emu*, void* new_user_data);
	void* gme_user_data(Music_Emu const*);
	typedef void (*gme_user_cleanup_t)(void* user_data);
	void gme_set_user_cleanup(Music_Emu*, gme_user_cleanup_t func);

]]

return ffi.load 'gme'
