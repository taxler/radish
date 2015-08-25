
local ffi = require 'ffi'

ffi.cdef [[
	
	typedef struct RESOURCE_UPDATE_W RESOURCE_UPDATE_W;
	typedef struct RESOURCE_UPDATE_A RESOURCE_UPDATE_A;

	typedef struct MODULE MODULE;
	typedef struct RESOURCE RESOURCE;
	typedef struct MICROSOFT_WINDOW MICROSOFT_WINDOW;

]]

return {
	is_invalid = function(handle)
		return ffi.cast('intptr_t', handle) == -1
	end;
	get_invalid = function()
		return ffi.cast('void*', ffi.cast('intptr_t', -1))
	end;
}
