
#include <windows.h>

#ifndef RADISH_STATE_DOT_H
#define RADISH_STATE_DOT_H

#define MICROSOFT_WINDOW void
#define ACCELERATOR_TABLE void
#define bool32 BOOL

#define RADISH_HOST_WINDOW_CLASS_NAME L"RadishHost"

//@@BEGIN:EXPORTS@@

typedef struct radish_buffer {
	void* data;
	size_t length;
	void (*free)(void*);
} radish_buffer;

radish_buffer* radish_buffer_alloc(size_t len);
radish_buffer* radish_buffer_for_wstring(const wchar_t* wstr);
radish_buffer* radish_buffer_for_bytes(const void* data, size_t len);
const wchar_t* radish_buffer_to_wstring(const radish_buffer* buffer, size_t* out_len);
const void* radish_buffer_to_bytes(const radish_buffer* buffer, size_t* out_len);
void radish_buffer_free(radish_buffer*);

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
	WMRADISH_DIALOG_RESPONSE,
	WMRADISH_DESTROY_WINDOW_REQUEST,
	WMRADISH_TOGGLE_FULLSCREEN,
	WMRADISH_ENTER_FULLSCREEN,
	WMRADISH_ENTERED_FULLSCREEN,
	WMRADISH_LEAVE_FULLSCREEN,
	WMRADISH_LEFT_FULLSCREEN,
	WMRADISH_THREAD_READY,
	WMRADISH_THREAD_SEND_DATA,
	WMRADISH_THREAD_TERMINATED
};

enum {
	SCSPACE_RADISH = 0x4000, /* unassigned syscommand region: 0x0010 -> 0xEFFF */
	SCRADISH_TOGGLE_FULLSCREEN = SCSPACE_RADISH
};

typedef struct radish_state {
	const wchar_t* init_script_name;
	MSG msg;
	void* main_fiber;
	void* script_fiber;
	radish_window* host_window;
	wchar_t* error;
	ACCELERATOR_TABLE* accelerator_table;
	unsigned __int32 parent_thread_id;
} radish_state;

radish_state* radish_get_state();

void radish_wait_message(radish_state*);

unsigned __int32 radish_create_thread(const wchar_t* init_script_name);
bool32 radish_send_thread(unsigned __int32 id, const unsigned __int8* data, size_t data_size);

//@@END:EXPORTS@@

#undef MICROSOFT_WINDOW
#undef ACCELERATOR_TABLE

#undef bool32

void radish_init_for_states();
radish_state* radish_create_state(const wchar_t* init_script_name);
void radish_set_state(radish_state*);
void radish_free_state();
BOOL radish_script_step(radish_state*);

void radish_init_host_window(radish_state* radish, radish_window* window);
void radish_create_window(radish_state* radish, radish_window* window);

void radish_set_error_wide(radish_state* radish, const wchar_t* wstr);
void radish_set_error_utf8(radish_state* radish, const char* utf8);

#endif
