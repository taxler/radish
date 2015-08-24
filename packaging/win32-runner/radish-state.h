
#include <windows.h>

#ifndef RADISH_STATE_DOT_H
#define RADISH_STATE_DOT_H

//@@BEGIN:EXPORTS@@

enum {
	WMSPACE_RADISH = 0x4000, /* in WM_USER space: 0x0400 -> 0x7FFF */
	WMRADISH_TERMINATE = WMSPACE_RADISH + 0,
	WMRADISH_TERMINATED
};

typedef struct radish_state {
	const wchar_t* init_script_name;
	MSG msg;
	void* main_fiber;
	void* script_fiber;
} radish_state;

radish_state* radish_get_state();

void radish_wait_message(radish_state*);

//@@END:EXPORTS@@

void radish_init_for_states();
radish_state* radish_create_state(const wchar_t* init_script_name);
void radish_free_state();
BOOL radish_handle_script_response(radish_state*);

#endif
