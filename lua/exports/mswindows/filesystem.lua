
local ffi = require 'ffi'
require 'exports.typedef.bool32'

ffi.cdef [[

	bool32 CopyFileW(const wchar_t* from_path, const wchar_t* to_path, bool32 fail_if_exists);

]]

return ffi.C
