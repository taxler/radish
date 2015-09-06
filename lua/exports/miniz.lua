
local ffi = require 'ffi'
require 'exports.typedef.bool32'
require 'exports.typedef.time_t'

local lib
ffi.cdef [[
	const char* mz_version();
]]
if assert(pcall(function()  assert(ffi.C.mz_version() ~= nil);  end)) then
	lib = ffi.C
else
	lib = ffi.load 'miniz'
end

ffi.cdef [=[

	enum {
		MZ_ADLER32_INIT = 1,
		MZ_CRC32_INIT = 0,
		MZ_DEFLATED = 8,
		//#define MZ_VERSION          "9.1.15"
		MZ_VERNUM = 0x91F0,
		MZ_VER_MAJOR = 9,
		MZ_VER_MINOR = 1,
		MZ_VER_REVISION = 15,
		MZ_VER_SUBREVISION = 0,

		MZ_DEFAULT_WINDOW_BITS = 15,

		MZ_DEFAULT_STRATEGY = 0,
		MZ_FILTERED = 1,
		MZ_HUFFMAN_ONLY = 2,
		MZ_RLE = 3,
		MZ_FIXED = 4,

		MZ_NO_FLUSH = 0,
		MZ_PARTIAL_FLUSH = 1,
		MZ_SYNC_FLUSH = 2,
		MZ_FULL_FLUSH = 3,
		MZ_FINISH = 4,
		MZ_BLOCK = 5,

		MZ_OK = 0,
		MZ_STREAM_END = 1,
		MZ_NEED_DICT = 2,
		MZ_ERRNO = -1,
		MZ_STREAM_ERROR = -2,
		MZ_DATA_ERROR = -3,
		MZ_MEM_ERROR = -4,

		MZ_BUF_ERROR = -5,
		MZ_VERSION_ERROR = -6,
		MZ_PARAM_ERROR = -10000,

		MZ_NO_COMPRESSION = 0,
		MZ_BEST_SPEED = 1,
		MZ_BEST_COMPRESSION = 9,
		MZ_UBER_COMPRESSION = 10,
		MZ_DEFAULT_LEVEL = 6,
		MZ_DEFAULT_COMPRESSION = -1,

		MZ_ZIP_MAX_IO_BUF_SIZE = 64 * 1024,
		MZ_ZIP_MAX_ARCHIVE_FILENAME_SIZE = 260,
		MZ_ZIP_MAX_ARCHIVE_FILE_COMMENT_SIZE = 256
	};
	typedef enum {
		MZ_ZIP_MODE_INVALID = 0,
		MZ_ZIP_MODE_READING = 1,
		MZ_ZIP_MODE_WRITING = 2,
		MZ_ZIP_MODE_WRITING_HAS_BEEN_FINALIZED = 3
	} mz_zip_mode;

	typedef enum mz_zip_flags {
		MZ_ZIP_FLAG_CASE_SENSITIVE                = 0x0100,
		MZ_ZIP_FLAG_IGNORE_PATH                   = 0x0200,
		MZ_ZIP_FLAG_COMPRESSED_DATA               = 0x0400,
		MZ_ZIP_FLAG_DO_NOT_SORT_CENTRAL_DIRECTORY = 0x0800
	} mz_zip_flags;

	enum {
		TINFL_FLAG_PARSE_ZLIB_HEADER = 1,
		TINFL_FLAG_HAS_MORE_INPUT = 2,
		TINFL_FLAG_USING_NON_WRAPPING_OUTPUT_BUF = 4,
		TINFL_FLAG_COMPUTE_ADLER32 = 8,

		TINFL_DECOMPRESS_MEM_TO_MEM_FAILED = -1,

		TDEFL_MAX_HUFF_TABLES = 3,
		TDEFL_MAX_HUFF_SYMBOLS_0 = 288,
		TDEFL_MAX_HUFF_SYMBOLS_1 = 32,
		TDEFL_MAX_HUFF_SYMBOLS_2 = 19,
		TDEFL_LZ_DICT_SIZE = 32768,
		TDEFL_LZ_DICT_SIZE_MASK = TDEFL_LZ_DICT_SIZE - 1,
		TDEFL_MIN_MATCH_LEN = 3,
		TDEFL_MAX_MATCH_LEN = 258,

		TDEFL_LZ_CODE_BUF_SIZE = 64 * 1024,
		TDEFL_OUT_BUF_SIZE = (TDEFL_LZ_CODE_BUF_SIZE * 13 ) / 10,
		TDEFL_MAX_HUFF_SYMBOLS = 288,
		TDEFL_LZ_HASH_BITS = 15,
		TDEFL_LEVEL1_HASH_SIZE_MASK = 4095,
		TDEFL_LZ_HASH_SHIFT = (TDEFL_LZ_HASH_BITS + 2) / 3,
		TDEFL_LZ_HASH_SIZE = 1 << TDEFL_LZ_HASH_BITS,

		TDEFL_WRITE_ZLIB_HEADER             = 0x01000,
		TDEFL_COMPUTE_ADLER32               = 0x02000,
		TDEFL_GREEDY_PARSING_FLAG           = 0x04000,
		TDEFL_NONDETERMINISTIC_PARSING_FLAG = 0x08000,
		TDEFL_RLE_MATCHES                   = 0x10000,
		TDEFL_FILTER_MATCHES                = 0x20000,
		TDEFL_FORCE_ALL_STATIC_BLOCKS       = 0x40000,
		TDEFL_FORCE_ALL_RAW_BLOCKS          = 0x80000,

		TDEFL_LESS_MEMORY = 0,

		TDEFL_HUFFMAN_ONLY = 0,
		TDEFL_DEFAULT_MAX_PROBES = 128,
		TDEFL_MAX_PROBES_MASK = 0xFFF,

		TINFL_MAX_HUFF_TABLES = 3,
		TINFL_MAX_HUFF_SYMBOLS_0 = 288,
		TINFL_MAX_HUFF_SYMBOLS_1 = 32,
		TINFL_MAX_HUFF_SYMBOLS_2 = 19,
		TINFL_FAST_LOOKUP_BITS = 10,
		TINFL_FAST_LOOKUP_SIZE = 1 << TINFL_FAST_LOOKUP_BITS,

		TINFL_LZ_DICT_SIZE = 32768
	};

	typedef enum {
		TDEFL_STATUS_BAD_PARAM = -2,
		TDEFL_STATUS_PUT_BUF_FAILED = -1,
		TDEFL_STATUS_OKAY = 0,
		TDEFL_STATUS_DONE = 1,
	} tdefl_status;

	typedef enum {
		TDEFL_NO_FLUSH = 0,
		TDEFL_SYNC_FLUSH = 2,
		TDEFL_FULL_FLUSH = 3,
		TDEFL_FINISH = 4
	} tdefl_flush;

	typedef enum {
		TINFL_STATUS_BAD_PARAM = -3,
		TINFL_STATUS_ADLER32_MISMATCH = -2,
		TINFL_STATUS_FAILED = -1,
		TINFL_STATUS_DONE = 0,
		TINFL_STATUS_NEEDS_MORE_INPUT = 1,
		TINFL_STATUS_HAS_MORE_OUTPUT = 2
	} tinfl_status;

	/*
	#if MINIZ_HAS_64BIT_REGISTERS
	#define TINFL_USE_64BIT_BITBUF 1
	#endif

	#if TINFL_USE_64BIT_BITBUF
	typedef uint64_t tinfl_bit_buf_t;
	#define TINFL_BITBUF_SIZE (64)
	#else
	*/
	typedef uint32_t tinfl_bit_buf_t;
	enum { TINFL_BITBUF_SIZE = 32 };
	/*
	#endif
	*/

	typedef struct mz_internal_state mz_internal_state;
	typedef struct mz_zip_internal_state mz_zip_internal_state;

	typedef void *(*mz_alloc_func)(void *opaque, size_t items, size_t size);
	typedef void (*mz_free_func)(void *opaque, void *address);
	typedef void *(*mz_realloc_func)(void *opaque, void *address, size_t items, size_t size);
	typedef size_t (*mz_file_read_func)(void *pOpaque, uint64_t file_ofs, void *pBuf, size_t n);
	typedef size_t (*mz_file_write_func)(void *pOpaque, uint64_t file_ofs, const void *pBuf, size_t n);
	typedef int (*tinfl_put_buf_func_ptr)(const void* pBuf, int len, void* userdata);
	typedef bool32 (*tdefl_put_buf_func_ptr)(const void* buf, int len, void* userdata);

	typedef struct mz_stream {
			const unsigned char *next_in;
			unsigned int avail_in;
			uint32_t total_in;

			unsigned char *next_out;
			unsigned int avail_out;
			uint32_t total_out;

			char *msg;
			mz_internal_state *state;

			mz_alloc_func zalloc;
			mz_free_func zfree;
			void *opaque;

			int data_type;
			uint32_t adler;
			uint32_t reserved;
	} mz_stream;

	typedef struct mz_zip_archive_file_stat {
			uint32_t m_file_index;
			uint32_t m_central_dir_ofs;
			uint16_t m_version_made_by;
			uint16_t m_version_needed;
			uint16_t m_bit_flag;
			uint16_t m_method;
			time_t m_time;
			uint32_t m_crc32;
			uint64_t m_comp_size;
			uint64_t m_uncomp_size;
			uint16_t m_internal_attr;
			uint32_t m_external_attr;
			uint64_t m_local_header_ofs;
			uint32_t m_comment_size;
			char m_filename[MZ_ZIP_MAX_ARCHIVE_FILENAME_SIZE];
			char m_comment[MZ_ZIP_MAX_ARCHIVE_FILE_COMMENT_SIZE];
	} mz_zip_archive_file_stat;

	typedef struct mz_zip_archive {
			uint64_t m_archive_size;
			uint64_t m_central_directory_file_ofs;
			uint32_t m_total_files;
			mz_zip_mode m_zip_mode;

			uint32_t m_file_offset_alignment;

			mz_alloc_func m_pAlloc;
			mz_free_func m_pFree;
			mz_realloc_func m_pRealloc;
			void *m_pAlloc_opaque;

			mz_file_read_func m_pRead;
			mz_file_write_func m_pWrite;
			void *m_pIO_opaque;

			mz_zip_internal_state *m_pState;

	} mz_zip_archive;

	typedef struct tdefl_compressor {
			tdefl_put_buf_func_ptr m_pPut_buf_func;
			void *m_pPut_buf_user;
			uint32_t m_flags, m_max_probes[2];
			int m_greedy_parsing;
			uint32_t m_adler32, m_lookahead_pos, m_lookahead_size, m_dict_size;
			uint8_t *m_pLZ_code_buf, *m_pLZ_flags, *m_pOutput_buf, *m_pOutput_buf_end;
			uint32_t m_num_flags_left, m_total_lz_bytes, m_lz_code_buf_dict_pos, m_bits_in, m_bit_buffer;
			uint32_t m_saved_match_dist, m_saved_match_len, m_saved_lit, m_output_flush_ofs, m_output_flush_remaining, m_finished, m_block_index, m_wants_to_finish;
			tdefl_status m_prev_return_status;
			const void *m_pIn_buf;
			void *m_pOut_buf;
			size_t *m_pIn_buf_size, *m_pOut_buf_size;
			tdefl_flush m_flush;
			const uint8_t *m_pSrc;
			size_t m_src_buf_left, m_out_buf_ofs;
			uint8_t m_dict[TDEFL_LZ_DICT_SIZE + TDEFL_MAX_MATCH_LEN - 1];
			uint16_t m_huff_count[TDEFL_MAX_HUFF_TABLES][TDEFL_MAX_HUFF_SYMBOLS];
			uint16_t m_huff_codes[TDEFL_MAX_HUFF_TABLES][TDEFL_MAX_HUFF_SYMBOLS];
			uint8_t m_huff_code_sizes[TDEFL_MAX_HUFF_TABLES][TDEFL_MAX_HUFF_SYMBOLS];
			uint8_t m_lz_code_buf[TDEFL_LZ_CODE_BUF_SIZE];
			uint16_t m_next[TDEFL_LZ_DICT_SIZE];
			uint16_t m_hash[TDEFL_LZ_HASH_SIZE];
			uint8_t m_output_buf[TDEFL_OUT_BUF_SIZE];
	} tdefl_compressor;

	typedef struct tinfl_huff_table {
			uint8_t m_code_size[TINFL_MAX_HUFF_SYMBOLS_0];
			int16_t m_look_up[TINFL_FAST_LOOKUP_SIZE], m_tree[TINFL_MAX_HUFF_SYMBOLS_0 * 2];
	} tinfl_huff_table;

	typedef struct tinfl_decompressor {
			uint32_t m_state, m_num_bits, m_zhdr0, m_zhdr1, m_z_adler32, m_final, m_type, m_check_adler32, m_dist, m_counter, m_num_extra, m_table_sizes[TINFL_MAX_HUFF_TABLES];
			tinfl_bit_buf_t m_bit_buf;
			size_t m_dist_from_out_buf_start;
			tinfl_huff_table m_tables[TINFL_MAX_HUFF_TABLES];
			uint8_t m_raw_header[4], m_len_codes[TINFL_MAX_HUFF_SYMBOLS_0 + TINFL_MAX_HUFF_SYMBOLS_1 + 137];
	} tinfl_decompressor;

	void mz_free(void*);
	uint32_t mz_adler32(uint32_t adler, const unsigned char *ptr, size_t buf_len);
	uint32_t mz_crc32(uint32_t crc, const unsigned char *ptr, size_t buf_len);
	int mz_deflateInit(mz_stream*, int level);
	int mz_deflateInit2(mz_stream*, int level, int method, int window_bits, int mem_level, int strategy);
	int mz_deflateReset(mz_stream*);
	int mz_deflate(mz_stream*, int flush);
	int mz_deflateEnd(mz_stream*);
	uint32_t mz_deflateBound(mz_stream*, uint32_t source_len);
	int mz_compress(unsigned char *pDest, uint32_t *pDest_len, const unsigned char *pSource, uint32_t source_len);
	int mz_compress2(unsigned char *pDest, uint32_t *pDest_len, const unsigned char *pSource, uint32_t source_len, int level);
	uint32_t mz_compressBound(uint32_t source_len);
	int mz_inflateInit(mz_stream*);
	int mz_inflateInit2(mz_stream*, int window_bits);
	int mz_inflate(mz_stream*, int flush);
	int mz_inflateEnd(mz_stream*);
	int mz_uncompress(unsigned char *pDest, uint32_t *pDest_len, const unsigned char *pSource, uint32_t source_len);
	const char *mz_error(int err);
	bool32 mz_zip_reader_init(mz_zip_archive*, uint64_t size, uint32_t flags);
	bool32 mz_zip_reader_init_mem(mz_zip_archive*, const void *pMem, size_t size, uint32_t flags);
	bool32 mz_zip_reader_init_file(mz_zip_archive*, const char *pFilename, uint32_t flags);
	uint32_t mz_zip_reader_get_num_files(mz_zip_archive*);
	bool32 mz_zip_reader_file_stat(mz_zip_archive*, uint32_t file_index, mz_zip_archive_file_stat *pStat);
	bool32 mz_zip_reader_is_file_a_directory(mz_zip_archive*, uint32_t file_index);
	bool32 mz_zip_reader_is_file_encrypted(mz_zip_archive*, uint32_t file_index);
	uint32_t mz_zip_reader_get_filename(mz_zip_archive*, uint32_t file_index, char *pFilename, uint32_t filename_buf_size);
	int mz_zip_reader_locate_file(mz_zip_archive*, const char *pName, const char *pComment, uint32_t flags);
	bool32 mz_zip_reader_extract_to_mem_no_alloc(mz_zip_archive*, uint32_t file_index, void *pBuf, size_t buf_size, uint32_t flags, void *pUser_read_buf, size_t user_read_buf_size);
	bool32 mz_zip_reader_extract_file_to_mem_no_alloc(mz_zip_archive*, const char *pFilename, void *pBuf, size_t buf_size, uint32_t flags, void *pUser_read_buf, size_t user_read_buf_size);
	bool32 mz_zip_reader_extract_to_mem(mz_zip_archive*, uint32_t file_index, void *pBuf, size_t buf_size, uint32_t flags);
	bool32 mz_zip_reader_extract_file_to_mem(mz_zip_archive*, const char *pFilename, void *pBuf, size_t buf_size, uint32_t flags);
	void *mz_zip_reader_extract_to_heap(mz_zip_archive*, uint32_t file_index, size_t *pSize, uint32_t flags);
	void *mz_zip_reader_extract_file_to_heap(mz_zip_archive*, const char *pFilename, size_t *pSize, uint32_t flags);
	bool32 mz_zip_reader_extract_to_callback(mz_zip_archive*, uint32_t file_index, mz_file_write_func pCallback, void *pOpaque, uint32_t flags);
	bool32 mz_zip_reader_extract_file_to_callback(mz_zip_archive*, const char *pFilename, mz_file_write_func pCallback, void *pOpaque, uint32_t flags);
	bool32 mz_zip_reader_extract_to_file(mz_zip_archive*, uint32_t file_index, const char *pDst_filename, uint32_t flags);
	bool32 mz_zip_reader_extract_file_to_file(mz_zip_archive*, const char *pArchive_filename, const char *pDst_filename, uint32_t flags);
	bool32 mz_zip_reader_end(mz_zip_archive*);
	bool32 mz_zip_writer_init(mz_zip_archive*, uint64_t existing_size);
	bool32 mz_zip_writer_init_heap(mz_zip_archive*, size_t size_to_reserve_at_beginning, size_t initial_allocation_size);
	bool32 mz_zip_writer_init_file(mz_zip_archive*, const char *pFilename, uint64_t size_to_reserve_at_beginning);
	bool32 mz_zip_writer_init_from_reader(mz_zip_archive*, const char *pFilename);
	bool32 mz_zip_writer_add_mem(mz_zip_archive*, const char *pArchive_name, const void *pBuf, size_t buf_size, uint32_t level_and_flags);
	bool32 mz_zip_writer_add_mem_ex(mz_zip_archive*, const char *pArchive_name, const void *pBuf, size_t buf_size, const void *pComment, uint16_t comment_size, uint32_t level_and_flags, uint64_t uncomp_size, uint32_t uncomp_crc32);
	bool32 mz_zip_writer_add_file(mz_zip_archive*, const char *pArchive_name, const char *pSrc_filename, const void *pComment, uint16_t comment_size, uint32_t level_and_flags);
	bool32 mz_zip_writer_add_from_zip_reader(mz_zip_archive*, mz_zip_archive *pSource_zip, uint32_t file_index);
	bool32 mz_zip_writer_finalize_archive(mz_zip_archive*);
	bool32 mz_zip_writer_finalize_heap_archive(mz_zip_archive*, void **pBuf, size_t *pSize);
	bool32 mz_zip_writer_end(mz_zip_archive*);
	bool32 mz_zip_add_mem_to_archive_file_in_place(
		const char *pZip_filename,
		const char *pArchive_name,
		const void *pBuf, size_t buf_size,
		const void *pComment, uint16_t comment_size,
		uint32_t level_and_flags);
	void *mz_zip_extract_archive_file_to_heap(
		const char *pZip_filename,
		const char *pArchive_name,
		size_t *pSize,
		uint32_t zip_flags);
	void *tinfl_decompress_mem_to_heap(
		const void *pSrc_buf, size_t src_buf_len,
		size_t *pOut_len,
		int flags);
	size_t tinfl_decompress_mem_to_mem(
		void *pOut_buf, size_t out_buf_len,
		const void *pSrc_buf, size_t src_buf_len,
		int flags);
	int tinfl_decompress_mem_to_callback(
		const void* pIn_buf,
		size_t* pIn_buf_size,
		tinfl_put_buf_func_ptr,
		void* userdata,
		int flags);
	tinfl_status tinfl_decompress(
		tinfl_decompressor*,
		const uint8_t* pIn_buf_next,
		size_t* pIn_buf_size,
		uint8_t* pOut_buf_start,
		uint8_t *pOut_buf_next,
		size_t *pOut_buf_size,
		uint32_t decomp_flags);
	void *tdefl_compress_mem_to_heap(const void *pSrc_buf, size_t src_buf_len, size_t *pOut_len, int flags);
	size_t tdefl_compress_mem_to_mem(void *pOut_buf, size_t out_buf_len, const void *pSrc_buf, size_t src_buf_len, int flags);
	void *tdefl_write_image_to_png_file_in_memory(
		const void* image_data, int w, int h, int channel_count,
		size_t *pLen_out);
	void *tdefl_write_image_to_png_file_in_memory_ex(
		const void* image_data, int w, int h, int channel_count,
		size_t *pLen_out,
		uint32_t level,
		bool32 flip);
	bool32 tdefl_compress_mem_to_output(
		const void* buf, size_t buf_len,
		tdefl_put_buf_func_ptr, void* userdata,
		int flags);
	tdefl_status tdefl_init(
		tdefl_compressor*,
		tdefl_put_buf_func_ptr, void* userdata,
		int flags);
	tdefl_status tdefl_compress(
		tdefl_compressor*,
		const void *pIn_buf,
		size_t *pIn_buf_size,
		void *pOut_buf,
		size_t *pOut_buf_size,
		tdefl_flush);
	tdefl_status tdefl_compress_buffer(tdefl_compressor*, const void* buf, size_t buf_size, tdefl_flush);
	tdefl_status tdefl_get_prev_return_status(tdefl_compressor*);
	uint32_t tdefl_get_adler32(tdefl_compressor*);
	uint32_t tdefl_create_comp_flags_from_zip_params(int level, int window_bits, int strategy);

	/*
	#define tinfl_init(r) do { (r)->m_state = 0; } MZ_MACRO_END
	#define tinfl_get_adler32(r) (r)->m_check_adler32
	*/

]=]

return lib
