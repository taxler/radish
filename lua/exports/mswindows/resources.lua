
local lib = {
	VS_FF_DEBUG = 0x1,
    VS_FF_PRERELEASE = 0x2,
    VS_FF_PATCHED = 0x4,
    VS_FF_PRIVATEBUILD = 0x8,
    VS_FF_INFOINFERRED = 0x10,
    VS_FF_SPECIALBUILD = 0x20,
    VS_FFI_SIGNATURE = 0xfeef04bd,
    VS_FFI_STRUCVERSION = 0x00010000,
    VOS__WINDOWS16 = 0x1,
    VOS__PM16 = 0x2,
    VOS__PM32 = 0x3,
    VOS__WINDOWS32 = 0x4,
    VOS_DOS = 0x10000,
    VOS_OS216 = 0x20000,
    VOS_NT = 0x40000,
    VOS_OS232 = 0x30000,
    VOS_NT_WINDOWS32 = 0x40004,
    VOS_UNKNOWN = 0,
    VFT_APP = 0x1,
    VFT_DLL = 0x2,
    VFT_DRV = 0x3,
    VFT_FONT = 0x4,
    VFT_VXD = 0x5,
    VFT_STATIC_LIB = 0x7,
    VFT_UNKNOWN = 0,
    VFT2_DRV_COMM = 0xA,
    VFT2_DRV_DISPLAY = 0x4,
    VFT2_DRV_INSTALLABLE = 0x8,
    VFT2_DRV_KEYBOARD = 0x2,
    VFT2_DRV_LANGUAGE = 0x3,
    VFT2_DRV_MOUSE = 0x5,
    VFT2_DRV_NETWORK = 0x6,
    VFT2_DRV_PRINTER = 0x1,
    VFT2_DRV_SOUND = 0x9,
    VFT2_DRV_SYSTEM = 0x7,
    VFT2_DRV_VERSIONED_PRINTER = 0xC,
    VFT2_UNKNOWN = 0,
    VFT2_FONT_RASTER = 0x1,
    VFT2_FONT_TRUETYPE = 0x3,
    VFT2_FONT_VECTOR = 0x2
}

local bit = require 'bit'
local ffi = require 'ffi'
require 'exports.mswindows.handles'
require 'exports.typedef.bool32'
local winstr = require 'exports.mswindows.strings'
local winlang = require 'exports.mswindows.languages'

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

	typedef struct VS_FIXEDFILEINFO {
		uint32_t dwSignature, dwStrucVersion, dwFileVersionMS, dwFileVersionLS;
		uint32_t dwProductVersionMS, dwProductVersionLS, dwFileFlagsMask, dwFileFlags;
		uint32_t dwFileOS, dwFileType, dwFileSubtype, dwFileDateMS, dwFileDateLS;
	} VS_FIXEDFILEINFO;

]]

local function make_int(i)
	return ffi.cast('const wchar_t*', i)
end

lib.RT_ICON = make_int(3)
lib.RT_GROUP_ICON = make_int(14)

lib.RT_VERSION = make_int(16)
lib.VS_VERSION_INFO = make_int(1)

lib.make_int = make_int

lib.VS_FIXEDFILEINFO = ffi.metatype('VS_FIXEDFILEINFO', {
	__index = {
		set_file_version = function(self, vstring)
			local v = {}
			for num in vstring:gmatch('%d+') do
				v[#v+1] = tonumber(num)
			end
			v[1] = v[1] or 1
			v[2] = v[2] or 0
			v[3] = v[3] or 0
			v[4] = v[4] or 0
			self.dwFileVersionMS = bit.bor(bit.lshift(v[1], 16), v[2])
			self.dwFileVersionLS = bit.bor(bit.lshift(v[3], 16), v[4])
		end;
		set_product_version = function(self, vstring)
			local v = {}
			for num in vstring:gmatch('%d+') do
				v[#v+1] = tonumber(num)
			end
			v[1] = v[1] or 1
			v[2] = v[2] or 0
			v[3] = v[3] or 0
			v[4] = v[4] or 0
			self.dwFileVersionMS = bit.bor(bit.lshift(v[1], 16), v[2])
			self.dwFileVersionLS = bit.bor(bit.lshift(v[3], 16), v[4])
		end;
		get_data = function(self)
			return ffi.string(self, ffi.sizeof('VS_FIXEDFILEINFO'))
		end;
	};
	__new = function(self_type)
		local v1, v2, v3, v4 = 1, 0, 0, 0
		local v = ffi.new(self_type, {
			dwSignature = lib.VS_FFI_SIGNATURE;
			dwStrucVersion = lib.VS_FFI_STRUCVERSION;
			dwFileOS = lib.VOS__WINDOWS32;
			dwFileType = lib.VFT_APP;

			dwFileVersionMS = bit.bor(bit.lshift(v1, 16), v2);
			dwFileVersionLS = bit.bor(bit.lshift(v3, 16), v4);
			dwProductVersionMS = bit.bor(bit.lshift(v1, 16), v2);
			dwProductVersionLS = bit.bor(bit.lshift(v3, 16), v4);

			dwFileFlagsMask = bit.bor(
				lib.VS_FF_DEBUG,
			    lib.VS_FF_PRERELEASE,
			    lib.VS_FF_PATCHED,
			    lib.VS_FF_PRIVATEBUILD,
			    lib.VS_FF_INFOINFERRED,
			    lib.VS_FF_SPECIALBUILD);
			--dwFileFlags     = bit.bor(mswin.VS_FF_PRERELEASE);

			--dwFileDateMS = now.dwHighDateTime;
			--dwFileDateLS = now.dwLowDateTime;
		})
		return v
	end;
})

local kernel32 = ffi.C

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
		res = kernel32.FindResourceExW(module, name, resource_type, winlang[language])
	else
		res = kernel32.FindResourceW(module, name, resource_type)
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

lib.get_for_module = assert(get_resource_for_module)

function lib.get(resource_type, name, language)
	return get_resource_for_module(nil, resource, name, language)
end

local function encode_uint16LE(v)
	return string.char(bit.band(v, 0xff), bit.rshift(v, 8))
end

local string_meta = {}

function lib.block_string(v)
	return setmetatable({v}, string_meta)
end

local function encode_block(block)
	local name = winstr.wide(assert(block.name, 'block must have a name'))
	name = ffi.string(name, ffi.sizeof(name))

	local block_type_id
	local text = block.text
	local data = block.bytes
	if text then
		if data ~= nil then
			error('block cannot include both text and bytes', 2)
		end
		block_type_id = 1
		if text == '' then
			data = ''
		else
			data = winstr.wide(text)
			data = ffi.string(data, ffi.sizeof(data))
		end
	elseif data == nil then
		error('block must include either text or bytes', 2)
	else
		block_type_id = 0
	end
	local data_padding = string.rep('\0', (4 - (#data % 4)) % 4)

	local child_data
	if block[1] then
		local buf = {}
		for i = 1, #block do
			buf[i] = encode_block(block[i])
		end
		child_data = table.concat(buf)
	else
		child_data = ''
	end

	local header_length = 2 + 2 + 2 + #name
	local header_padding = string.rep('\0', (4 - (header_length % 4)) % 4)

	local total_length = header_length + #header_padding + #data + #data_padding + #child_data

	local header = encode_uint16LE(total_length)
		.. encode_uint16LE(#data)
		.. encode_uint16LE(block_type_id)
		.. name

	return header .. header_padding .. data .. data_padding .. child_data
end

lib.encode_block = encode_block

local function decode_block(encoded, i)
	i = i or 1
	local block = {}
	local total_length = string.byte(encoded, i  ) + string.byte(encoded, i+1) * 0x100
	local value_length = string.byte(encoded, i+2) + string.byte(encoded, i+3) * 0x100
	local is_bytes = string.sub(encoded, i+4, i+5) == '\0\0'

	local j = 6
	while string.sub(encoded, i+j, i+j+1) ~= '\0\0' do
		j = j + 2
	end
	local name_ptr = ffi.cast('const char*', encoded) + (i - 1) + 6
	block.name = winstr.utf8(name_ptr, (j - 6) / 2)
	j = j + 2
	j = j + (4 - (j % 4)) % 4

	if value_length == 0 then
		block[is_bytes and 'bytes' or 'text'] = ''
	else
		if is_bytes then
			block.bytes = string.sub(encoded, i+j, i+j+value_length-1)
		else
			block.text = winstr.utf8(ffi.cast('const char*', encoded) + (i - 1) + j, value_length / 2)
			-- remove null terminator
			block.text = block.text:match('(.-)%z?$')
		end
		j = j + value_length
		j = j + (4 - (j % 4)) % 4
	end

	local end_pos = i + total_length
	i = i + j

	while i < end_pos do
		block[#block+1], i = decode_block(encoded, i)
	end

	return block, end_pos
end

lib.decode_block = decode_block

return lib
