
local lib = {}
package.loaded[(...)] = lib

local ffi = require 'ffi'
require 'exports.mswindows.handles'
require 'exports.mswindows.handles.module'
require 'exports.typedef.bool32'

ffi.cdef [[

	RESOURCE_UPDATE_A* BeginUpdateResourceA(const char* path, bool32 delete_existing);
	RESOURCE_UPDATE_W* BeginUpdateResourceW(const wchar_t* path, bool32 delete_existing);

	bool32 UpdateResourceA(
		RESOURCE_UPDATE_A*,
		const char* type,
		const char* name,
		uint16_t language,
		void* data,
		uint32_t data_length);

	bool32 UpdateResourceW(
		RESOURCE_UPDATE_W*,
		const wchar_t* type,
		const wchar_t* name,
		uint16_t language,
		void* data,
		uint32_t data_length);

	bool32 EndUpdateResourceA(RESOURCE_UPDATE_A*, bool32 discard_changes);
	bool32 EndUpdateResourceW(RESOURCE_UPDATE_W*, bool32 discard_changes);

	RESOURCE* FindResourceA(
		MODULE*,
		const char* name,
		const char* type);
	RESOURCE* FindResourceW(
		MODULE*,
		const wchar_t* name,
		const wchar_t* type);
	RESOURCE* FindResourceExA(
		MODULE*,
		const char* name,
		const char* type,
		uint16_t languageID);
	RESOURCE* FindResourceExW(
		MODULE*,
		const wchar_t* name,
		const wchar_t* type,
		uint16_t languageID);
	void* LoadResource(MODULE*, RESOURCE*);
	void* LockResource(void*);
	uint32_t SizeofResource(MODULE*, RESOURCE*);

	typedef bool32 (__stdcall *EnumResTypeProcA)(
		MODULE*,
		char* type,
		intptr_t lparam);
	typedef bool32 (__stdcall *EnumResTypeProcW)(
		MODULE*,
		wchar_t* type,
		intptr_t lparam);
	bool32 EnumResourceTypesA(
		MODULE*,
		EnumResTypeProcA,
		intptr_t lparam);
	bool32 EnumResourceTypesW(
		MODULE*,
		EnumResTypeProcW,
		intptr_t lparam);
	typedef bool32 (__stdcall *EnumResNameProcA)(
		MODULE*,
		const char* type,
		char* name,
		intptr_t lparam);
	typedef bool32 (__stdcall *EnumResNameProcW)(
		MODULE*,
		const wchar_t* type,
		wchar_t* name,
		intptr_t lparam);
	bool32 EnumResourceNamesA(
		MODULE*,
		const char* type,
		EnumResNameProcA,
		intptr_t lparam);
	bool32 EnumResourceNamesW(
		MODULE*,
		const wchar_t* type,
		EnumResNameProcW,
		intptr_t lparam);
	typedef bool32 (__stdcall *EnumResLangProcA)(
		MODULE*,
		const char* type,
		const char* name,
		uint16_t languageID,
		intptr_t lparam);
	typedef bool32 (__stdcall *EnumResLangProcW)(
		MODULE*,
		const wchar_t* type,
		const wchar_t* name,
		uint16_t languageID,
		intptr_t lparam);
	bool32 EnumResourceLanguagesA(
		MODULE*,
		const char* type,
		const char* name,
		EnumResLangProcA,
		intptr_t lparam);
	bool32 EnumResourceLanguagesW(
		MODULE*,
		const wchar_t* type,
		const wchar_t* name,
		EnumResLangProcW,
		intptr_t lparam);

]]

local function make_int(i)
	return ffi.cast('const wchar_t*', i)
end

lib.RT_ICON = make_int(3)
lib.RT_GROUP_ICON = make_int(14)

lib.make_int = make_int

local function get_resource_for_module(module, resource_type, name, language)
	if type(resource_type) == 'number' then
		resource_type = make_int(resource_type)
	elseif type(resource_type) == 'string' then
		resource_type = winstr.wide(resource_type)
	end
	if type(name) == 'number' then
		name = make_int(name)
	elseif type(name) == 'string' then
		name = winstr.wide(name)
	end
	local res
	if language then
		res = kernel32.FindResourceW(module, name, resource_type)
	else
		res = kernel32.FindResourceW(module, name, resource_type, winlang[language])
	end
	if res == nil then
		return nil, 'resource not found'
	end
	local loaded = kernel32.LoadResource(module, res)
	if loaded == nil then
		return nil, 'unable to load resource'
	end
	local locked = kernel32.LockResource(loaded)
	if locked == nil then
		return nil, 'unable to lock resource'
	end
	return ffi.string(locked, kernel32.SizeofResource(module, res))
end

lib.get_for_module = get_resource_for_module

function lib.get(resource_type, name, language)
	return get_resource_for_module(nil, resource, name, language)
end

return lib
