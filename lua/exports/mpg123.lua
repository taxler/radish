
local ffi = require 'ffi'
require 'exports.crt'

ffi.cdef [[

	enum {
		MPG123_API_VERSION = 41,

		MPG123_MONO_LEFT    = 0x1,
		MPG123_MONO_RIGHT   = 0x2,
		MPG123_MONO_MIX     = 0x4,
		MPG123_FORCE_MONO   = MPG123_MONO_LEFT | MPG123_MONO_RIGHT | MPG123_MONO_MIX,
		MPG123_FORCE_STEREO = 0x8,
		MPG123_FORCE_8BIT   = 0x10,
		MPG123_QUIET        = 0x20,
		MPG123_GAPLESS      = 0x40,
		MPG123_NO_RESYNC    = 0x80,
		MPG123_SEEKBUFFER   = 0x100,
		MPG123_FUZZY        = 0x200,
		MPG123_FORCE_FLOAT  = 0x400,
		MPG123_PLAIN_ID3TEXT = 0x800,
		MPG123_IGNORE_STREAMLENGTH = 0x1000,
		MPG123_SKIP_ID3V2 = 0x2000,
		MPG123_IGNORE_INFOFRAME = 0x4000,
		MPG123_AUTO_RESAMPLE = 0x8000,
		MPG123_PICTURE = 0x10000,

		MPG123_RVA_OFF   = 0,
		MPG123_RVA_MIX   = 1,
		MPG123_RVA_ALBUM = 2,
		MPG123_RVA_MAX   = MPG123_RVA_ALBUM,

		MPG123_DONE = -12,
		MPG123_NEW_FORMAT = -11,
		MPG123_NEED_MORE = -10,
		MPG123_ERR = -1,
		MPG123_OK = 0,
		MPG123_BAD_OUTFORMAT,
		MPG123_BAD_CHANNEL,
		MPG123_BAD_RATE,
		MPG123_ERR_16TO8TABLE,
		MPG123_BAD_PARAM,
		MPG123_BAD_BUFFER,
		MPG123_OUT_OF_MEM,
		MPG123_NOT_INITIALIZED,
		MPG123_BAD_DECODER,
		MPG123_BAD_HANDLE,
		MPG123_NO_BUFFERS,
		MPG123_BAD_RVA,
		MPG123_NO_GAPLESS,
		MPG123_NO_SPACE,
		MPG123_BAD_TYPES,
		MPG123_BAD_BAND,
		MPG123_ERR_NULL,
		MPG123_ERR_READER,
		MPG123_NO_SEEK_FROM_END,
		MPG123_BAD_WHENCE,
		MPG123_NO_TIMEOUT,
		MPG123_BAD_FILE,
		MPG123_NO_SEEK,
		MPG123_NO_READER,
		MPG123_BAD_PARS,
		MPG123_BAD_INDEX_PAR,
		MPG123_OUT_OF_SYNC,
		MPG123_RESYNC_FAIL,
		MPG123_NO_8BIT,
		MPG123_BAD_ALIGN,
		MPG123_NULL_BUFFER,
		MPG123_NO_RELSEEK,
		MPG123_NULL_POINTER,
		MPG123_BAD_KEY,
		MPG123_NO_INDEX,
		MPG123_INDEX_FAIL,
		MPG123_BAD_DECODER_SETUP,
		MPG123_MISSING_FEATURE,
		MPG123_BAD_VALUE,
		MPG123_LSEEK_FAILED,
		MPG123_BAD_CUSTOM_IO,
		MPG123_LFS_OVERFLOW,
		MPG123_INT_OVERFLOW,

		MPG123_ENC_8      = 0x00f,
		MPG123_ENC_16     = 0x040,
		MPG123_ENC_24     = 0x4000,
		MPG123_ENC_32     = 0x100,
		MPG123_ENC_SIGNED = 0x080,
		MPG123_ENC_FLOAT  = 0xe00,
		MPG123_ENC_SIGNED_16   = (MPG123_ENC_16|MPG123_ENC_SIGNED|0x10),
		MPG123_ENC_UNSIGNED_16 = (MPG123_ENC_16|0x20),
		MPG123_ENC_UNSIGNED_8  = 0x01,
		MPG123_ENC_SIGNED_8    = (MPG123_ENC_SIGNED|0x02),
		MPG123_ENC_ULAW_8      = 0x04,
		MPG123_ENC_ALAW_8      = 0x08,
		MPG123_ENC_SIGNED_32   = MPG123_ENC_32|MPG123_ENC_SIGNED|0x1000,
		MPG123_ENC_UNSIGNED_32 = MPG123_ENC_32|0x2000,
		MPG123_ENC_SIGNED_24   = MPG123_ENC_24|MPG123_ENC_SIGNED|0x1000,
		MPG123_ENC_UNSIGNED_24 = MPG123_ENC_24|0x2000,
		MPG123_ENC_FLOAT_32    = 0x200,
		MPG123_ENC_FLOAT_64    = 0x400,
		MPG123_ENC_ANY = ( MPG123_ENC_SIGNED_16  | MPG123_ENC_UNSIGNED_16 | MPG123_ENC_UNSIGNED_8
		                  | MPG123_ENC_SIGNED_8   | MPG123_ENC_ULAW_8      | MPG123_ENC_ALAW_8
		                  | MPG123_ENC_SIGNED_32  | MPG123_ENC_UNSIGNED_32
		                  | MPG123_ENC_SIGNED_24  | MPG123_ENC_UNSIGNED_24
		                  | MPG123_ENC_FLOAT_32   | MPG123_ENC_FLOAT_64 ),

		MPG123_MONO   = 1,
		MPG123_STEREO = 2,

		mpg123_id3_latin1   = 0,
		mpg123_id3_utf16bom = 1,
		mpg123_id3_utf16be  = 2,
		mpg123_id3_utf8     = 3,
		mpg123_id3_enc_max  = mpg123_id3_utf8,

		mpg123_id3_pic_other          =  0,
		mpg123_id3_pic_icon           =  1,
		mpg123_id3_pic_other_icon     =  2,
		mpg123_id3_pic_front_cover    =  3,
		mpg123_id3_pic_back_cover     =  4,
		mpg123_id3_pic_leaflet        =  5,
		mpg123_id3_pic_media          =  6,
		mpg123_id3_pic_lead           =  7,
		mpg123_id3_pic_artist         =  8,
		mpg123_id3_pic_conductor      =  9,
		mpg123_id3_pic_orchestra      = 10,
		mpg123_id3_pic_composer       = 11,
		mpg123_id3_pic_lyricist       = 12,
		mpg123_id3_pic_location       = 13,
		mpg123_id3_pic_recording      = 14,
		mpg123_id3_pic_performance    = 15,
		mpg123_id3_pic_video          = 16,
		mpg123_id3_pic_fish           = 17,
		mpg123_id3_pic_illustration   = 18,
		mpg123_id3_pic_artist_logo    = 19,
		mpg123_id3_pic_publisher_logo = 20,

		MPG123_ID3     = 0x3,
		MPG123_NEW_ID3 = 0x1,
		MPG123_ICY     = 0xc,
		MPG123_NEW_ICY = 0x4
	};

	typedef enum {
		MPG123_VERBOSE = 0,
		MPG123_FLAGS,
		MPG123_ADD_FLAGS,
		MPG123_FORCE_RATE,
		MPG123_DOWN_SAMPLE,
		MPG123_RVA,
		MPG123_DOWNSPEED,
		MPG123_UPSPEED,
		MPG123_START_FRAME,
		MPG123_DECODE_FRAMES,
		MPG123_ICY_INTERVAL,
		MPG123_OUTSCALE,
		MPG123_TIMEOUT,
		MPG123_REMOVE_FLAGS,
		MPG123_RESYNC_LIMIT,
		MPG123_INDEX_SIZE,
		MPG123_PREFRAMES,
		MPG123_FEEDPOOL,
		MPG123_FEEDBUFFER
	} mpg123_parms;

	typedef enum {
		MPG123_FEATURE_ABI_UTF8OPEN = 0,
		MPG123_FEATURE_OUTPUT_8BIT,
		MPG123_FEATURE_OUTPUT_16BIT,
		MPG123_FEATURE_OUTPUT_32BIT,
		MPG123_FEATURE_INDEX,
		MPG123_FEATURE_PARSE_ID3V2,
		MPG123_FEATURE_DECODE_LAYER1,
		MPG123_FEATURE_DECODE_LAYER2,
		MPG123_FEATURE_DECODE_LAYER3,
		MPG123_FEATURE_DECODE_ACCURATE,
		MPG123_FEATURE_DECODE_DOWNSAMPLE,
		MPG123_FEATURE_DECODE_NTOM,
		MPG123_FEATURE_PARSE_ICY,
		MPG123_FEATURE_TIMEOUT_READ,
	} mpg123_feature_set;

	typedef enum {
		MPG123_LEFT = 0x1,
		MPG123_RIGHT = 0x2,
		MPG123_LR = MPG123_LEFT | MPG123_RIGHT
	} mpg123_channels;

	typedef enum {
		MPG123_CBR = 0,
		MPG123_VBR,
		MPG123_ABR
	} mpg123_vbr;

	typedef enum {
		MPG123_1_0 = 0,
		MPG123_2_0,
		MPG123_2_5
	} mpg123_version;

	typedef enum {
		MPG123_M_STEREO=0,
		MPG123_M_JOINT,
		MPG123_M_DUAL,
		MPG123_M_MONO
	} mpg123_mode;

	typedef enum {
		MPG123_CRC=0x1,
		MPG123_COPYRIGHT=0x2,
		MPG123_PRIVATE=0x4,
		MPG123_ORIGINAL=0x8
	} mpg123_flags;

	typedef enum {
		MPG123_ACCURATE = 1,
		MPG123_BUFFERFILL,
		MPG123_FRANKENSTEIN,
		MPG123_FRESH_DECODER
	} mpg123_state;

	typedef enum {
		mpg123_text_unknown  = 0,
		mpg123_text_utf8     = 1,
		mpg123_text_latin1   = 2,
		mpg123_text_icy      = 3,
		mpg123_text_cp1252   = 4,
		mpg123_text_utf16    = 5,
		mpg123_text_utf16bom = 6,
		mpg123_text_utf16be  = 7,
		mpg123_text_max      = mpg123_text_utf16be
	} mpg123_text_encoding;

	typedef struct mpg123_handle mpg123_handle;

	typedef struct mpg123_frameinfo {
		mpg123_version version;
		int layer;
		long rate;
		mpg123_mode mode;
		int mode_ext;
		int framesize;
		mpg123_flags flags;
		int emphasis;
		int bitrate;
		int abr_rate;
		mpg123_vbr vbr;
	} mpg123_frameinfo;

	typedef struct {
		char* p;
		size_t size;
		size_t fill;
	} mpg123_string;

	typedef struct mpg123_text {
		char lang[3];
		char id[4];
		mpg123_string description;
		mpg123_string text;
	} mpg123_text;

	typedef struct mpg123_picture {
		char type;
		mpg123_string description;
		mpg123_string mime_type;
		size_t size;
		unsigned char* data;
	} mpg123_picture;

	typedef struct mpg123_id3v2 {
		unsigned char version;
		mpg123_string* title;
		mpg123_string* artist;
		mpg123_string* album;
		mpg123_string* year;
		mpg123_string* genre;
		mpg123_string* comment;

		mpg123_text* comment_list;
		size_t comments;
		mpg123_text* text;
		size_t texts;
		mpg123_text* extra;
		size_t extras;
		mpg123_picture* picture;
		size_t pictures;
	} mpg123_id3v2;

	typedef struct mpg123_id3v1 {
		char tag[3];
		char title[30];
		char artist[30];
		char album[30];
		char year[4];
		char comment[30];
		unsigned char genre;
	} mpg123_id3v1;

	typedef struct mpg123_pars mpg123_pars;

	int mpg123_init();
	void mpg123_exit();
	mpg123_handle* mpg123_new(const char* decoder, int* out_error);
	void mpg123_delete(mpg123_handle*);
	int mpg123_param(mpg123_handle*, mpg123_parms, long value, double fvalue);
	int mpg123_getparam(mpg123_handle*, mpg123_parms, long* val, double* fval);
	int mpg123_feature(mpg123_feature_set);
	const char* mpg123_plain_strerror(int errcode);
	const char* mpg123_strerror(mpg123_handle*);
	int mpg123_errcode(mpg123_handle*);
	const char** mpg123_decoders();
	const char** mpg123_supported_decoders();
	int mpg123_decoder(mpg123_handle*, const char* decoder_name);
	const char* mpg123_current_decoder(mpg123_handle*);
	void mpg123_rates(const long** list, size_t* number);
	void mpg123_encodings(const int** list, size_t* number);
	int mpg123_encsize(int encoding);
	int mpg123_format_none(mpg123_handle*);
	int mpg123_format_all(mpg123_handle*);
	int mpg123_format(mpg123_handle*, long rate, int channels, int encodings);
	int mpg123_format_support(mpg123_handle*, long rate, int encoding);
	int mpg123_getformat(mpg123_handle*, long* rate, int* channels, int* encoding);
	int mpg123_open(mpg123_handle*, const char* path);
	int mpg123_open_fd(mpg123_handle*, int fd);
	int mpg123_open_handle(mpg123_handle*, void* iohandle);
	int mpg123_open_feed(mpg123_handle*);
	int mpg123_close(mpg123_handle*);
	int mpg123_read(mpg123_handle*, unsigned char* outmemory, size_t outmemsize, size_t* done);
	int mpg123_feed(mpg123_handle*, const unsigned char* in, size_t size);
	int mpg123_decode(
		mpg123_handle*,
		const unsigned char* inmemory,
		size_t inmemsize,
		unsigned char* outmemory,
		size_t outmemsize,
		size_t* done);
	int mpg123_decode_frame(mpg123_handle*, off_t* num, unsigned char** audio, size_t* bytes);
	int mpg123_framebyframe_decode(mpg123_handle*, off_t* num, unsigned char** audio, size_t* bytes);
	int mpg123_framebyframe_next(mpg123_handle*);
	int mpg123_framedata(mpg123_handle*, unsigned long* header, unsigned char** bodydata, size_t* bodybytes);
	off_t mpg123_framepos(mpg123_handle*);
	off_t mpg123_tell(mpg123_handle*);
	off_t mpg123_tellframe(mpg123_handle*);
	off_t mpg123_tell_stream(mpg123_handle*);
	off_t mpg123_seek(mpg123_handle*, off_t sampleoff, int whence);
	off_t mpg123_feedseek(mpg123_handle*, off_t sampleoff, int whence, off_t* input_offset);
	off_t mpg123_seek_frame(mpg123_handle*, off_t frameoff, int whence);
	off_t mpg123_timeframe(mpg123_handle*, double sec);
	int mpg123_index(mpg123_handle*, off_t** offsets, off_t* step, size_t* fill);
	int mpg123_set_index(mpg123_handle*, off_t* offsets, off_t step, size_t fill);
	int mpg123_position(
		mpg123_handle*,
		off_t frame_offset,
		off_t buffered_bytes,
		off_t* current_frame,
		off_t* frames_left,
		double* current_seconds,
		double* seconds_left);
	int mpg123_eq(mpg123_handle*, mpg123_channels, int band, double val);
	double mpg123_geteq(mpg123_handle*, mpg123_channels, int band);
	int mpg123_reset_eq(mpg123_handle*);
	int mpg123_volume(mpg123_handle*, double vol);
	int mpg123_volume_change(mpg123_handle*, double change);
	int mpg123_getvolume(mpg123_handle*, double* base, double* really, double* rva_db);
	int mpg123_info(mpg123_handle*, mpg123_frameinfo* out_info);
	size_t mpg123_safe_buffer();
	int mpg123_scan(mpg123_handle*);
	off_t mpg123_length(mpg123_handle*);
	int mpg123_set_filesize(mpg123_handle*, off_t size);
	double mpg123_tpf(mpg123_handle*);
	int mpg123_spf(mpg123_handle*);
	long mpg123_clip(mpg123_handle*);
	int mpg123_getstate(mpg123_handle*, mpg123_state, long* val, double* fval);
	void mpg123_init_string(mpg123_string*);
	void mpg123_free_string(mpg123_string*);
	int mpg123_resize_string(mpg123_string*, size_t news);
	int mpg123_grow_string(mpg123_string*, size_t news);
	int mpg123_copy_string(mpg123_string* from, mpg123_string* to);
	int mpg123_add_string(mpg123_string*, const char* stuff);
	int mpg123_add_substring(mpg123_string* sb, const char* stuff, size_t from, size_t count);
	int mpg123_set_string(mpg123_string*, const char* stuff);
	int mpg123_set_substring(mpg123_string* sb, const char* stuff, size_t from, size_t count);
	size_t mpg123_strlen(mpg123_string* sb, int utf8);
	int mpg123_chomp_string(mpg123_string* sb);
	mpg123_text_encoding mpg123_enc_from_id3(unsigned char id3_enc_byte);
	int mpg123_store_utf8(mpg123_string* sb, mpg123_text_encoding, const unsigned char* source, size_t source_size);
	int mpg123_meta_check(mpg123_handle*);
	void mpg123_meta_free(mpg123_handle*);
	int mpg123_id3(mpg123_handle*, mpg123_id3v1** v1, mpg123_id3v2** v2);
	int mpg123_icy(mpg123_handle*, char** icy_meta);
	char* mpg123_icy2utf8(const char* icy_text);
	mpg123_handle* mpg123_parnew(mpg123_pars*, const char* decoder, int* error);
	mpg123_pars* mpg123_new_pars(int* error);
	void mpg123_delete_pars(mpg123_pars*);
	int mpg123_fmt_none(mpg123_pars*);
	int mpg123_fmt_all(mpg123_pars*);
	int mpg123_fmt(mpg123_pars*, long rate, int channels, int encodings);
	int mpg123_fmt_support(mpg123_pars*, long rate, int encoding);
	int mpg123_par(mpg123_pars*, mpg123_parms, long value, double fvalue);
	int mpg123_getpar(mpg123_pars*, mpg123_parms, long* val, double* fval);
	int mpg123_replace_buffer(mpg123_handle*, unsigned char* data, size_t size);
	size_t mpg123_outblock(mpg123_handle*);
	int mpg123_replace_reader(
		mpg123_handle*,
		ssize_t (*r_read) (int, void*, size_t),
		off_t (*r_lseek)(int, off_t, int));
	int mpg123_replace_reader_handle(
		mpg123_handle*,
		ssize_t (*r_read) (void*, void*, size_t),
		off_t (*r_lseek)(void*, off_t, int),
		void (*cleanup)(void*));

]]

return ffi.load 'libmpg123-0'
