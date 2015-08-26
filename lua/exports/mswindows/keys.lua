
local ffi = require 'ffi'
require 'exports.mswindows.handles'

ffi.cdef [[

	enum {
		VK_LBUTTON = 1,
		VK_RBUTTON,
		VK_CANCEL,
		VK_MBUTTON,
		VK_XBUTTON1,
		VK_XBUTTON2,
		VK_BACK = 8,
		VK_TAB,
		VK_CLEAR = 0xC,
		VK_RETURN,
		VK_ENTER,
		VK_SHIFT = 0x10,
		VK_CONTROL,
		VK_MENU, // alt key
		VK_PAUSE,
		VK_CAPITAL, // caps lock
		VK_KANA,
		VK_HANGUEL = VK_KANA,
		VK_HANGUL = VK_KANA,
		VK_JUNJA = 0x17,
		VK_FINAL,
		VK_HANJA,
		VK_KANJI = VK_HANJA,
		VK_ESCAPE = 0x1B,
		VK_CONVERT,
		VK_NONCONVERT,
		VK_ACCEPT,
		VK_MODECHANGE,
		VK_SPACE,
		VK_PRIOR, // page up
		VK_NEXT, // page down
		VK_END,
		VK_HOME,
		VK_LEFT,
		VK_UP,
		VK_RIGHT,
		VK_DOWN,
		VK_SELECT,
		VK_PRINT,
		VK_EXECUTE,
		VK_SNAPSHOT, // print screen
		VK_INSERT,
		VK_DELETE,
		VK_HELP,
		// 0x30 to 0x39: 0 to 9
		// 0x41 to 0x5A: A to Z
		VK_LWIN = 0x5B,
		VK_RWIN,
		VK_APPS,
		VK_SLEEP = 0x5F,
		VK_NUMPAD0,
		VK_NUMPAD1,
		VK_NUMPAD2,
		VK_NUMPAD3,
		VK_NUMPAD4,
		VK_NUMPAD5,
		VK_NUMPAD6,
		VK_NUMPAD7,
		VK_NUMPAD8,
		VK_NUMPAD9,
		VK_MULTIPLY,
		VK_ADD,
		VK_SEPARATOR,
		VK_SUBTRACT,
		VK_DECIMAL,
		VK_DIVIDE,
		VK_F1,
		VK_F2,
		VK_F3,
		VK_F4,
		VK_F5,
		VK_F6,
		VK_F7,
		VK_F8,
		VK_F9,
		VK_F10,
		VK_F11,
		VK_F12,
		VK_F13,
		VK_F14,
		VK_F15,
		VK_F16,
		VK_F17,
		VK_F18,
		VK_F19,
		VK_F20,
		VK_F21,
		VK_F22,
		VK_F23,
		VK_F24,
		VK_NUMLOCK = 0x90,
		VK_SCROLL,
		// 0x92-0x96: OEM specific
		VK_LSHIFT = 0xA0,
		VK_RSHIFT,
		VK_LCONTROL,
		VK_RCONTROL,
		VK_LMENU,
		VK_RMENU,
		VK_BROWSER_BACK,
		VK_BROWSER_FORWARD,
		VK_BROWSER_REFRESH,
		VK_BROWSER_STOP,
		VK_BROWSER_SEARCH,
		VK_BROWSER_FAVORITES,
		VK_BROWSER_HOME,
		VK_VOLUME_MUTE,
		VK_VOLUME_DOWN,
		VK_VOLUME_UP,
		VK_MEDIA_NEXT_TRACK,
		VK_MEDIA_PREV_TRACK,
		VK_MEDIA_STOP,
		VK_MEDIA_PLAY_PAUSE,
		VK_LAUNCH_MAIL,
		VK_LAUNCH_MEDIA_SELECT,
		VK_LAUNCH_APP1,
		VK_LAUNCH_APP2,
		VK_OEM_1 = 0xBA,
		VK_OEM_PLUS,
		VK_OEM_COMMA,
		VK_OEM_MINUS,
		VK_OEM_PERIOD,
		VK_OEM_2,
		VK_OEM_3,
		VK_OEM_4 = 0xDB,
		VK_OEM_5,
		VK_OEM_6,
		VK_OEM_7,
		VK_OEM_8,
		// 0xE1: OEM specific
		VK_OEM_102 = 0xE2, // either angle bracket or backslash on the RT 102-key keyboard
		// 0xE3-0xE4: OEM specific
		VK_PROCESSKEY = 0xE5,
		// 0xE6: OEM specific
		/*
			pass Unicode characters as keystrokes: VK_PACKET is low-word of 32-bit VK value
			used for non-keyboard input methods
		*/
		VK_PACKET = 0xE7, 
		// 0xE9-F5: OEM specific
		VK_ATTN = 0xF6,
		VK_CRSEL,
		VK_EXSEL,
		VK_EREOF,
		VK_PLAY,
		VK_ZOOM,
		VK_NONAME, // reserved
		VK_PA1,
		VK_OEM_CLEAR
	};

	// accelerator tables

	enum {
		FVIRTKEY = 0x01,
		// FNOINVERT = 0x02, /* obsolete: for 16-bit windows */
		FSHIFT = 0x04,
		FCONTROL = 0x08,
		FALT = 0x10
	};

	typedef struct ACCEL {
		uint8_t fVirt;
		uint16_t key;
		uint16_t cmd;
	} ACCEL;
	ACCELERATOR_TABLE* CreateAcceleratorTableW(
		ACCEL* array,
		int array_length);

]]

return ffi.C
