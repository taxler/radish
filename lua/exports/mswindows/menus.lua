
local ffi = require 'ffi'
require 'exports.mswindows'

ffi.cdef [[

	enum {
		MF_GRAYED       = 0x001,
		MF_DISABLED     = 0x002, MF_ENABLED   = 0,
		MF_BITMAP       = 0x004, MF_STRING    = 0,
		MF_CHECKED      = 0x008, MF_UNCHECKED = 0,
		MF_POPUP        = 0x010,
		MF_MENUBARBREAK = 0x020,
		MF_MENUBREAK    = 0x040,
		MF_OWNERDRAW    = 0x100,
		MF_SEPARATOR    = 0x800
	};

	WINDOWS_MENU* GetSystemMenu(
		MICROSOFT_WINDOW*,
		bool32 reset_to_default);

	bool32 AppendMenuW(
		WINDOWS_MENU*,
		uint32_t flags,
		uintptr_t item_id_or_submenu_handle,
		const wchar_t* text_or_other);

]]

return ffi.C
