
local ffi = require 'ffi'

ffi.cdef [[

	typedef struct FILE FILE;

	void* malloc(size_t);
	void free(void*);

	FILE* freopen(const char* filename, const char* mode, FILE*);

]]

return ffi.C
