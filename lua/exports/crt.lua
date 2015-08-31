
local ffi = require 'ffi'

ffi.cdef [[

	typedef struct FILE FILE;
	typedef long int off_t; // does not seem to be very easy to define this
	typedef intptr_t ssize_t;

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
