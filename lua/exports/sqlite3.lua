
local ffi = require 'ffi'

ffi.cdef [[

	const char sqlite3_version[];

]]

assert(ffi.C.sqlite3_version ~= nil)

-- attempt to load statically-linked version, otherwise try dynamically-linked
local lib
if pcall(function()  assert(ffi.C.sqlite3_version ~= nil)  end) then
	lib = ffi.C
else
	lib = ffi.load 'sqlite3'
end

ffi.cdef [[
	const char* __stdcall sqlite3_libversion();
	const char* __stdcall sqlite3_sourceid();
	int __stdcall sqlite3_libversion_number();
	int __stdcall sqlite3_compileoption_used(const char* zOptName);
	const char* __stdcall sqlite3_compileoption_get(int N);
	int __stdcall sqlite3_threadsafe();

	typedef struct sqlite3 sqlite3;

	int __stdcall sqlite3_close(sqlite3*);
	int __stdcall sqlite3_close_v2(sqlite3*);

	typedef int (*sqlite3_callback)(void*, int, char**, char**);

	int __stdcall sqlite3_exec(
		sqlite3*,
		const char* sql,
		int (*callback)(void*, int, char**, char**),
		void*,
		char** errmsg);

	enum {
		SQLITE_OK          =   0,

		SQLITE_ERROR       =   1,
		SQLITE_INTERNAL    =   2,
		SQLITE_PERM        =   3,
		SQLITE_ABORT       =   4,
		SQLITE_BUSY        =   5,
		SQLITE_LOCKED      =   6,
		SQLITE_NOMEM       =   7,
		SQLITE_READONLY    =   8,
		SQLITE_INTERRUPT   =   9,
		SQLITE_IOERR       =  10,
		SQLITE_CORRUPT     =  11,
		SQLITE_NOTFOUND    =  12,
		SQLITE_FULL        =  13,
		SQLITE_CANTOPEN    =  14,
		SQLITE_PROTOCOL    =  15,
		SQLITE_EMPTY       =  16,
		SQLITE_SCHEMA      =  17,
		SQLITE_TOOBIG      =  18,
		SQLITE_CONSTRAINT  =  19,
		SQLITE_MISMATCH    =  20,
		SQLITE_MISUSE      =  21,
		SQLITE_NOLFS       =  22,
		SQLITE_AUTH        =  23,
		SQLITE_FORMAT      =  24,
		SQLITE_RANGE       =  25,
		SQLITE_NOTADB      =  26,
		SQLITE_NOTICE      =  27,
		SQLITE_WARNING     =  28,
		SQLITE_ROW         = 100,
		SQLITE_DONE        = 101,

		SQLITE_IOERR_READ              = (SQLITE_IOERR | (1<<8)),
		SQLITE_IOERR_SHORT_READ        = (SQLITE_IOERR | (2<<8)),
		SQLITE_IOERR_WRITE             = (SQLITE_IOERR | (3<<8)),
		SQLITE_IOERR_FSYNC             = (SQLITE_IOERR | (4<<8)),
		SQLITE_IOERR_DIR_FSYNC         = (SQLITE_IOERR | (5<<8)),
		SQLITE_IOERR_TRUNCATE          = (SQLITE_IOERR | (6<<8)),
		SQLITE_IOERR_FSTAT             = (SQLITE_IOERR | (7<<8)),
		SQLITE_IOERR_UNLOCK            = (SQLITE_IOERR | (8<<8)),
		SQLITE_IOERR_RDLOCK            = (SQLITE_IOERR | (9<<8)),
		SQLITE_IOERR_DELETE            = (SQLITE_IOERR | (10<<8)),
		SQLITE_IOERR_BLOCKED           = (SQLITE_IOERR | (11<<8)),
		SQLITE_IOERR_NOMEM             = (SQLITE_IOERR | (12<<8)),
		SQLITE_IOERR_ACCESS            = (SQLITE_IOERR | (13<<8)),
		SQLITE_IOERR_CHECKRESERVEDLOCK = (SQLITE_IOERR | (14<<8)),
		SQLITE_IOERR_LOCK              = (SQLITE_IOERR | (15<<8)),
		SQLITE_IOERR_CLOSE             = (SQLITE_IOERR | (16<<8)),
		SQLITE_IOERR_DIR_CLOSE         = (SQLITE_IOERR | (17<<8)),
		SQLITE_IOERR_SHMOPEN           = (SQLITE_IOERR | (18<<8)),
		SQLITE_IOERR_SHMSIZE           = (SQLITE_IOERR | (19<<8)),
		SQLITE_IOERR_SHMLOCK           = (SQLITE_IOERR | (20<<8)),
		SQLITE_IOERR_SHMMAP            = (SQLITE_IOERR | (21<<8)),
		SQLITE_IOERR_SEEK              = (SQLITE_IOERR | (22<<8)),
		SQLITE_IOERR_DELETE_NOENT      = (SQLITE_IOERR | (23<<8)),
		SQLITE_IOERR_MMAP              = (SQLITE_IOERR | (24<<8)),
		SQLITE_IOERR_GETTEMPPATH       = (SQLITE_IOERR | (25<<8)),
		SQLITE_IOERR_CONVPATH          = (SQLITE_IOERR | (26<<8)),
		SQLITE_LOCKED_SHAREDCACHE      = (SQLITE_LOCKED |  (1<<8)),
		SQLITE_BUSY_RECOVERY           = (SQLITE_BUSY   |  (1<<8)),
		SQLITE_BUSY_SNAPSHOT           = (SQLITE_BUSY   |  (2<<8)),
		SQLITE_CANTOPEN_NOTEMPDIR      = (SQLITE_CANTOPEN | (1<<8)),
		SQLITE_CANTOPEN_ISDIR          = (SQLITE_CANTOPEN | (2<<8)),
		SQLITE_CANTOPEN_FULLPATH       = (SQLITE_CANTOPEN | (3<<8)),
		SQLITE_CANTOPEN_CONVPATH       = (SQLITE_CANTOPEN | (4<<8)),
		SQLITE_CORRUPT_VTAB            = (SQLITE_CORRUPT | (1<<8)),
		SQLITE_READONLY_RECOVERY       = (SQLITE_READONLY | (1<<8)),
		SQLITE_READONLY_CANTLOCK       = (SQLITE_READONLY | (2<<8)),
		SQLITE_READONLY_ROLLBACK       = (SQLITE_READONLY | (3<<8)),
		SQLITE_READONLY_DBMOVED        = (SQLITE_READONLY | (4<<8)),
		SQLITE_ABORT_ROLLBACK          = (SQLITE_ABORT | (2<<8)),
		SQLITE_CONSTRAINT_CHECK        = (SQLITE_CONSTRAINT | (1<<8)),
		SQLITE_CONSTRAINT_COMMITHOOK   = (SQLITE_CONSTRAINT | (2<<8)),
		SQLITE_CONSTRAINT_FOREIGNKEY   = (SQLITE_CONSTRAINT | (3<<8)),
		SQLITE_CONSTRAINT_FUNCTION     = (SQLITE_CONSTRAINT | (4<<8)),
		SQLITE_CONSTRAINT_NOTNULL      = (SQLITE_CONSTRAINT | (5<<8)),
		SQLITE_CONSTRAINT_PRIMARYKEY   = (SQLITE_CONSTRAINT | (6<<8)),
		SQLITE_CONSTRAINT_TRIGGER      = (SQLITE_CONSTRAINT | (7<<8)),
		SQLITE_CONSTRAINT_UNIQUE       = (SQLITE_CONSTRAINT | (8<<8)),
		SQLITE_CONSTRAINT_VTAB         = (SQLITE_CONSTRAINT | (9<<8)),
		SQLITE_CONSTRAINT_ROWID        = (SQLITE_CONSTRAINT |(10<<8)),
		SQLITE_NOTICE_RECOVER_WAL      = (SQLITE_NOTICE | (1<<8)),
		SQLITE_NOTICE_RECOVER_ROLLBACK = (SQLITE_NOTICE | (2<<8)),
		SQLITE_WARNING_AUTOINDEX       = (SQLITE_WARNING | (1<<8)),
		SQLITE_AUTH_USER               = (SQLITE_AUTH | (1<<8)),

		SQLITE_OPEN_READONLY         = 0x00000001,
		SQLITE_OPEN_READWRITE        = 0x00000002,
		SQLITE_OPEN_CREATE           = 0x00000004,
		SQLITE_OPEN_DELETEONCLOSE    = 0x00000008,
		SQLITE_OPEN_EXCLUSIVE        = 0x00000010,
		SQLITE_OPEN_AUTOPROXY        = 0x00000020,
		SQLITE_OPEN_URI              = 0x00000040,
		SQLITE_OPEN_MEMORY           = 0x00000080,
		SQLITE_OPEN_MAIN_DB          = 0x00000100,
		SQLITE_OPEN_TEMP_DB          = 0x00000200,
		SQLITE_OPEN_TRANSIENT_DB     = 0x00000400,
		SQLITE_OPEN_MAIN_JOURNAL     = 0x00000800,
		SQLITE_OPEN_TEMP_JOURNAL     = 0x00001000,
		SQLITE_OPEN_SUBJOURNAL       = 0x00002000,
		SQLITE_OPEN_MASTER_JOURNAL   = 0x00004000,
		SQLITE_OPEN_NOMUTEX          = 0x00008000,
		SQLITE_OPEN_FULLMUTEX        = 0x00010000,
		SQLITE_OPEN_SHAREDCACHE      = 0x00020000,
		SQLITE_OPEN_PRIVATECACHE     = 0x00040000,
		SQLITE_OPEN_WAL              = 0x00080000,

		SQLITE_IOCAP_ATOMIC                 = 0x00000001,
		SQLITE_IOCAP_ATOMIC512              = 0x00000002,
		SQLITE_IOCAP_ATOMIC1K               = 0x00000004,
		SQLITE_IOCAP_ATOMIC2K               = 0x00000008,
		SQLITE_IOCAP_ATOMIC4K               = 0x00000010,
		SQLITE_IOCAP_ATOMIC8K               = 0x00000020,
		SQLITE_IOCAP_ATOMIC16K              = 0x00000040,
		SQLITE_IOCAP_ATOMIC32K              = 0x00000080,
		SQLITE_IOCAP_ATOMIC64K              = 0x00000100,
		SQLITE_IOCAP_SAFE_APPEND            = 0x00000200,
		SQLITE_IOCAP_SEQUENTIAL             = 0x00000400,
		SQLITE_IOCAP_UNDELETABLE_WHEN_OPEN  = 0x00000800,
		SQLITE_IOCAP_POWERSAFE_OVERWRITE    = 0x00001000,
		SQLITE_IOCAP_IMMUTABLE              = 0x00002000,

		SQLITE_LOCK_NONE          = 0,
		SQLITE_LOCK_SHARED        = 1,
		SQLITE_LOCK_RESERVED      = 2,
		SQLITE_LOCK_PENDING       = 3,
		SQLITE_LOCK_EXCLUSIVE     = 4,

		SQLITE_SYNC_NORMAL        = 0x00002,
		SQLITE_SYNC_FULL          = 0x00003,
		SQLITE_SYNC_DATAONLY      = 0x00010
	};

	typedef struct sqlite3_file sqlite3_file;

	typedef struct sqlite3_io_methods {
		int iVersion;
		int (*xClose)(sqlite3_file*);
		int (*xRead)(sqlite3_file*, void*, int iAmt, int64_t iOfst);
		int (*xWrite)(sqlite3_file*, const void*, int iAmt, int64_t iOfst);
		int (*xTruncate)(sqlite3_file*, int64_t size);
		int (*xSync)(sqlite3_file*, int flags);
		int (*xFileSize)(sqlite3_file*, int64_t* pSize);
		int (*xLock)(sqlite3_file*, int);
		int (*xUnlock)(sqlite3_file*, int);
		int (*xCheckReservedLock)(sqlite3_file*, int* pResOut);
		int (*xFileControl)(sqlite3_file*, int op, void* pArg);
		int (*xSectorSize)(sqlite3_file*);
		int (*xDeviceCharacteristics)(sqlite3_file*);

		int (*xShmMap)(sqlite3_file*, int iPg, int pgsz, int, void volatile**);
		int (*xShmLock)(sqlite3_file*, int offset, int n, int flags);
		void (*xShmBarrier)(sqlite3_file*);
		int (*xShmUnmap)(sqlite3_file*, int deleteFlag);

		int (*xFetch)(sqlite3_file*, int64_t iOfst, int iAmt, void** pp);
		int (*xUnfetch)(sqlite3_file*, int64_t iOfst, void* p);
	} sqlite3_io_methods;

	typedef struct sqlite3_file {
		const sqlite3_io_methods* pMethods;
	} sqlite3_file;

	enum {
		SQLITE_FCNTL_LOCKSTATE              =  1,
		SQLITE_FCNTL_GET_LOCKPROXYFILE      =  2,
		SQLITE_FCNTL_SET_LOCKPROXYFILE      =  3,
		SQLITE_FCNTL_LAST_ERRNO             =  4,
		SQLITE_FCNTL_SIZE_HINT              =  5,
		SQLITE_FCNTL_CHUNK_SIZE             =  6,
		SQLITE_FCNTL_FILE_POINTER           =  7,
		SQLITE_FCNTL_SYNC_OMITTED           =  8,
		SQLITE_FCNTL_WIN32_AV_RETRY         =  9,
		SQLITE_FCNTL_PERSIST_WAL            = 10,
		SQLITE_FCNTL_OVERWRITE              = 11,
		SQLITE_FCNTL_VFSNAME                = 12,
		SQLITE_FCNTL_POWERSAFE_OVERWRITE    = 13,
		SQLITE_FCNTL_PRAGMA                 = 14,
		SQLITE_FCNTL_BUSYHANDLER            = 15,
		SQLITE_FCNTL_TEMPFILENAME           = 16,
		SQLITE_FCNTL_MMAP_SIZE              = 18,
		SQLITE_FCNTL_TRACE                  = 19,
		SQLITE_FCNTL_HAS_MOVED              = 20,
		SQLITE_FCNTL_SYNC                   = 21,
		SQLITE_FCNTL_COMMIT_PHASETWO        = 22,
		SQLITE_FCNTL_WIN32_SET_HANDLE       = 23,
		SQLITE_FCNTL_WAL_BLOCK              = 24,
		SQLITE_FCNTL_ZIPVFS                 = 25,
		SQLITE_FCNTL_RBU                    = 26,

		SQLITE_GET_LOCKPROXYFILE      = SQLITE_FCNTL_GET_LOCKPROXYFILE,
		SQLITE_SET_LOCKPROXYFILE      = SQLITE_FCNTL_SET_LOCKPROXYFILE,
		SQLITE_LAST_ERRNO             = SQLITE_FCNTL_LAST_ERRNO
	};

	typedef struct sqlite3_mutex sqlite3_mutex;

	typedef struct sqlite3_vfs sqlite3_vfs;
	typedef void (*sqlite3_syscall_ptr)();
	struct sqlite3_vfs {
		int iVersion;
		int szOsFile;
		int mxPathname;
		sqlite3_vfs* pNext;
		const char* zName;
		void* pAppData;
		int (*xOpen)(sqlite3_vfs*, const char* zName, sqlite3_file*, int flags, int* pOutFlags);
		int (*xDelete)(sqlite3_vfs*, const char* zName, int syncDir);
		int (*xAccess)(sqlite3_vfs*, const char* zName, int flags, int* pResOut);
		int (*xFullPathname)(sqlite3_vfs*, const char* zName, int nOut, char* zOut);
		void* (*xDlOpen)(sqlite3_vfs*, const char* zFilename);
		void (*xDlError)(sqlite3_vfs*, int nByte, char* zErrMsg);
		void (*(*xDlSym)(sqlite3_vfs*, void*, const char* zSymbol))();
		void (*xDlClose)(sqlite3_vfs*, void*);
		int (*xRandomness)(sqlite3_vfs*, int nByte, char* zOut);
		int (*xSleep)(sqlite3_vfs*, int microseconds);
		int (*xCurrentTime)(sqlite3_vfs*, double*);
		int (*xGetLastError)(sqlite3_vfs*, int, char*);

		int (*xCurrentTimeInt64)(sqlite3_vfs*, int64_t*);

		int (*xSetSystemCall)(sqlite3_vfs*, const char* zName, sqlite3_syscall_ptr);
		sqlite3_syscall_ptr (*xGetSystemCall)(sqlite3_vfs*, const char* zName);
		const char* (*xNextSystemCall)(sqlite3_vfs*, const char* zName);
	};

	enum {
		SQLITE_ACCESS_EXISTS    = 0,
		SQLITE_ACCESS_READWRITE = 1,
		SQLITE_ACCESS_READ      = 2,

		SQLITE_SHM_UNLOCK       = 1,
		SQLITE_SHM_LOCK         = 2,
		SQLITE_SHM_SHARED       = 4,
		SQLITE_SHM_EXCLUSIVE    = 8,

		SQLITE_SHM_NLOCK        = 8
	};

	int __stdcall sqlite3_initialize();
	int __stdcall sqlite3_shutdown();
	int __stdcall sqlite3_os_init();
	int __stdcall sqlite3_os_end();

	int __cdecl sqlite3_config(int, ...);

	int __cdecl sqlite3_db_config(sqlite3*, int op, ...);

	typedef struct sqlite3_mem_methods sqlite3_mem_methods;
	struct sqlite3_mem_methods {
		void* (*xMalloc)(int);
		void (*xFree)(void*);
		void* (*xRealloc)(void*, int);
		int (*xSize)(void*);
		int (*xRoundup)(int);
		int (*xInit)(void*);
		void (*xShutdown)(void*);
		void* pAppData;
	};

	enum {
		SQLITE_CONFIG_SINGLETHREAD  = 1,
		SQLITE_CONFIG_MULTITHREAD   = 2,
		SQLITE_CONFIG_SERIALIZED    = 3,
		SQLITE_CONFIG_MALLOC        = 4,
		SQLITE_CONFIG_GETMALLOC     = 5,
		SQLITE_CONFIG_SCRATCH       = 6,
		SQLITE_CONFIG_PAGECACHE     = 7,
		SQLITE_CONFIG_HEAP          = 8,
		SQLITE_CONFIG_MEMSTATUS     = 9,
		SQLITE_CONFIG_MUTEX        = 10,
		SQLITE_CONFIG_GETMUTEX     = 11,

		SQLITE_CONFIG_LOOKASIDE    = 13,
		SQLITE_CONFIG_PCACHE       = 14,
		SQLITE_CONFIG_GETPCACHE    = 15,
		SQLITE_CONFIG_LOG          = 16,
		SQLITE_CONFIG_URI          = 17,
		SQLITE_CONFIG_PCACHE2      = 18,
		SQLITE_CONFIG_GETPCACHE2   = 19,
		SQLITE_CONFIG_COVERING_INDEX_SCAN = 20,
		SQLITE_CONFIG_SQLLOG       = 21,
		SQLITE_CONFIG_MMAP_SIZE    = 22,
		SQLITE_CONFIG_WIN32_HEAPSIZE      = 23,
		SQLITE_CONFIG_PCACHE_HDRSZ        = 24,
		SQLITE_CONFIG_PMASZ               = 25,


		SQLITE_DBCONFIG_LOOKASIDE       = 1001,
		SQLITE_DBCONFIG_ENABLE_FKEY     = 1002,
		SQLITE_DBCONFIG_ENABLE_TRIGGER  = 1003
	};

	int __stdcall sqlite3_extended_result_codes(sqlite3*, int onoff);
	int64_t __stdcall sqlite3_last_insert_rowid(sqlite3*);
	int __stdcall sqlite3_changes(sqlite3*);
	int __stdcall sqlite3_total_changes(sqlite3*);
	void __stdcall sqlite3_interrupt(sqlite3*);

	int __stdcall sqlite3_complete(const char* sql);
	int __stdcall sqlite3_complete16(const void* sql);

	int __stdcall sqlite3_busy_handler(sqlite3*, int(*)(void*, int), void*);
	int __stdcall sqlite3_busy_timeout(sqlite3*, int ms);

	int __stdcall sqlite3_get_table(
		sqlite3* db,
		const char* zSql,
		char*** pazResult,
		int* pnRow,
		int* pnColumn,
		char** pzErrmsg);
	void __stdcall sqlite3_free_table(char** result);

	char* __cdecl sqlite3_mprintf(const char*, ...);
	char* __stdcall sqlite3_vmprintf(const char*, va_list);
	char* __cdecl sqlite3_snprintf(int, char*, const char*, ...);
	char* __stdcall sqlite3_vsnprintf(int, char*, const char*, va_list);

	void* __stdcall sqlite3_malloc(int);
	void* __stdcall sqlite3_malloc64(uint64_t);
	void* __stdcall sqlite3_realloc(void*, int);
	void* __stdcall sqlite3_realloc64(void*, uint64_t);
	void __stdcall sqlite3_free(void*);
	uint64_t __stdcall sqlite3_msize(void*);

	int64_t __stdcall sqlite3_memory_used();
	int64_t __stdcall sqlite3_memory_highwater(int resetFlag);

	void __stdcall sqlite3_randomness(int N, void* P);

	int __stdcall sqlite3_set_authorizer(
		sqlite3*,
		int (*xAuth)(void*, int, const char*, const char*, const char*, const char*),
		void* pUserData);

	enum {
		SQLITE_DENY   = 1,
		SQLITE_IGNORE = 2,

		SQLITE_CREATE_INDEX          = 1,
		SQLITE_CREATE_TABLE          = 2,
		SQLITE_CREATE_TEMP_INDEX     = 3,
		SQLITE_CREATE_TEMP_TABLE     = 4,
		SQLITE_CREATE_TEMP_TRIGGER   = 5,
		SQLITE_CREATE_TEMP_VIEW      = 6,
		SQLITE_CREATE_TRIGGER        = 7,
		SQLITE_CREATE_VIEW           = 8,
		SQLITE_DELETE                = 9,
		SQLITE_DROP_INDEX           = 10,
		SQLITE_DROP_TABLE           = 11,
		SQLITE_DROP_TEMP_INDEX      = 12,
		SQLITE_DROP_TEMP_TABLE      = 13,
		SQLITE_DROP_TEMP_TRIGGER    = 14,
		SQLITE_DROP_TEMP_VIEW       = 15,
		SQLITE_DROP_TRIGGER         = 16,
		SQLITE_DROP_VIEW            = 17,
		SQLITE_INSERT               = 18,
		SQLITE_PRAGMA               = 19,
		SQLITE_READ                 = 20,
		SQLITE_SELECT               = 21,
		SQLITE_TRANSACTION          = 22,
		SQLITE_UPDATE               = 23,
		SQLITE_ATTACH               = 24,
		SQLITE_DETACH               = 25,
		SQLITE_ALTER_TABLE          = 26,
		SQLITE_REINDEX              = 27,
		SQLITE_ANALYZE              = 28,
		SQLITE_CREATE_VTABLE        = 29,
		SQLITE_DROP_VTABLE          = 30,
		SQLITE_FUNCTION             = 31,
		SQLITE_SAVEPOINT            = 32,
		SQLITE_COPY                  = 0,
		SQLITE_RECURSIVE            = 33,
	};

	void* __stdcall sqlite3_trace(sqlite3*, void(*xTrace)(void*, const char*), void*);
	/* SQLITE_EXPERIMENTAL */ void* __stdcall sqlite3_profile(sqlite3*,
		 void(*xProfile)(void*, const char*, uint64_t), void*);

	void __stdcall sqlite3_progress_handler(sqlite3*, int, int(*)(void*), void*);

	int __stdcall sqlite3_open(
		const char* filename,
		sqlite3** ppDb);
	int __stdcall sqlite3_open16(
		const void* filename,
		sqlite3** ppDb);
	int __stdcall sqlite3_open_v2(
		const char* filename,
		sqlite3** ppDb,
		int flags,
		const char* zVfs);

	const char* __stdcall sqlite3_uri_parameter(const char* zFilename, const char* zParam);
	int __stdcall sqlite3_uri_boolean(const char* zFile, const char* zParam, int bDefault);
	int64_t __stdcall sqlite3_uri_int64(const char*, const char*, int64_t);

	int __stdcall sqlite3_errcode(sqlite3* db);
	int __stdcall sqlite3_extended_errcode(sqlite3* db);
	const char* __stdcall sqlite3_errmsg(sqlite3*);
	const void* __stdcall sqlite3_errmsg16(sqlite3*);
	const char* __stdcall sqlite3_errstr(int);

	typedef struct sqlite3_stmt sqlite3_stmt;

	int __stdcall sqlite3_limit(sqlite3*, int id, int newVal);

	enum {
		SQLITE_LIMIT_LENGTH                    = 0,
		SQLITE_LIMIT_SQL_LENGTH                = 1,
		SQLITE_LIMIT_COLUMN                    = 2,
		SQLITE_LIMIT_EXPR_DEPTH                = 3,
		SQLITE_LIMIT_COMPOUND_SELECT           = 4,
		SQLITE_LIMIT_VDBE_OP                   = 5,
		SQLITE_LIMIT_FUNCTION_ARG              = 6,
		SQLITE_LIMIT_ATTACHED                  = 7,
		SQLITE_LIMIT_LIKE_PATTERN_LENGTH       = 8,
		SQLITE_LIMIT_VARIABLE_NUMBER           = 9,
		SQLITE_LIMIT_TRIGGER_DEPTH            = 10,
		SQLITE_LIMIT_WORKER_THREADS           = 11
	};

	int __stdcall sqlite3_prepare(
		sqlite3* db,
		const char* zSql,
		int nByte,
		sqlite3_stmt** ppStmt,
		const char** pzTail);
	int __stdcall sqlite3_prepare_v2(
		sqlite3* db,
		const char* zSql,
		int nByte,
		sqlite3_stmt** ppStmt,
		const char** pzTail);
	int __stdcall sqlite3_prepare16(
		sqlite3* db,
		const void* zSql,
		int nByte,
		sqlite3_stmt** ppStmt,
		const void** pzTail);
	int __stdcall sqlite3_prepare16_v2(
		sqlite3* db,
		const void* zSql,
		int nByte,
		sqlite3_stmt** ppStmt,
		const void** pzTail);

	const char* __stdcall sqlite3_sql(sqlite3_stmt* pStmt);

	int __stdcall sqlite3_stmt_readonly(sqlite3_stmt* pStmt);

	int __stdcall sqlite3_stmt_busy(sqlite3_stmt*);

	typedef struct Mem sqlite3_value;

	typedef struct sqlite3_context sqlite3_context;

	int __stdcall sqlite3_bind_blob(sqlite3_stmt*, int, const void*, int n, void(*)(void*));
	int __stdcall sqlite3_bind_blob64(sqlite3_stmt*, int, const void*, uint64_t, void(*)(void*));
	int __stdcall sqlite3_bind_double(sqlite3_stmt*, int, double);
	int __stdcall sqlite3_bind_int(sqlite3_stmt*, int, int);
	int __stdcall sqlite3_bind_int64(sqlite3_stmt*, int, int64_t);
	int __stdcall sqlite3_bind_null(sqlite3_stmt*, int);
	int __stdcall sqlite3_bind_text(sqlite3_stmt*, int, const char*, int, void(*)(void*));
	int __stdcall sqlite3_bind_text16(sqlite3_stmt*, int, const void*, int, void(*)(void*));
	int __stdcall sqlite3_bind_text64(sqlite3_stmt*, int, const char*, uint64_t, void(*)(void*), unsigned char encoding);
	int __stdcall sqlite3_bind_value(sqlite3_stmt*, int, const sqlite3_value*);
	int __stdcall sqlite3_bind_zeroblob(sqlite3_stmt*, int, int n);
	int __stdcall sqlite3_bind_zeroblob64(sqlite3_stmt*, int, uint64_t);

	int __stdcall sqlite3_bind_parameter_count(sqlite3_stmt*);

	const char* __stdcall sqlite3_bind_parameter_name(sqlite3_stmt*, int);

	int __stdcall sqlite3_bind_parameter_index(sqlite3_stmt*, const char* zName);

	int __stdcall sqlite3_clear_bindings(sqlite3_stmt*);

	int __stdcall sqlite3_column_count(sqlite3_stmt* pStmt);

	const char* __stdcall sqlite3_column_name(sqlite3_stmt*, int N);
	const void* __stdcall sqlite3_column_name16(sqlite3_stmt*, int N);

	const char* __stdcall sqlite3_column_database_name(sqlite3_stmt*, int);
	const void* __stdcall sqlite3_column_database_name16(sqlite3_stmt*, int);
	const char* __stdcall sqlite3_column_table_name(sqlite3_stmt*, int);
	const void* __stdcall sqlite3_column_table_name16(sqlite3_stmt*, int);
	const char* __stdcall sqlite3_column_origin_name(sqlite3_stmt*, int);
	const void* __stdcall sqlite3_column_origin_name16(sqlite3_stmt*, int);

	const char* __stdcall sqlite3_column_decltype(sqlite3_stmt*, int);
	const void* __stdcall sqlite3_column_decltype16(sqlite3_stmt*, int);

	int __stdcall sqlite3_step(sqlite3_stmt*);

	int __stdcall sqlite3_data_count(sqlite3_stmt* pStmt);

	enum {
		SQLITE_INTEGER  = 1,
		SQLITE_FLOAT    = 2,
		SQLITE_TEXT     = 3,
		SQLITE3_TEXT    = 3,
		SQLITE_BLOB     = 4,
		SQLITE_NULL     = 5
	};

	const void* __stdcall sqlite3_column_blob(sqlite3_stmt*, int iCol);
	int __stdcall sqlite3_column_bytes(sqlite3_stmt*, int iCol);
	int __stdcall sqlite3_column_bytes16(sqlite3_stmt*, int iCol);
	double __stdcall sqlite3_column_double(sqlite3_stmt*, int iCol);
	int __stdcall sqlite3_column_int(sqlite3_stmt*, int iCol);
	int64_t __stdcall sqlite3_column_int64(sqlite3_stmt*, int iCol);
	const unsigned char* __stdcall sqlite3_column_text(sqlite3_stmt*, int iCol);
	const void* __stdcall sqlite3_column_text16(sqlite3_stmt*, int iCol);
	int __stdcall sqlite3_column_type(sqlite3_stmt*, int iCol);
	sqlite3_value* __stdcall sqlite3_column_value(sqlite3_stmt*, int iCol);

	int __stdcall sqlite3_finalize(sqlite3_stmt* pStmt);

	int __stdcall sqlite3_reset(sqlite3_stmt* pStmt);

	int __stdcall sqlite3_create_function(
		sqlite3* db,
		const char* zFunctionName,
		int nArg,
		int eTextRep,
		void* pApp,
		void (*xFunc)(sqlite3_context*, int, sqlite3_value**),
		void (*xStep)(sqlite3_context*, int, sqlite3_value**),
		void (*xFinal)(sqlite3_context*));
	int __stdcall sqlite3_create_function16(
		sqlite3* db,
		const void* zFunctionName,
		int nArg,
		int eTextRep,
		void* pApp,
		void (*xFunc)(sqlite3_context*, int, sqlite3_value**),
		void (*xStep)(sqlite3_context*, int, sqlite3_value**),
		void (*xFinal)(sqlite3_context*));
	int __stdcall sqlite3_create_function_v2(
		sqlite3* db,
		const char* zFunctionName,
		int nArg,
		int eTextRep,
		void* pApp,
		void (*xFunc)(sqlite3_context*, int, sqlite3_value**),
		void (*xStep)(sqlite3_context*, int, sqlite3_value**),
		void (*xFinal)(sqlite3_context*),
		void(*xDestroy)(void*));

	enum {
		SQLITE_UTF8           = 1,
		SQLITE_UTF16LE        = 2,
		SQLITE_UTF16BE        = 3,
		SQLITE_UTF16          = 4,
		SQLITE_ANY            = 5,
		SQLITE_UTF16_ALIGNED  = 8,

		SQLITE_DETERMINISTIC  = 0x800
	};

	const void* __stdcall sqlite3_value_blob(sqlite3_value*);
	int __stdcall sqlite3_value_bytes(sqlite3_value*);
	int __stdcall sqlite3_value_bytes16(sqlite3_value*);
	double __stdcall sqlite3_value_double(sqlite3_value*);
	int __stdcall sqlite3_value_int(sqlite3_value*);
	int64_t __stdcall sqlite3_value_int64(sqlite3_value*);
	const unsigned char* __stdcall sqlite3_value_text(sqlite3_value*);
	const void* __stdcall sqlite3_value_text16(sqlite3_value*);
	const void* __stdcall sqlite3_value_text16le(sqlite3_value*);
	const void* __stdcall sqlite3_value_text16be(sqlite3_value*);
	int __stdcall sqlite3_value_type(sqlite3_value*);
	int __stdcall sqlite3_value_numeric_type(sqlite3_value*);

	/* SQLITE_EXPERIMENTAL */ sqlite3_value* __stdcall sqlite3_value_dup(const sqlite3_value*);
	/* SQLITE_EXPERIMENTAL */ void __stdcall sqlite3_value_free(sqlite3_value*);

	void* __stdcall sqlite3_aggregate_context(sqlite3_context*, int nBytes);
	void* __stdcall sqlite3_user_data(sqlite3_context*);
	sqlite3* __stdcall sqlite3_context_db_handle(sqlite3_context*);

	void* __stdcall sqlite3_get_auxdata(sqlite3_context*, int N);
	void __stdcall sqlite3_set_auxdata(sqlite3_context*, int N, void*, void (*)(void*));

	typedef void (*sqlite3_destructor_type)(void*);

	/*
	#define SQLITE_STATIC      ((sqlite3_destructor_type)0)
	#define SQLITE_TRANSIENT   ((sqlite3_destructor_type)-1)
	*/

	void __stdcall sqlite3_result_blob(sqlite3_context*, const void*, int, void(*)(void*));
	void __stdcall sqlite3_result_blob64(sqlite3_context*, const void*, uint64_t, void(*)(void*));
	void __stdcall sqlite3_result_double(sqlite3_context*, double);
	void __stdcall sqlite3_result_error(sqlite3_context*, const char*, int);
	void __stdcall sqlite3_result_error16(sqlite3_context*, const void*, int);
	void __stdcall sqlite3_result_error_toobig(sqlite3_context*);
	void __stdcall sqlite3_result_error_nomem(sqlite3_context*);
	void __stdcall sqlite3_result_error_code(sqlite3_context*, int);
	void __stdcall sqlite3_result_int(sqlite3_context*, int);
	void __stdcall sqlite3_result_int64(sqlite3_context*, int64_t);
	void __stdcall sqlite3_result_null(sqlite3_context*);
	void __stdcall sqlite3_result_text(sqlite3_context*, const char*, int, void(*)(void*));
	void __stdcall sqlite3_result_text64(sqlite3_context*, const char*, uint64_t, void(*)(void*), unsigned char encoding);
	void __stdcall sqlite3_result_text16(sqlite3_context*, const void*, int, void(*)(void*));
	void __stdcall sqlite3_result_text16le(sqlite3_context*, const void*, int, void(*)(void*));
	void __stdcall sqlite3_result_text16be(sqlite3_context*, const void*, int, void(*)(void*));
	void __stdcall sqlite3_result_value(sqlite3_context*, sqlite3_value*);
	void __stdcall sqlite3_result_zeroblob(sqlite3_context*, int n);
	int __stdcall sqlite3_result_zeroblob64(sqlite3_context*, uint64_t n);

	int __stdcall sqlite3_create_collation(
		sqlite3*,
		const char* zName,
		int eTextRep,
		void* pArg,
		int(*xCompare)(void*, int, const void*, int, const void*));
	int __stdcall sqlite3_create_collation_v2(
		sqlite3*,
		const char* zName,
		int eTextRep,
		void* pArg,
		int(*xCompare)(void*, int, const void*, int, const void*),
		void(*xDestroy)(void*));
	int __stdcall sqlite3_create_collation16(
		sqlite3*,
		const void* zName,
		int eTextRep,
		void* pArg,
		int(*xCompare)(void*, int, const void*, int, const void*));
	int __stdcall sqlite3_collation_needed(
		sqlite3*,
		void*,
		void(*)(void*, sqlite3*, int eTextRep, const char*));
	int __stdcall sqlite3_collation_needed16(
		sqlite3*,
		void*,
		void(*)(void*, sqlite3*, int eTextRep, const void*));

	int __stdcall sqlite3_sleep(int);
	char* sqlite3_temp_directory;
	char* sqlite3_data_directory;
	int __stdcall sqlite3_get_autocommit(sqlite3*);
	sqlite3* __stdcall sqlite3_db_handle(sqlite3_stmt*);
	const char* __stdcall sqlite3_db_filename(sqlite3* db, const char* zDbName);
	int __stdcall sqlite3_db_readonly(sqlite3* db, const char* zDbName);
	sqlite3_stmt* __stdcall sqlite3_next_stmt(sqlite3* pDb, sqlite3_stmt* pStmt);

	void* __stdcall sqlite3_commit_hook(sqlite3*, int(*)(void*), void*);
	void* __stdcall sqlite3_rollback_hook(sqlite3*, void(*)(void*), void*);

	void* __stdcall sqlite3_update_hook(
		sqlite3*,
		void(*)(void*, int, char const*, char const*, int64_t),
		void*);

	int __stdcall sqlite3_enable_shared_cache(int);
	int __stdcall sqlite3_release_memory(int);
	int __stdcall sqlite3_db_release_memory(sqlite3*);
	int64_t __stdcall sqlite3_soft_heap_limit64(int64_t N);

	int __stdcall sqlite3_table_column_metadata(
		sqlite3* db,
		const char* zDbName,
		const char* zTableName,
		const char* zColumnName,
		char const** pzDataType,
		char const** pzCollSeq,
		int* pNotNull,
		int* pPrimaryKey,
		int* pAutoinc);

	int __stdcall sqlite3_load_extension(
		sqlite3* db,
		const char* zFile,
		const char* zProc,
		char** pzErrMsg);

	int __stdcall sqlite3_enable_load_extension(sqlite3* db, int onoff);
	int __stdcall sqlite3_auto_extension(void (*xEntryPoint)());
	int __stdcall sqlite3_cancel_auto_extension(void (*xEntryPoint)());
	void __stdcall sqlite3_reset_auto_extension();

	typedef struct sqlite3_vtab sqlite3_vtab;
	typedef struct sqlite3_index_info sqlite3_index_info;
	typedef struct sqlite3_vtab_cursor sqlite3_vtab_cursor;
	typedef struct sqlite3_module sqlite3_module;

	struct sqlite3_module {
		int iVersion;
		int (*xCreate)(sqlite3*, void* pAux, int argc, const char* const* argv, sqlite3_vtab** ppVTab, char**);
		int (*xConnect)(sqlite3*, void* pAux, int argc, const char* const* argv, sqlite3_vtab** ppVTab, char**);
		int (*xBestIndex)(sqlite3_vtab* pVTab, sqlite3_index_info*);
		int (*xDisconnect)(sqlite3_vtab* pVTab);
		int (*xDestroy)(sqlite3_vtab* pVTab);
		int (*xOpen)(sqlite3_vtab* pVTab, sqlite3_vtab_cursor** ppCursor);
		int (*xClose)(sqlite3_vtab_cursor*);
		int (*xFilter)(sqlite3_vtab_cursor*, int idxNum, const char* idxStr, int argc, sqlite3_value** argv);
		int (*xNext)(sqlite3_vtab_cursor*);
		int (*xEof)(sqlite3_vtab_cursor*);
		int (*xColumn)(sqlite3_vtab_cursor*, sqlite3_context*, int);
		int (*xRowid)(sqlite3_vtab_cursor*, int64_t* pRowid);
		int (*xUpdate)(sqlite3_vtab*, int, sqlite3_value**, int64_t*);
		int (*xBegin)(sqlite3_vtab* pVTab);
		int (*xSync)(sqlite3_vtab* pVTab);
		int (*xCommit)(sqlite3_vtab* pVTab);
		int (*xRollback)(sqlite3_vtab* pVTab);
		int (*xFindFunction)(
			sqlite3_vtab* pVtab, int nArg, const char* zName,
			void (**pxFunc)(sqlite3_context*, int, sqlite3_value**),
			void** ppArg);
		int (*xRename)(sqlite3_vtab* pVtab, const char* zNew);

		int (*xSavepoint)(sqlite3_vtab* pVTab, int);
		int (*xRelease)(sqlite3_vtab* pVTab, int);
		int (*xRollbackTo)(sqlite3_vtab* pVTab, int);
	};

	struct sqlite3_index_info {

		int nConstraint;
		struct sqlite3_index_constraint {
		   int iColumn;
		   unsigned char op;
		   unsigned char usable;
		   int iTermOffset;
		}* aConstraint;
		int nOrderBy;
		struct sqlite3_index_orderby {
		   int iColumn;
		   unsigned char desc;
		}* aOrderBy;

		struct sqlite3_index_constraint_usage {
		  int argvIndex;
		  unsigned char omit;
		}* aConstraintUsage;
		int idxNum;
		char* idxStr;
		int needToFreeIdxStr;
		int orderByConsumed;
		double estimatedCost;

		int64_t estimatedRows;
	};

	enum {
		SQLITE_INDEX_CONSTRAINT_EQ    = 2,
		SQLITE_INDEX_CONSTRAINT_GT    = 4,
		SQLITE_INDEX_CONSTRAINT_LE    = 8,
		SQLITE_INDEX_CONSTRAINT_LT    = 16,
		SQLITE_INDEX_CONSTRAINT_GE    = 32,
		SQLITE_INDEX_CONSTRAINT_MATCH = 64,
	};

	int __stdcall sqlite3_create_module(
		sqlite3* db,
		const char* zName,
		const sqlite3_module* p,
		void* pClientData);
	int __stdcall sqlite3_create_module_v2(
		sqlite3* db,
		const char* zName,
		const sqlite3_module* p,
		void* pClientData,
		void(*xDestroy)(void*));

	struct sqlite3_vtab {
		const sqlite3_module* pModule;
		int nRef;
		char* zErrMsg;
	};

	struct sqlite3_vtab_cursor {
		sqlite3_vtab* pVtab;
	};

	int __stdcall sqlite3_declare_vtab(sqlite3*, const char* zSQL);
	int __stdcall sqlite3_overload_function(sqlite3*, const char* zFuncName, int nArg);
	typedef struct sqlite3_blob sqlite3_blob;

	int __stdcall sqlite3_blob_open(
		sqlite3*,
		const char* zDb,
		const char* zTable,
		const char* zColumn,
		int64_t iRow,
		int flags,
		sqlite3_blob** ppBlob);

	int __stdcall sqlite3_blob_reopen(sqlite3_blob*, int64_t);
	int __stdcall sqlite3_blob_close(sqlite3_blob*);
	int __stdcall sqlite3_blob_bytes(sqlite3_blob*);
	int __stdcall sqlite3_blob_read(sqlite3_blob*, void* Z, int N, int iOffset);
	int __stdcall sqlite3_blob_write(sqlite3_blob*, const void* z, int n, int iOffset);

	sqlite3_vfs* __stdcall sqlite3_vfs_find(const char* zVfsName);
	int __stdcall sqlite3_vfs_register(sqlite3_vfs*, int makeDflt);
	int __stdcall sqlite3_vfs_unregister(sqlite3_vfs*);

	sqlite3_mutex* __stdcall sqlite3_mutex_alloc(int);
	void __stdcall sqlite3_mutex_free(sqlite3_mutex*);
	void __stdcall sqlite3_mutex_enter(sqlite3_mutex*);
	int __stdcall sqlite3_mutex_try(sqlite3_mutex*);
	void __stdcall sqlite3_mutex_leave(sqlite3_mutex*);

	typedef struct sqlite3_mutex_methods {
		int (*xMutexInit)();
		int (*xMutexEnd)();
		sqlite3_mutex* (*xMutexAlloc)(int);
		void (*xMutexFree)(sqlite3_mutex*);
		void (*xMutexEnter)(sqlite3_mutex*);
		int (*xMutexTry)(sqlite3_mutex*);
		void (*xMutexLeave)(sqlite3_mutex*);
		int (*xMutexHeld)(sqlite3_mutex*);
		int (*xMutexNotheld)(sqlite3_mutex*);
	} sqlite3_mutex_methods;

	/*
	#ifndef NDEBUG
	int __stdcall sqlite3_mutex_held(sqlite3_mutex*);
	int __stdcall sqlite3_mutex_notheld(sqlite3_mutex*);
	#endif
	*/

	enum {
		SQLITE_MUTEX_FAST             = 0,
		SQLITE_MUTEX_RECURSIVE        = 1,
		SQLITE_MUTEX_STATIC_MASTER    = 2,
		SQLITE_MUTEX_STATIC_MEM       = 3,
		SQLITE_MUTEX_STATIC_MEM2      = 4,
		SQLITE_MUTEX_STATIC_OPEN      = 4,
		SQLITE_MUTEX_STATIC_PRNG      = 5,
		SQLITE_MUTEX_STATIC_LRU       = 6,
		SQLITE_MUTEX_STATIC_LRU2      = 7,
		SQLITE_MUTEX_STATIC_PMEM      = 7,
		SQLITE_MUTEX_STATIC_APP1      = 8,
		SQLITE_MUTEX_STATIC_APP2      = 9,
		SQLITE_MUTEX_STATIC_APP3     = 10,
		SQLITE_MUTEX_STATIC_VFS1     = 11,
		SQLITE_MUTEX_STATIC_VFS2     = 12,
		SQLITE_MUTEX_STATIC_VFS3     = 13
	};

	sqlite3_mutex* __stdcall sqlite3_db_mutex(sqlite3*);

	int __stdcall sqlite3_file_control(sqlite3*, const char* zDbName, int op, void*);

	int __cdecl sqlite3_test_control(int op, ...);

	enum {
		SQLITE_TESTCTRL_FIRST                    = 5,
		SQLITE_TESTCTRL_PRNG_SAVE                = 5,
		SQLITE_TESTCTRL_PRNG_RESTORE             = 6,
		SQLITE_TESTCTRL_PRNG_RESET               = 7,
		SQLITE_TESTCTRL_BITVEC_TEST              = 8,
		SQLITE_TESTCTRL_FAULT_INSTALL            = 9,
		SQLITE_TESTCTRL_BENIGN_MALLOC_HOOKS     = 10,
		SQLITE_TESTCTRL_PENDING_BYTE            = 11,
		SQLITE_TESTCTRL_ASSERT                  = 12,
		SQLITE_TESTCTRL_ALWAYS                  = 13,
		SQLITE_TESTCTRL_RESERVE                 = 14,
		SQLITE_TESTCTRL_OPTIMIZATIONS           = 15,
		SQLITE_TESTCTRL_ISKEYWORD               = 16,
		SQLITE_TESTCTRL_SCRATCHMALLOC           = 17,
		SQLITE_TESTCTRL_LOCALTIME_FAULT         = 18,
		SQLITE_TESTCTRL_EXPLAIN_STMT            = 19,
		SQLITE_TESTCTRL_NEVER_CORRUPT           = 20,
		SQLITE_TESTCTRL_VDBE_COVERAGE           = 21,
		SQLITE_TESTCTRL_BYTEORDER               = 22,
		SQLITE_TESTCTRL_ISINIT                  = 23,
		SQLITE_TESTCTRL_SORTER_MMAP             = 24,
		SQLITE_TESTCTRL_IMPOSTER                = 25,
		SQLITE_TESTCTRL_LAST                    = 25
	};

	int __stdcall sqlite3_status(int op, int* pCurrent, int* pHighwater, int resetFlag);
	int __stdcall sqlite3_status64(
		int op,
		int64_t* pCurrent,
		int64_t* pHighwater,
		int resetFlag);

	enum {
		SQLITE_STATUS_MEMORY_USED          = 0,
		SQLITE_STATUS_PAGECACHE_USED       = 1,
		SQLITE_STATUS_PAGECACHE_OVERFLOW   = 2,
		SQLITE_STATUS_SCRATCH_USED         = 3,
		SQLITE_STATUS_SCRATCH_OVERFLOW     = 4,
		SQLITE_STATUS_MALLOC_SIZE          = 5,
		SQLITE_STATUS_PARSER_STACK         = 6,
		SQLITE_STATUS_PAGECACHE_SIZE       = 7,
		SQLITE_STATUS_SCRATCH_SIZE         = 8,
		SQLITE_STATUS_MALLOC_COUNT         = 9
	};

	int __stdcall sqlite3_db_status(sqlite3*, int op, int* pCur, int* pHiwtr, int resetFlg);

	enum {
		SQLITE_DBSTATUS_LOOKASIDE_USED       = 0,
		SQLITE_DBSTATUS_CACHE_USED           = 1,
		SQLITE_DBSTATUS_SCHEMA_USED          = 2,
		SQLITE_DBSTATUS_STMT_USED            = 3,
		SQLITE_DBSTATUS_LOOKASIDE_HIT        = 4,
		SQLITE_DBSTATUS_LOOKASIDE_MISS_SIZE  = 5,
		SQLITE_DBSTATUS_LOOKASIDE_MISS_FULL  = 6,
		SQLITE_DBSTATUS_CACHE_HIT            = 7,
		SQLITE_DBSTATUS_CACHE_MISS           = 8,
		SQLITE_DBSTATUS_CACHE_WRITE          = 9,
		SQLITE_DBSTATUS_DEFERRED_FKS        = 10,
		SQLITE_DBSTATUS_MAX                 = 10
	};

	int __stdcall sqlite3_stmt_status(sqlite3_stmt*, int op, int resetFlg);

	enum {
		SQLITE_STMTSTATUS_FULLSCAN_STEP     = 1,
		SQLITE_STMTSTATUS_SORT              = 2,
		SQLITE_STMTSTATUS_AUTOINDEX         = 3,
		SQLITE_STMTSTATUS_VM_STEP           = 4
	};

	typedef struct sqlite3_pcache sqlite3_pcache;

	typedef struct sqlite3_pcache_page {
		void* pBuf;
		void* pExtra;
	} sqlite3_pcache_page;

	typedef struct sqlite3_pcache_methods2 {
		int iVersion;
		void* pArg;
		int (*xInit)(void*);
		void (*xShutdown)(void*);
		sqlite3_pcache* (*xCreate)(int szPage, int szExtra, int bPurgeable);
		void (*xCachesize)(sqlite3_pcache*, int nCachesize);
		int (*xPagecount)(sqlite3_pcache*);
		sqlite3_pcache_page* (*xFetch)(sqlite3_pcache*, unsigned key, int createFlag);
		void (*xUnpin)(sqlite3_pcache*, sqlite3_pcache_page*, int discard);
		void (*xRekey)(sqlite3_pcache*, sqlite3_pcache_page*, unsigned oldKey, unsigned newKey);
		void (*xTruncate)(sqlite3_pcache*, unsigned iLimit);
		void (*xDestroy)(sqlite3_pcache*);
		void (*xShrink)(sqlite3_pcache*);
	} sqlite3_pcache_methods2;

	typedef struct sqlite3_pcache_methods {
		void* pArg;
		int (*xInit)(void*);
		void (*xShutdown)(void*);
		sqlite3_pcache* (*xCreate)(int szPage, int bPurgeable);
		void (*xCachesize)(sqlite3_pcache*, int nCachesize);
		int (*xPagecount)(sqlite3_pcache*);
		void* (*xFetch)(sqlite3_pcache*, unsigned key, int createFlag);
		void (*xUnpin)(sqlite3_pcache*, void*, int discard);
		void (*xRekey)(sqlite3_pcache*, void*, unsigned oldKey, unsigned newKey);
		void (*xTruncate)(sqlite3_pcache*, unsigned iLimit);
		void (*xDestroy)(sqlite3_pcache*);
	} sqlite3_pcache_methods;

	typedef struct sqlite3_backup sqlite3_backup;

	sqlite3_backup* __stdcall sqlite3_backup_init(
		sqlite3* pDest,
		const char* zDestName,
		sqlite3* pSource,
		const char* zSourceName);
	int __stdcall sqlite3_backup_step(sqlite3_backup* p, int nPage);
	int __stdcall sqlite3_backup_finish(sqlite3_backup* p);
	int __stdcall sqlite3_backup_remaining(sqlite3_backup* p);
	int __stdcall sqlite3_backup_pagecount(sqlite3_backup* p);

	int __stdcall sqlite3_unlock_notify(
		sqlite3* pBlocked,
		void (*xNotify)(void** apArg, int nArg),
		void* pNotifyArg);

	int __stdcall sqlite3_stricmp(const char*, const char*);
	int __stdcall sqlite3_strnicmp(const char*, const char*, int);
	int __stdcall sqlite3_strglob(const char* zGlob, const char* zStr);
	void __cdecl sqlite3_log(int iErrCode, const char* zFormat, ...);

	void* __stdcall sqlite3_wal_hook(
		sqlite3*,
		int(*)(void*, sqlite3*, const char*, int),
		void*);

	int __stdcall sqlite3_wal_autocheckpoint(sqlite3* db, int N);
	int __stdcall sqlite3_wal_checkpoint(sqlite3* db, const char* zDb);

	int __stdcall sqlite3_wal_checkpoint_v2(
		sqlite3* db,
		const char* zDb,
		int eMode,
		int* pnLog,
		int* pnCkpt);

	enum {
		SQLITE_CHECKPOINT_PASSIVE  = 0,
		SQLITE_CHECKPOINT_FULL     = 1,
		SQLITE_CHECKPOINT_RESTART  = 2,
		SQLITE_CHECKPOINT_TRUNCATE = 3
	};

	int __cdecl sqlite3_vtab_config(sqlite3*, int op, ...);

	static const int SQLITE_VTAB_CONSTRAINT_SUPPORT = 1;

	int __stdcall sqlite3_vtab_on_conflict(sqlite3*);

	enum {
		SQLITE_ROLLBACK = 1,
		SQLITE_FAIL     = 3,
		SQLITE_REPLACE  = 5,

		SQLITE_SCANSTAT_NLOOP    = 0,
		SQLITE_SCANSTAT_NVISIT   = 1,
		SQLITE_SCANSTAT_EST      = 2,
		SQLITE_SCANSTAT_NAME     = 3,
		SQLITE_SCANSTAT_EXPLAIN  = 4,
		SQLITE_SCANSTAT_SELECTID = 5
	};

	int __stdcall sqlite3_stmt_scanstatus(
		sqlite3_stmt* pStmt,
		int idx,
		int iScanStatusOp,
		void* pOut);

	void __stdcall sqlite3_stmt_scanstatus_reset(sqlite3_stmt*);

	// SQLITE3RTREE

	typedef struct sqlite3_rtree_geometry sqlite3_rtree_geometry;
	typedef struct sqlite3_rtree_query_info sqlite3_rtree_query_info;

	typedef double sqlite3_rtree_dbl;

	int __stdcall sqlite3_rtree_geometry_callback(
		sqlite3* db,
		const char* zGeom,
		int (*xGeom)(sqlite3_rtree_geometry*, int, sqlite3_rtree_dbl*, int*),
		void* pContext);

	struct sqlite3_rtree_geometry {
		void* pContext;
		int nParam;
		sqlite3_rtree_dbl* aParam;
		void* pUser;
		void (*xDelUser)(void*);
	};

	int __stdcall sqlite3_rtree_query_callback(
		sqlite3* db,
		const char* zQueryFunc,
		int (*xQueryFunc)(sqlite3_rtree_query_info*),
		void* pContext,
		void (*xDestructor)(void*));

	struct sqlite3_rtree_query_info {
		void* pContext;
		int nParam;
		sqlite3_rtree_dbl* aParam;
		void* pUser;
		void (*xDelUser)(void*);
		sqlite3_rtree_dbl* aCoord;
		unsigned int* anQueue;
		int nCoord;
		int iLevel;
		int mxLevel;
		int64_t iRowid;
		sqlite3_rtree_dbl rParentScore;
		int eParentWithin;
		int eWithin;
		sqlite3_rtree_dbl rScore;

		sqlite3_value** apSqlParam;
	};

	enum {
		NOT_WITHIN       = 0,
		PARTLY_WITHIN    = 1,
		FULLY_WITHIN     = 2
	};

]]

return lib
