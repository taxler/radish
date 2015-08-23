
local ffi = require 'ffi'

ffi.cdef [[

	typedef _Bool int bool32;

]]

return ffi.typeof 'bool32'
