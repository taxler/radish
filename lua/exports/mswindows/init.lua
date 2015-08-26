
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
		WM_SYSCOMMAND       = 0x0112, // wparam: SC_(...) command id
		                              // lparam if using a mnemonic: 0
		                              // lparam if using a system accelerator: -1
		                              // otherwise:
		                              //   lparam << 16 >> 16: x position
		                              //   lparam       >> 16: y position
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
	MICROSOFT_WINDOW* GetConsoleWindow();

	enum {
		GWLP_WNDPROC   = -4,
		GWLP_HINSTANCE = -6,
		GWL_HWNDPARENT = -8,
		GWLP_ID        = -12, // cannot be top level window
		GWL_STYLE      = -16,
		GWL_EXSTYLE    = -20,
		GWLP_USERDATA  = -21
	};

	enum {
		WS_TILED        = 0x00000000,
		WS_OVERLAPPED   = 0x00000000,
		WS_MAXIMIZEBOX  = 0x00010000,
		WS_TABSTOP      = 0x00010000,
		WS_GROUP        = 0x00020000,
		WS_MINIMIZEBOX  = 0x00020000,
		WS_SIZEBOX      = 0x00040000,
		WS_THICKFRAME   = 0x00040000,
		WS_SYSMENU      = 0x00080000,
		WS_HSCROLL      = 0x00100000,
		WS_VSCROLL      = 0x00200000,
		WS_DLGFRAME     = 0x00400000,
		WS_BORDER       = 0x00800000,
		WS_CAPTION      = 0x00C00000,
		WS_MAXIMIZE     = 0x01000000,
		WS_CLIPCHILDREN = 0x02000000,
		WS_CLIPSIBLINGS = 0x04000000,
		WS_DISABLED     = 0x08000000,
		WS_VISIBLE      = 0x10000000,
		WS_MINIMIZE     = 0x20000000,
		WS_ICONIC       = WS_MINIMIZE,
		WS_CHILD        = 0x40000000,
		WS_POPUP        = 0x80000000,
		WS_CHILDWINDOW  = WS_CHILD,

		WS_OVERLAPPEDWINDOW
			= WS_OVERLAPPED | WS_CAPTION | WS_SYSMENU | WS_THICKFRAME | WS_MINIMIZEBOX | WS_MAXIMIZEBOX,
		WS_TILEDWINDOW = WS_OVERLAPPEDWINDOW,
		WS_POPUPWINDOW = WS_POPUP | WS_BORDER | WS_SYSMENU
	};

	enum {
		WS_EX_DLGMODALFRAME       = 0x00000001,
		WS_EX_NOPARENTNOTIFY      = 0x00000004,
		WS_EX_TOPMOST             = 0x00000008,
		WS_EX_ACCEPTFILES         = 0x00000010,
		WS_EX_TRANSPARENT         = 0x00000020,
		WS_EX_MDICHILD            = 0x00000040,
		WS_EX_TOOLWINDOW          = 0x00000080,
		WS_EX_WINDOWEDGE          = 0x00000100,
		WS_EX_CLIENTEDGE          = 0x00000200,
		WS_EX_CONTEXTHELP         = 0x00000400,
		WS_EX_RIGHT               = 0x00001000, WS_EX_LEFT           = 0x00000000,
		WS_EX_RTLREADING          = 0x00002000, WS_EX_LTRREADING     = 0x00000000,
		WS_EX_LEFTSCROLLBAR       = 0x00004000, WS_EX_RIGHTSCROLLBAR = 0x00000000,
		WS_EX_CONTROLPARENT       = 0x00010000,
		WS_EX_STATICEDGE          = 0x00020000,
		WS_EX_APPWINDOW           = 0x00040000,
		WS_EX_LAYERED             = 0x00080000,
		WS_EX_NOINHERITLAYOUT     = 0x00100000,
		WS_EX_NOREDIRECTIONBITMAP = 0x00200000,
		WS_EX_LAYOUTRTL           = 0x00400000,
		WS_EX_COMPOSITED          = 0x02000000,
		WS_EX_NOACTIVATE          = 0x08000000,
		WS_EX_OVERLAPPEDWINDOW    = WS_EX_WINDOWEDGE | WS_EX_CLIENTEDGE,
		WS_EX_PALETTEWINDOW       = WS_EX_WINDOWEDGE | WS_EX_TOOLWINDOW | WS_EX_TOPMOST
	};

	bool32 PostMessageW(MICROSOFT_WINDOW*, uint32_t message, uintptr_t wparam, intptr_t lparam);
	void PostQuitMessage(int exit_code);

	enum {
		LWA_COLORKEY = 1,
		LWA_ALPHA = 2
	};

	bool32 SetLayeredWindowAttributes(MICROSOFT_WINDOW*, uint32_t color_key, uint8_t alpha, uint32_t flags);

	enum {
		SW_HIDE = 0,
		SW_SHOWNORMAL = 1,
		SW_SHOWMINIMIZED = 2,
		SW_SHOWMAXIMIZED = 3,
		SW_MAXIMIZE = SW_SHOWMAXIMIZED,
		SW_SHOWNOACTIVATE = 4,
		SW_SHOW = 5,
		SW_MINIMIZE = 6,
		SW_SHOWMINNOACTIVE = 7,
		SW_SHOWNA = 8,
		SW_RESTORE = 9,
		SW_SHOWDEFAULT = 10,
		SW_FORCEMINIMIZE = 11
	};

	bool32 ShowWindow(MICROSOFT_WINDOW*, int);

	MICROSOFT_WINDOW* SetParent(MICROSOFT_WINDOW* child, MICROSOFT_WINDOW* new_parent);

	enum {
		SCF_ISSECURE    =      1, // flag: is the screen saver secure?

		SC_CLOSE        = 0xF060,
		SC_CONTEXTHELP  = 0xF180, // ? cursor, clicking control posts WM_HELP
		SC_DEFAULT      = 0xF160,
		SC_HOTKEY       = 0xF150, // lparam: window to activate
		SC_HSCROLL      = 0xF080,
		SC_KEYMENU      = 0xF100,
		SC_MAXIMIZE     = 0xF030,
		SC_MINIMIZE     = 0xF020,
		SC_MONITORPOWER = 0xF170, // lparam: -1 (powering on), 1 (low power), 2 (being shut off)
		SC_MOUSEMENU    = 0xF090,
		SC_MOVE         = 0xF010,
		SC_NEXTWINDOW   = 0xF040,
		SC_PREVWINDOW   = 0xF050,
		SC_RESTORE      = 0xF120,
		SC_SCREENSAVE   = 0xF140,
		SC_SIZE	        = 0xF000,
		SC_TASKLIST     = 0xF130,
		SC_VSCROLL      = 0xF070
	};

]]

if ffi.abi '64bit' then
	ffi.cdef [[
		intptr_t SetWindowLongPtrW(MICROSOFT_WINDOW*, int index, intptr_t new_value);
	]]
else
	ffi.cdef [[
		intptr_t SetWindowLongPtrW(MICROSOFT_WINDOW*, int index, intptr_t new_value) __asm__("SetWindowLongW");
	]]
end

-- ffi.C includes kernel32, user32, gdi32
return ffi.C
