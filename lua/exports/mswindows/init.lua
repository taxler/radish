
local ffi = require 'ffi'
require 'exports.mswindows.handles'
require 'exports.typedef.bool32'

if ffi.os ~= 'Windows' then
	return false
end

ffi.cdef [[

	MODULE* GetModuleHandleA(const char* path);
	MODULE* GetModuleHandleW(const wchar_t* path);

	MODULE* LoadLibraryW(const wchar_t* path);
	bool32 FreeLibrary(MODULE*);

	typedef struct POINT {
		int32_t x, y;
	} POINT;

	typedef struct MSG {
		void*     hwnd;
		uint32_t  message;
		uintptr_t wParam;
		intptr_t  lParam;
		uint32_t  time;
		POINT     pt;
	} MSG;

]]

-- ffi.C includes kernel32, user32, gdi32
return ffi.C
