
#include <windows.h>
#include "radish-text.h"

const char* radish_push_utf8(lua_State* L, const wchar_t* wide_string) {
	size_t buf_size = WideCharToMultiByte(65001, 0, wide_string, -1, NULL, 0, NULL, NULL) - 1;
	char* buf = malloc(buf_size);
	WideCharToMultiByte(65001, 0, wide_string, -1, buf, buf_size, NULL, NULL);
	lua_pushlstring(L, buf, buf_size);
	free(buf);
	return lua_tostring(L, -1);
}

wchar_t* radish_copy_malloc_wide(lua_State *L, int index) {
	size_t len, buf_size;
	wchar_t* buf;
	const char* utf8 = lua_tolstring(L, index, &len);
	len += 1;
	buf_size = MultiByteToWideChar(65001, 0, utf8, len, NULL, 0);
	buf = (wchar_t*)malloc(sizeof(wchar_t) * buf_size);
	MultiByteToWideChar(65001, 0, utf8, len, buf, buf_size);
	return buf;
}

wchar_t* radish_to_wstring(lua_State *L, int index) {
	size_t len, buf_size;
	wchar_t* buf;
	const char* utf8 = lua_tolstring(L, index, &len);
	len += 1;
	buf_size = MultiByteToWideChar(65001, 0, utf8, len, NULL, 0);
	if (index < 0) index = lua_gettop(L) + 1 + index;
	buf = (wchar_t*)lua_newuserdata(L, sizeof(wchar_t) * buf_size);
	MultiByteToWideChar(65001, 0, utf8, len, buf, buf_size);
	lua_replace(L, index);
	return buf;
}
