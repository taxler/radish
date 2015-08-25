
#include <windows.h>
#include "radish-state.h"
#include "radish-resources.h"

radish_state* main_radish = NULL;

LRESULT CALLBACK radish_window_proc(HWND hwnd, UINT message_id, WPARAM wparam, LPARAM lparam);

void radish_init_host_window(radish_state* radish, radish_window* window) {
    HMODULE hmodule = GetModuleHandle(NULL);

    main_radish = radish;
    radish->host_window = window;

	window->class_info.cbSize = sizeof(WNDCLASSEXW);
	window->class_info.style = 0;
	window->class_info.lpfnWndProc = radish_window_proc;
    window->class_info.cbClsExtra = 0;
    window->class_info.cbWndExtra = 0;
    window->class_info.hInstance = hmodule;
    window->class_info.hIcon = LoadIcon(hmodule, MAKEINTRESOURCE(32));
    if (window->class_info.hIcon == NULL) {
    	window->class_info.hIcon = LoadIcon(hmodule, MAKEINTRESOURCE(1));
    }
    window->class_info.hCursor = LoadCursor(NULL, IDC_ARROW);
    window->class_info.hbrBackground = (HBRUSH)GetStockObject(BLACK_BRUSH);
    window->class_info.lpszMenuName = NULL;
    window->class_info.lpszClassName = RADISH_HOST_WINDOW_CLASS_NAME;
    window->class_info.hIconSm = LoadIcon(hmodule, MAKEINTRESOURCE(16));
    if (window->class_info.hIconSm == NULL) {
    	window->class_info.hIconSm = LoadIcon(hmodule, MAKEINTRESOURCE(1));
    }

    window->atom = RegisterClassExW(&window->class_info);

    window->create_info.lpCreateParams = window;
    window->create_info.hInstance = hmodule;
    window->create_info.hMenu = NULL;
    window->create_info.hwndParent = NULL;
    window->create_info.cy = CW_USEDEFAULT;
    window->create_info.cx = CW_USEDEFAULT;
    window->create_info.y = CW_USEDEFAULT;
    window->create_info.x = CW_USEDEFAULT;
    window->create_info.style
    	= WS_OVERLAPPED
    	| WS_CAPTION
    	| WS_SYSMENU
    	| WS_THICKFRAME
    	| WS_MINIMIZEBOX
    	| WS_MAXIMIZEBOX
    	| WS_VISIBLE;
    window->create_info.lpszName = radish_get_title();
    window->create_info.lpszClass = window->class_info.lpszClassName;
    window->create_info.dwExStyle = 0;
}

void radish_create_window(radish_state* radish, radish_window* window) {
	CreateWindowExW(
		window->create_info.dwExStyle,
		window->create_info.lpszClass,
		window->create_info.lpszName,
		window->create_info.style,
		window->create_info.x,
		window->create_info.y,
		window->create_info.cx,
		window->create_info.cy,
		window->create_info.hwndParent,
		window->create_info.hMenu,
		window->create_info.hInstance,
		window->create_info.lpCreateParams);
}

void radish_hwnd_creating(HWND hwnd, CREATESTRUCT* creation) {
	radish_window* window = (radish_window*)creation->lpCreateParams;
	window->hwnd = hwnd;
}

BOOL radish_is_host_hwnd(radish_state* radish, HWND hwnd) {
	return radish != NULL && radish->host_window != NULL && radish->host_window->hwnd == hwnd;
}

LRESULT CALLBACK radish_window_proc(HWND hwnd, UINT message, WPARAM wparam, LPARAM lparam) {
	BOOL continuing_script;
	radish_state* radish = main_radish; // TODO: Use GetWindowLongPtr on hwnd?
	// preliminary tasks
	switch(message) {
		case WM_CREATE:
			radish_hwnd_creating(hwnd, (CREATESTRUCT*)lparam);
			break;
	}
	// pass over to Lua
	radish->msg.hwnd = hwnd;
	radish->msg.message = message;
	radish->msg.wParam = wparam;
	radish->msg.lParam = lparam;
	continuing_script = radish_script_step(radish);
	// do things that always need to be done, regardless of what Lua wants
	switch(message) {
		case WM_DESTROY:
			if (radish_is_host_hwnd(radish, hwnd)) {
				radish->host_window->hwnd = NULL;
			}
			break;
	}
	if (!continuing_script) {
		PostQuitMessage(radish->error == NULL ? EXIT_SUCCESS : EXIT_FAILURE);
	}
	else if (radish->msg.message == WMRADISH_HANDLED) {
		// Lua does not want the default action(s) to run,
		// and has provided its own return code
		return (LRESULT)radish->msg.lParam;
	}
	// do the default thing
	return DefWindowProcW(hwnd, message, wparam, lparam);
}
