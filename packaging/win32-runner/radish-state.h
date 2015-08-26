
#include <windows.h>

#ifndef RADISH_STATE_DOT_H
#define RADISH_STATE_DOT_H

#define MICROSOFT_WINDOW void

#define RADISH_HOST_WINDOW_CLASS_NAME L"RadishHost"

//@@BEGIN:EXPORTS@@

typedef struct radish_window {
	WNDCLASSEXW class_info;
	unsigned short atom;
	CREATESTRUCTW create_info;
	MICROSOFT_WINDOW* hwnd;
} radish_window;

enum {
	WMSPACE_RADISH = 0x4000, /* in WM_USER space: 0x0400 -> 0x7FFF */
	WMRADISH_TERMINATE = WMSPACE_RADISH + 0,
	WMRADISH_TERMINATED,
	WMRADISH_HANDLED,
	WMRADISH_DIALOG_REQUEST,
	WMRADISH_DIALOG_RESPONSE
};

typedef struct radish_state {
	const wchar_t* init_script_name;
	MSG msg;
	void* main_fiber;
	void* script_fiber;
	radish_window* host_window;
	wchar_t* error;
} radish_state;

radish_state* radish_get_state();

void radish_wait_message(radish_state*);

//@@END:EXPORTS@@

#undef MICROSOFT_WINDOW

void radish_init_for_states();
radish_state* radish_create_state(const wchar_t* init_script_name);
void radish_free_state();
BOOL radish_script_step(radish_state*);

void radish_init_host_window(radish_state* radish, radish_window* window);
void radish_create_window(radish_state* radish, radish_window* window);

void radish_set_error_wide(radish_state* radish, const wchar_t* wstr);
void radish_set_error_utf8(radish_state* radish, const char* utf8);

#endif
