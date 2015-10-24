
local ffi = require 'ffi'
require 'exports.mswindows.com'
require 'exports.mswindows.automation'

ffi.cdef [[

	int32_t SHCreateStreamOnFileEx(
		const wchar_t* path,
		uint32_t mode,
		uint32_t attributes,
		bool32 create,
		IStream* reserved,
		IStream** out_stream);

]]

return ffi.load 'shlwapi'
