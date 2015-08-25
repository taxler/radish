
#include "lua.h"

#ifndef RADISH_RESOURCES_DOT_H
#define RADISH_RESOURCES_DOT_H

#define DEFAULT_APP_TITLE L"Radish"

int radish_load_init_script(lua_State *L, const wchar_t* name);
wchar_t* radish_get_title();
void radish_add_resource_module_loader(lua_State *L);

#endif
