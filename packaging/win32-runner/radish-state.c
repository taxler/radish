
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

BOOL radish_script_step(radish_state* radish) {
	if (radish->script_fiber == NULL) {
		return FALSE;
	}
	SwitchToFiber(radish->script_fiber);
	switch (radish->msg.message) {
		case WMRADISH_TERMINATED:
			DeleteFiber(radish->script_fiber);
			radish->script_fiber = NULL;
			return FALSE;
	}
	return TRUE;
}

void radish_set_error_wide(radish_state* radish, const wchar_t* wstr) {
	size_t len;
	if (radish->error != NULL) {
		free(radish->error);
	}
	if (wstr == NULL) {
		radish->error = NULL;
		return;
	}
	len = wcslen(wstr);
	radish->error = (wchar_t*)malloc(sizeof(wchar_t) * (len + 1));
	wcsncpy(radish->error, wstr, len);
	radish->error[len] = 0;
}

void radish_set_error_utf8(radish_state* radish, const char* utf8) {
	size_t len;
	if (radish->error != NULL) {
		free(radish->error);
	}
	if (utf8 == NULL) {
		radish->error = NULL;
		return;
	}
	len = MultiByteToWideChar(65001, 0, utf8, -1, NULL, 0);
	radish->error = (wchar_t*)malloc(sizeof(wchar_t) * (len + 1));
	MultiByteToWideChar(65001, 0, utf8, -1, radish->error, len);
	radish->error[len] = 0;
}
