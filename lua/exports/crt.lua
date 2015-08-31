
local ffi = require 'ffi'

ffi.cdef [[

	typedef struct FILE FILE;

	void* malloc(size_t);
	void free(void*);

	FILE* fopen (const char* filename, const char* mode);
	int fseek(FILE*, long int offset, int origin);
	long int ftell(FILE*);
	int fclose(FILE*);

	FILE* freopen(const char* filename, const char* mode, FILE*);

	int memcmp(const void* ptr1, const void* ptr2, size_t);

]]

return ffi.C
