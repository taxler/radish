
local ffi = require 'ffi'
require 'exports.mswindows.handles'

if ffi.os ~= 'Windows' then
	return false
end

ffi.cdef [[

	MODULE* GetModuleHandleA(const char* path);
	MODULE* GetModuleHandleW(const wchar_t* path);

]]

-- ffi.C includes kernel32, user32, gdi32
return ffi.C
