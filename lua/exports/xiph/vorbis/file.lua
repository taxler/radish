
local ffi = require 'ffi'
require 'exports.xiph.ogg'
require 'exports.xiph.vorbis'
require 'exports.crt'

ffi.cdef [[

	enum {
		NOTOPEN   = 0,
		PARTOPEN  = 1,
		OPENED    = 2,
		STREAMSET = 3,
		INITSET   = 4
	};

	typedef struct ov_callbacks {
		size_t (*read_func)  (void *ptr, size_t size, size_t nmemb, void* datasource);
		int    (*seek_func)  (void *datasource, int64_t offset, int whence);
		int    (*close_func) (void *datasource);
		long   (*tell_func)  (void *datasource);
	} ov_callbacks;

	typedef struct OggVorbis_File {
		void* datasource;
		int seekable;
		int64_t offset;
		int64_t end;
		ogg_sync_state oy;
		/*
			If the FILE handle isn't seekable (e.g. a pipe), 
			only the current stream appears
		*/
		int links;
		int64_t* offsets;
		int64_t* dataoffsets;
		long* serialnos;
		int64_t* pcmlengths;	// overloaded to maintain binary
								// compatibility; x2 size, stores both
								// beginning and end values
		vorbis_info* vi;
		vorbis_comment* vc;
		/* Decoding working state local storage */
		int64_t pcm_offset;
		int ready_state;
		long current_serialno;
		int current_link;
		double bittrack;
		double samptrack;
		ogg_stream_state os; /* take physical pages, weld into a logical stream of packets */
		vorbis_dsp_state vd; /* central working state for the packet->PCM decoder */
		vorbis_block     vb; /* local working space for packet->PCM decode */
		ov_callbacks callbacks;
	} OggVorbis_File;

	int ov_clear(OggVorbis_File*);
	int ov_fopen(const char *path, OggVorbis_File*);
	int ov_open(FILE*, OggVorbis_File*, const char* initial, long ibytes);
	int ov_open_callbacks(
		void* datasource,
		OggVorbis_File*,
		const char* initial,
		long ibytes,
		ov_callbacks);
	int ov_test(FILE *f, OggVorbis_File*, const char *initial, long ibytes);
	int ov_test_callbacks(
		void* datasource,
		OggVorbis_File*,
		const char *initial,
		long ibytes,
		ov_callbacks);
	int ov_test_open(OggVorbis_File*);
	long ov_bitrate(OggVorbis_File*, int i);
	long ov_bitrate_instant(OggVorbis_File*);
	long ov_streams(OggVorbis_File*);
	long ov_seekable(OggVorbis_File*);
	long ov_serialnumber(OggVorbis_File*, int i);
	int64_t ov_raw_total(OggVorbis_File*, int i);
	int64_t ov_pcm_total(OggVorbis_File*, int i);
	double ov_time_total(OggVorbis_File*, int i);
	int ov_raw_seek(OggVorbis_File*, int64_t pos);
	int ov_pcm_seek(OggVorbis_File*, int64_t pos);
	int ov_pcm_seek_page(OggVorbis_File*, int64_t pos);
	int ov_time_seek(OggVorbis_File*, double pos);
	int ov_time_seek_page(OggVorbis_File*, double pos);
	int ov_raw_seek_lap(OggVorbis_File*, int64_t pos);
	int ov_pcm_seek_lap(OggVorbis_File*, int64_t pos);
	int ov_pcm_seek_page_lap(OggVorbis_File*, int64_t pos);
	int ov_time_seek_lap(OggVorbis_File*, double pos);
	int ov_time_seek_page_lap(OggVorbis_File*, double pos);
	int64_t ov_raw_tell(OggVorbis_File*);
	int64_t ov_pcm_tell(OggVorbis_File*);
	double ov_time_tell(OggVorbis_File*);
	vorbis_info* ov_info(OggVorbis_File*, int link);
	vorbis_comment* ov_comment(OggVorbis_File*, int link);
	long ov_read_float(
		OggVorbis_File*,
		float*** pcm_channels,
		int samples,
		int* bitstream);
	long ov_read_filter(
		OggVorbis_File*,
		char* buffer,
		int length,
		int bigendianp,
		int word,
		int sgned,
		int *bitstream,
		void (*filter)(float** pcm, long channels, long samples, void* filter_param),
		void* filter_param);
	long ov_read(
		OggVorbis_File*,
		char* buffer,
		int length,
		int bigendianp,
		int word,
		int sgned,
		int* bitstream);
	int ov_crosslap(OggVorbis_File* vf1, OggVorbis_File* vf2);
	int ov_halfrate(OggVorbis_File*, int flag);
	int ov_halfrate_p(OggVorbis_File*);

]]

-- attempt to load statically-linked version, otherwise try dynamically-linked
if pcall(function()  assert(ffi.C.ov_open ~= nil)  end) then
	return ffi.C
else
	return ffi.load 'vorbisfile'
end
