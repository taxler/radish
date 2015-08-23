
local ffi = require 'ffi'
require 'exports.typedef.bool32'
local winstr = require 'exports.mswindows.strings'

ffi.cdef [[

	bool32 CopyFileW(const wchar_t* from_path, const wchar_t* to_path, bool32 fail_if_exists);

]]

local kernel32 = ffi.C

return {
	copy = function(from_path, to_path, fail_if_exists)
		return kernel32.CopyFileW(winstr.wide(from_path), winstr.wide(to_path), not not fail_if_exists)
	end;
}
