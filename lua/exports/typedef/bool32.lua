
local ffi = require 'ffi'

ffi.cdef [[

	typedef _Bool int32_t bool32;

]]

return ffi.typeof 'bool32'
