
#include <windows.h>
#include "radish-scripting.h"
#include "radish-state.h"
#include "radish-resources.h"
#include "radish-text.h"

#include "lua.h"
#include "lauxlib.h"
#include "lualib.h"
#include "luaconf.h"

VOID CALLBACK radish_script_fiber_proc(PVOID lpParameter);

void* radish_create_script_fiber(radish_state* radish) {
	return CreateFiber(0, radish_script_fiber_proc, radish);
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

VOID CALLBACK radish_script_fiber_proc(PVOID lpParameter) {
	radish_state* radish = (radish_state*)lpParameter;
	int errfunc_i;

	lua_State *L = luaL_newstate();

	lua_pushlightuserdata(L, radish);
	lua_setfield(L, LUA_REGISTRYINDEX, "radish_state*");

	lua_atpanic(L, radish_error);

	luaL_openlibs(L);

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
