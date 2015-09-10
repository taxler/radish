
#ifndef RADISH_TEXT_DOT_H
#define RADISH_TEXT_DOT_H

#include "lua.h"

const char* radish_push_utf8(lua_State *L, const wchar_t* wide_string);
wchar_t* radish_to_wstring(lua_State *L, int index);
wchar_t* radish_copy_malloc_wide(lua_State *L, int index);
wchar_t* radish_clone_wstring(const wchar_t* wstring);

#endif
