
local ffi = require 'ffi'

ffi.cdef [[
	
	typedef struct RESOURCE_UPDATE_W RESOURCE_UPDATE_W;
	typedef struct RESOURCE_UPDATE_A RESOURCE_UPDATE_A;

	typedef struct MODULE MODULE;
	typedef struct RESOURCE RESOURCE;

]]

return ffi
