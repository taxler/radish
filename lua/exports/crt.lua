
local ffi = require 'ffi'

ffi.cdef [[

	typedef struct FILE FILE;

	void* malloc(size_t);
	void free(void*);

]]

return ffi.C
