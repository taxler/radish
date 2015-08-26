
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
		MICROSOFT_WINDOW* hwnd;
		uint32_t          message;
		uintptr_t         wParam;
		intptr_t          lParam;
		uint32_t          time;
		POINT             pt;
	} MSG;

	typedef intptr_t (__stdcall *WNDPROC)(
		MICROSOFT_WINDOW* hwnd,
		uint32_t message,
		uintptr_t wparam,
		intptr_t lparam);

	typedef struct WNDCLASSEXW {
		uint32_t cbSize;
		uint32_t style;
		WNDPROC   lpfnWndProc;
		int       cbClsExtra;
		int       cbWndExtra;
		MODULE* hInstance;
		void*     hIcon;
		void*   hCursor;
		void*   hbrBackground;
		const wchar_t* lpszMenuName;
		const wchar_t* lpszClassName;
		void*     hIconSm;
	} WNDCLASSEXW;

	typedef struct CREATESTRUCTW {
		void* lpCreateParams;
		MODULE* hInstance;
		void* hMenu;
		MICROSOFT_WINDOW* hwndParent;
		int       cy;
		int       cx;
		int       y;
		int       x;
		int32_t    style;
		const wchar_t* lpszName;
		const wchar_t* lpszClass;
		uint32_t    dwExStyle;
	} CREATESTRUCTW;

	// window messages
	enum {
		WM_ZERO             = 0x0000,
		WM_CREATE           = 0x0001, // lparam: CREATESTRUCT*
		                              // ret to continue: 0
		                              // ret to destroy: -1
		WM_DESTROY          = 0x0002,
		WM_MOVE             = 0x0003, // lparam << 16 >> 16: client x
		                              // lparam       >> 16: client y
		WM_SIZE             = 0x0005, // wparam = 0: normal resize
		                              // wparam = 1: minimized
		                              // wparam = 2: maximized
		                              // wparam = 3: another window restored (for pop-up windows)
		                              // wparam = 4: another window maximized (for pop-up windows)
		                              // lparam << 16 >> 16: client width
		                              // lparam       >> 16: client height
		WM_ENABLE           = 0x000A, // wparam: boolean (not being disabled)
		WM_SETTEXT          = 0x000C, // lparam: string
		                              // ret if success: true
		                              // ret if not enough space:
		                              //  if edit control: false
		                              //  if list box: LB_ERRSPACE
		                              //  if combo box: CB_ERRSPACE
		                              //  if combo box w/o edit control: CB_ERR
		WM_GETTEXT          = 0x000D, // wparam: buf size (including \0)
		                              // lparam: buf
		                              // ret: chars copied
		WM_GETTEXTLENGTH    = 0x000E, // ret: character count (not including \0)
		WM_CLOSE            = 0x0010, // default: destroy window
		WM_QUIT             = 0x0012, // wparam: exit code
		WM_QUERYOPEN        = 0x0013, // (sent to minimized window on request to restore)
		                              // ret: boolean (allow de-minimize)
		WM_ERASEBKGND       = 0x0014, // wparam: hdc
		                              // ret: boolean (bg erased)
		                              // default: use hbrBackground from class def
		WM_SHOWWINDOW       = 0x0018, // wparam: boolean (not being hidden)
		                              // lparam = 0: normal show
		                              // lparam = 1: minimizing
		                              // lparam = 2: covered by another window being maximized
		                              // lparam = 3: parent window being restored
		                              // lparam = 4: uncovered by another window being un-maximized
		WM_ACTIVATEAPP      = 0x001C, // wparam: boolean (not being deactivated)
		                              // lparam: thread id (owner of the window)
		WM_CANCELMODE       = 0x001F, // default: cancel scrollbar processing
		                              // default: cancel internal menu processing
		                              // default: release mouse capture
		WM_CHILDACTIVATE    = 0x0022,
		WM_GETMINMAXINFO    = 0x0024, // lparam: MINMAXINFO*
		WM_SETFONT          = 0x0030, // wparam: hfont
		                              // lparam & 0xffff: boolean (redraw control)
		WM_GETFONT          = 0x0031, // ret: hfont
		WM_QUERYDRAGICON    = 0x0037, // (sent to a minimized window about to be dragged)
		                              // ret: hicon/hcursor (null for default)
		WM_COMPACTING       = 0x0041, // (to all top-level windows: memory is low)
		                              // wparam: ratio of CPU time spent compacting
		                              //         out of 0x10000 (e.g. 0x8000 = 50%)
		WM_WINDOWPOSCHANGING= 0x0046, // lparam: WINDOWPOS*
		                              // default: send WM_GETMINMAXINFO
		WM_WINDOWPOSCHANGED = 0x0047, // lparam: WINDOWPOS*
		                              // default: send WM_SIZE/WM_MOVE
		WM_INPUTLANGCHANGEREQUEST
		                    = 0x0050, // wparam | 1: locale keyboard layout OK for system charset
		                              // wparam | 2: "next locale" hot key was used
		                              // wparam | 4: "prev locale" hot key was used
		                              // lparam: new input locale id
		                              // default: accept request
		WM_INPUTLANGCHANGE  = 0x0051, // wparam: character set of new locale
		                              // lparam: input locale id
		                              // return: boolean (handled)
		WM_USERCHANGED      = 0x0054,
		WM_GETICON          = 0x007F, // ret if wparam=0: small hicon
		                              // ret if wparam=1: big hicon
		                              // ret if wparam=2: small hicon,
		                              //                   system default if none set
		                              // lparam: DPI
		WM_STYLECHANGED     = 0x007D, // wparam = -16: normal window styles
		                              // wparam = -20: extended window styles
		                              // STYLESTRUCT*
		WM_SETICON          = 0x0080, // wparam: boolean (set the "big" icon)
		                              // lparam: hicon (null to remove)
		                              // ret: hicon (previous)
		WM_NCCREATE         = 0x0081, // lparam: CREATESTRUCT*
		                              // ret: boolean (continue creation)
		WM_NCDESTROY        = 0x0082,
		WM_NCCALCSIZE       = 0x0083, // lparam if wparam = false: RECT*
		                              // lparam if wparam = true: NCCALCSIZE_PARAMS*
		                              // ret: [investigate?]
		WM_NCACTIVATE       = 0x0086, // wparam: boolean (not being deactivated)
		                              // lparam: [investigate?]
		                              // ret: boolean (successful state change)
		WM_KEYDOWN          = 0x0100, // wparam: virtual key code
		                              // lparam bits 0-15: repeat count
		                              // lparam bits 16-23: scan code
		                              // lparam bit 24: set if extended key (right alt/ctrl)
		                              // lparam bit 30: set if key previously down
		MN_GETHMENU         = 0x01E1, // ret: hmenu
		WM_SIZING           = 0x0214, // wparam: WMSZ_ constant, edge being sized
		                              // lparam: RECT*
		                              // ret: boolean (handled)
		WM_MOVING           = 0x0216, // lparam: RECT* (window in screen coords - can modify!)
		WM_ENTERSIZEMOVE    = 0x0231,
		WM_EXITSIZEMOVE     = 0x0232,
		WM_THEMECHANGED     = 0x031A,

        WM_USER             = 0x4000,
		WM_USER_LAST        = 0x7FFF,
		WM_APP              = 0x8000,
		WM_APP_LAST         = 0xBFFF
	};

	bool32 AllocConsole();

]]

-- ffi.C includes kernel32, user32, gdi32
return ffi.C
