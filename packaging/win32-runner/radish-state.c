
#include <windows.h>
#include "radish-state.h"
#include "radish-resources.h"

DWORD radish_state_tls;

void radish_init_for_states() {
	radish_state_tls = TlsAlloc();
}

radish_state* radish_create_state(const wchar_t* init_script_name) {
	radish_state* state = TlsGetValue(radish_state_tls);
	if (state == NULL) {
		state = (radish_state*)malloc(sizeof(radish_state));
		TlsSetValue(radish_state_tls, state);
	}
	state->init_script_name = init_script_name;
	return state;
}

radish_state* radish_get_state() {
	void* data = TlsGetValue(radish_state_tls);
	if (data == NULL) {
		data = malloc(sizeof(radish_state));
		TlsSetValue(radish_state_tls, data);
	}
	return (radish_state*)data;
}

void radish_free_state() {
	void* data = TlsGetValue(radish_state_tls);
	if (data != NULL) {
		free(data);
		TlsFree(radish_state_tls);
	}
}

void radish_wait_message(radish_state* state) {
	if (state->main_fiber != NULL) {
		SwitchToFiber(state->main_fiber);
	}
	else {
		GetMessage(&state->msg, NULL, 0, 0);
	}
}

BOOL radish_handle_script_response(radish_state* radish) {
	switch (radish->msg.message) {
		case WMRADISH_TERMINATED:
			if (radish->msg.lParam != 0) {
				wchar_t* message = (wchar_t*)radish->msg.lParam;
				// TODO: use main hwnd when it exists
				MessageBoxW(NULL, message, radish_get_title(), MB_OK | MB_ICONERROR);
				free(message);
			}
			return FALSE;
	}
	return TRUE;
}
