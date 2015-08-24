
#include <windows.h>
#include <strsafe.h>
#include "radish-resources.h"
#include "radish-text.h"
#include "lua.h"
#include "lauxlib.h"

void* get_file_version_info() {
	HMODULE module = GetModuleHandleW(NULL);
	wchar_t module_path[MAX_PATH];
	DWORD name_len = GetModuleFileNameW(module, module_path, MAX_PATH);
	DWORD info_len = GetFileVersionInfoSizeW(module_path, NULL);
	void* info;
	if (info_len == 0) {
		return NULL;
	}
	info = malloc(info_len);
	if (!GetFileVersionInfoW(module_path, 0, info_len, info)) {
		if (info != NULL) {
			free(info);
		}
		return NULL;
	}
	return info;
}

BOOL get_translation_id(void* fvinfo, WORD* out_id1, WORD* out_id2) {
	WORD* data_words;
	UINT data_len;
	if (out_id1 == NULL || out_id2 == NULL) {
		return FALSE;
	}
	if (!VerQueryValueW(fvinfo, L"\\VarFileInfo\\Translation", (LPVOID*)&data_words, &data_len)) {
		return FALSE;
	}
	if (data_len < 4) {
		return FALSE;
	}
	out_id1[0] = data_words[0];
	out_id2[0] = data_words[1];
	return TRUE;
}

wchar_t* get_title(void* fvinfo, WORD id1, WORD id2) {
	wchar_t* title;
	UINT title_len;
	wchar_t query_buf[] = L"\\StringFileInfo\\xxxxxxxx\\ProductName";
	StringCchPrintfW(query_buf, sizeof(query_buf), L"\\StringFileInfo\\%04x%04x\\ProductName", id1, id2);
	if (!VerQueryValueW(fvinfo, query_buf, &title, &title_len)) {
		return NULL;
	}
	return title;
}

wchar_t* radish_get_title() {
	void* fvinfo;
	WORD id1, id2;
	wchar_t* title;
	if ((fvinfo = get_file_version_info()) == NULL) {
		return DEFAULT_APP_TITLE;
	}
	if (!get_translation_id(fvinfo, &id1, &id2)) {
		free(fvinfo);
		return DEFAULT_APP_TITLE;
	}
	if ((title = get_title(fvinfo, id1, id2)) == NULL) {
		free(fvinfo);
		return DEFAULT_APP_TITLE;
	}
	free(fvinfo);
	return title;
}

int radish_load_init_script(lua_State *L, const wchar_t* name) {
	HRSRC hrsrc;
	HGLOBAL not_hglobal;
	LPVOID data;
	int result;
	if ((hrsrc = FindResourceW(NULL, name, L"INIT")) == NULL) {
		lua_pushliteral(L, "init script not found: ");
		radish_push_utf8(L, name);
		lua_concat(L, 2);
		return 1;
	}
	if ((not_hglobal = LoadResource(NULL, hrsrc)) == NULL) {
		lua_pushliteral(L, "unable to load init script resource: ");
		radish_push_utf8(L, name);
		lua_concat(L, 2);
		return 1;
	}
	if ((data = LockResource(not_hglobal)) == NULL) {
		lua_pushliteral(L, "unable to lock init script resource: ");
		radish_push_utf8(L, name);
		lua_concat(L, 2);
		return 1;
	}
	lua_pushliteral(L, "=");
	radish_push_utf8(L, name);
	lua_concat(L, 2);
	result = luaL_loadbuffer(L, (const char*)data, SizeofResource(NULL, hrsrc), lua_tostring(L, -1));
	lua_remove(L, -2);
	return result;
}
