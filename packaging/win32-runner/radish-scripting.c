
#include <windows.h>
#include "radish-scripting.h"
#include "radish-state.h"
#include "radish-resources.h"
#include "radish-text.h"
#include "radish-dialog.h"

#include "lua.h"
#include "lauxlib.h"
#include "lualib.h"
#include "luaconf.h"

VOID CALLBACK radish_script_fiber_proc(PVOID lpParameter);
DWORD WINAPI radish_thread_proc(LPVOID lpParameter);

void* radish_create_script_fiber(radish_state* radish) {
	return CreateFiber(0, radish_script_fiber_proc, radish);
}

DWORD radish_create_thread(const wchar_t* init_script_name) {
	DWORD new_thread_id;
	radish_state* new_radish_state = (radish_state*)malloc(sizeof(radish_state));
	size_t name_len = wcslen(init_script_name);
	wchar_t* script_name_copy = (wchar_t*)malloc(sizeof(wchar_t) * (name_len + 1));
	memcpy(script_name_copy, init_script_name, name_len * sizeof(wchar_t));
	script_name_copy[name_len] = 0;
	memset(new_radish_state, 0, sizeof(radish_state));
	new_radish_state->init_script_name = script_name_copy;
	new_radish_state->parent_thread_id = GetCurrentThreadId();
	CreateThread(NULL, 0, radish_thread_proc, new_radish_state, 0, &new_thread_id);
	return new_thread_id;
}

int radish_error(lua_State *L) {
	radish_state* radish;
	lua_getfield(L, LUA_REGISTRYINDEX, "radish_state*");
	radish = (radish_state*)lua_touserdata(L, -1);
	lua_pop(L, 1);
	if (radish != NULL) {
		radish_set_error_utf8(radish, lua_tostring(L, -1));
	}
	lua_close(L);
	if (radish != NULL && radish->main_fiber != NULL) {
		for (; ; ) {
			radish->msg.message = WMRADISH_TERMINATED;
			SwitchToFiber(radish->main_fiber);
		}
	}
	// TODO: thread posts error message back to main thread
	ExitThread(EXIT_FAILURE);
}

static lua_State *getthread (lua_State *L, int *arg) {
	if (lua_isthread(L, 1)) {
		*arg = 1;
		return lua_tothread(L, 1);
	}
	else {
		*arg = 0;
		return L;
	}
}

#define LEVELS1 12      /* size of the first part of the stack */
#define LEVELS2 10      /* size of the second part of the stack */

int radish_formulate_error_message(lua_State *L) {
	int level;
	int firstpart = 1;  /* still before eventual `...' */
	int arg;
	lua_State *L1 = getthread(L, &arg);
	lua_Debug ar;
	if (lua_isnumber(L, arg+2)) {
		level = (int)lua_tointeger(L, arg+2);
		lua_pop(L, 1);
	}
	else {
		level = (L == L1) ? 1 : 0;  /* level 0 may be this own function */
	}
	if (lua_gettop(L) == arg) {
		lua_pushliteral(L, "");
	}
	else if (!lua_isstring(L, arg+1)) {
		return 1;  /* message is not a string */
	}
	else {
		lua_pushliteral(L, "\n");
	}
	lua_pushliteral(L, "stack traceback:");
	while (lua_getstack(L1, level++, &ar)) {
		if (level > LEVELS1 && firstpart) {
			/* no more than `LEVELS2' more levels? */
			if (!lua_getstack(L1, level+LEVELS2, &ar)) {
				level--;  /* keep going */
			}
			else {
				lua_pushliteral(L, "\n\t...");  /* too many levels */
				while (lua_getstack(L1, level+LEVELS2, &ar)) level++; /* find last levels */
			}
			firstpart = 0;
			continue;
		}
		lua_pushliteral(L, "\n\t");
		lua_getinfo(L1, "Snl", &ar);
		lua_pushfstring(L, "%s:", ar.short_src);
		if (ar.currentline > 0) {
			lua_pushfstring(L, "%d:", ar.currentline);
		}
		if (*ar.namewhat != '\0') {
			lua_pushfstring(L, " in function " LUA_QS, ar.name);
		}
		else {
			if (*ar.what == 'm') {
				lua_pushfstring(L, " in main chunk");
			}
			else if (*ar.what == 'C' || *ar.what == 't') {
				lua_pushliteral(L, " ?");  /* C function or tail call */
			}
			else {
				lua_pushfstring(L, " in function <%s:%d>", ar.short_src, ar.linedefined);
			}
		}
		lua_concat(L, lua_gettop(L) - arg);
	}
	lua_concat(L, lua_gettop(L) - arg);
	return 1;
}

extern int luaopen_lpeg(lua_State *L);

VOID CALLBACK radish_script_fiber_proc(PVOID lpParameter) {
	radish_state* radish = (radish_state*)lpParameter;
	int errfunc_i;

	lua_State *L = luaL_newstate();

	lua_pushlightuserdata(L, radish);
	lua_setfield(L, LUA_REGISTRYINDEX, "radish_state*");

	lua_atpanic(L, radish_error);

	luaL_openlibs(L);

	luaL_loadstring(L, "local name, loader = ...; package.preload[name] = loader");
	lua_pushliteral(L, "lpeg");
	lua_pushcfunction(L, luaopen_lpeg);
	lua_call(L, 2, 0);

	radish_add_resource_module_loader(L);

	lua_pushcfunction(L, radish_formulate_error_message);
	errfunc_i = lua_gettop(L);

	if (0 != radish_load_init_script(L, radish->init_script_name)) {
		lua_pushcfunction(L, radish_error);
		lua_insert(L, -2);
		lua_call(L, 1, 0);
		return;
	}

	if (0 != lua_pcall(L, 0, 0, errfunc_i)) {
		lua_pushcfunction(L, radish_error);
		lua_insert(L, -2);
		lua_call(L, 1, 0);
		return;
	}

	lua_close(L);

	for (; ; ) {
		radish->msg.message = WMRADISH_TERMINATED;
		SwitchToFiber(radish->main_fiber);
	}
}

BOOL radish_script_running(radish_state* radish) {
	return radish->script_fiber != NULL;
}

void radish_update_first(radish_state* radish) {
	radish->last_update = GetTickCount();
	radish->msg.message = WMRADISH_UPDATE;
	radish->msg.lParam = 0;
	radish_script_step(radish);
}
void radish_update_certain(radish_state* radish) {
	DWORD ticks = GetTickCount();
	DWORD diff = ticks - radish->last_update;
	radish->last_update = ticks;
	radish->msg.message = WMRADISH_UPDATE;
	radish->msg.wParam = (WPARAM)diff;
	radish->msg.hwnd = NULL;
	radish_script_step(radish);
}
void radish_update_maybe(radish_state* radish) {
	DWORD ticks = GetTickCount();
	DWORD diff = ticks - radish->last_update;
	if (radish->update_timeout > 0 && diff >= radish->update_timeout) {
		radish->last_update = ticks;
		radish->msg.message = WMRADISH_UPDATE;
		radish->msg.hwnd = NULL;
		radish->msg.wParam = (WPARAM)diff;
		radish_script_step(radish);
	}
}
DWORD radish_update_timeout(radish_state* radish) {
	DWORD ticks = GetTickCount();
	DWORD diff = ticks - radish->last_update;
	if (radish->update_timeout == 0) return INFINITE;
	if (diff >= radish->update_timeout) return 0;
	return radish->update_timeout - diff;
}

DWORD WINAPI radish_thread_proc(LPVOID lpParameter) {
	radish_state* radish = (radish_state*)lpParameter;
	radish->main_fiber = ConvertThreadToFiber(NULL);
	radish->script_fiber = radish_create_script_fiber(radish);
	radish_set_state(radish);

	if (radish_script_step(radish)) {
		// force the creation of the message queue
		PeekMessage(&radish->msg, NULL, WM_USER, WM_USER, PM_NOREMOVE);
		// notify the parent thread that we are ready to receive events
		PostThreadMessage(radish->parent_thread_id, WMRADISH_THREAD_READY, GetCurrentThreadId(), 0);
		radish_update_first(radish);
		do {
			DWORD timeout = radish_update_timeout(radish);
			DWORD result = MsgWaitForMultipleObjects(
				radish->wait_object_count,
				radish->wait_objects,
				FALSE,
				timeout,
				QS_ALLINPUT);
			if (result == WAIT_OBJECT_0 + radish->wait_object_count) {
				BOOL first = TRUE;
				while (PeekMessage(&radish->msg, NULL, 0, 0, PM_REMOVE)) {
					UINT message = radish->msg.message;
					HWND hwnd = radish->msg.hwnd;
					WPARAM wparam = radish->msg.wParam;
					LPARAM lparam = radish->msg.lParam;
					// do not allow a torrent of messages to prevent wait object notifications
					// or updates from getting through
					if (first) {
						first = FALSE;
					}
					else {
						DWORD result2 = WaitForMultipleObjects(
							radish->wait_object_count,
							radish->wait_objects,
							FALSE,
							0);
						if (result2 >= WAIT_OBJECT_0 && result2 < (WAIT_OBJECT_0 + radish->wait_object_count)) {
							radish->msg.message = WMRADISH_WAIT_OBJECT_SIGNALLED;
							radish->msg.hwnd = NULL;
							radish->msg.lParam = (LPARAM)(result2 - WAIT_OBJECT_0);
							radish->msg.wParam = (WPARAM)radish->wait_objects[radish->msg.lParam];
							radish_script_step(radish);
						}
						else if (result2 >= WAIT_ABANDONED_0 && result2 < (WAIT_ABANDONED_0 + radish->wait_object_count)) {
							radish->msg.message = WMRADISH_MUTEX_ABANDONED;
							radish->msg.hwnd = NULL;
							radish->msg.lParam = (LPARAM)(result2 - WAIT_ABANDONED_0);
							radish->msg.wParam = (WPARAM)radish->wait_objects[radish->msg.lParam];
							radish_script_step(radish);
						}
						radish->msg.message = message;
						radish->msg.hwnd = hwnd;
						radish->msg.wParam = wparam;
						radish->msg.lParam = lparam;
					}
					radish_script_step(radish);
					switch (message) {
						case WMRADISH_DIALOG_RESPONSE:
							radish_free_dialog(radish, (radish_dialog*)lparam);
							break;
						case WMRADISH_THREAD_SEND_DATA:
							radish_buffer_free((radish_buffer*)lparam);
							break;
					}
					radish_update_maybe(radish);
				}
			}
			else if (result >= WAIT_OBJECT_0 && result < (WAIT_OBJECT_0 + radish->wait_object_count)) {
				radish->msg.message = WMRADISH_WAIT_OBJECT_SIGNALLED;
				radish->msg.hwnd = NULL;
				radish->msg.lParam = (LPARAM)(result - WAIT_OBJECT_0);
				radish->msg.wParam = (WPARAM)radish->wait_objects[radish->msg.lParam];
				radish_script_step(radish);
				radish_update_maybe(radish);
			}
			else if (result >= WAIT_ABANDONED_0 && result < (WAIT_ABANDONED_0 + radish->wait_object_count)) {
				radish->msg.message = WMRADISH_MUTEX_ABANDONED;
				radish->msg.hwnd = NULL;
				radish->msg.lParam = (LPARAM)(result - WAIT_ABANDONED_0);
				radish->msg.wParam = (WPARAM)radish->wait_objects[radish->msg.lParam];
				radish_script_step(radish);
				radish_update_maybe(radish);
			}
			else if (result == WAIT_FAILED) {
				radish->error = L"MsgWaitForMultipleObjects Error";
				break;
			}
			else if (result == WAIT_TIMEOUT) {
				radish_update_certain(radish);
				if (timeout == 0) Sleep(0);
			}
			else {
				radish->error = L"Unknown result from MsgWaitForMultipleObjects";
				break;
			}
		}
		while (radish_script_running(radish));
	}
	PostThreadMessage(
		radish->parent_thread_id,
		WMRADISH_THREAD_TERMINATED,
		GetCurrentThreadId(),
		(LPARAM)radish);
	return radish->error == NULL ? EXIT_FAILURE : EXIT_SUCCESS;
}

BOOL radish_send_thread(UINT thread_id, const BYTE* data, size_t data_len) {
	return PostThreadMessage(
		thread_id,
		WMRADISH_THREAD_SEND_DATA,
		(WPARAM)GetCurrentThreadId(),
		(LPARAM)radish_buffer_for_bytes(data, data_len));
}
