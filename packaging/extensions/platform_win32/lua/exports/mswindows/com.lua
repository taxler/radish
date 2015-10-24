
local ffi = require 'ffi'
local mswin = require 'exports.mswindows'
local winguids = require 'exports.mswindows.guids'
local winchecks = require 'exports.mswindows.checks'

local com = {}

local com_meta = {__index = function(self, key)  return self.lpVtbl[key];  end}

local com_objects = {}

local function add_methods(buf, object_name, object_def)
	if not object_def.root then
		add_methods(buf, object_name, com_objects[object_def.inherits or 'IUnknown'])
	end
	for i, method_def in ipairs(object_def.methods) do
		buf[#buf+1] = (method_def.ret or 'int32_t')
			.. ' (__stdcall *' .. method_def[1] .. ')(' .. object_name .. '* self'
		if method_def[2] then
			buf[#buf+1] = ', ' .. method_def[2] .. ');\n'
		else
			buf[#buf+1] = ');\n'
		end
	end
end

function com.predef(...)
	for i = 1, select('#', ...) do
		local name = select(i, ...)
		if not pcall(ffi.typeof, name) then
			ffi.cdef(string.format('typedef struct %s %s;', name, name))
		end
	end
end

function com.def(objects_def)
	for i, object_def in ipairs(objects_def) do
		object_def.methods = object_def.methods or {}
		local object_name = object_def[1]
		local stored_version = {iid = assert(winguids.guid(object_def.iid))}
		if object_def.root then
			if object_def.inherits then
				error('root object cannot inherit')
			end
			stored_version.root = true
		elseif object_def.inherits then
			stored_version.inherits = object_def.inherits
		end
		stored_version.methods = object_def.methods
		com_objects[object_name] = stored_version
		com.predef(object_name)
	end
	for i, object_def in ipairs(objects_def) do
		local object_name = object_def[1]
		local object_fields = object_def.fields or ''
		local buf = {}
		add_methods(buf, object_name, object_def)
		local object_methods = table.concat(buf)
		local struct_cdef = string.format(
			'typedef struct %s {\n  struct {\n%s\n  } *lpVtbl;\n%s\n} %s;',
			object_name, object_methods, object_fields, object_name)
		ffi.cdef(struct_cdef)
		ffi.metatype(object_name, com_meta)
	end
end

function com.def_entry_enum(def)
	local object = {iid = def.iid}
	if def[1] then
		object[1] = def[1]
	else
		local typename = def.ctype
		local interfacename = typename:match('^I(.*)%*$')
		object[1] = 'IEnum' .. (interfacename or typename)
	end
	object.methods = {
		{'Next', 'uint32_t celt, ' .. def.ctype .. '* rgelt, uint32_t* pceltFetched'};
		{'Skip', 'uint32_t celt'};
		{'Reset'};
		{'Clone', object[1] .. '** ppenum'};
	}
	return object
end

com.def {
	{'IUnknown', root = true;
		methods = {
			{'QueryInterface', 'GUID* guid, void** out_interface'};
			{'AddRef', ret='uint32_t'};
			{'Release', ret='uint32_t'};
		};
		iid = '00000000-0000-0000-C000000000000046';
	};
  --com.def_entry_enum{ ctype='IUnknown*', iid='00000100-0000-0000-C000-000000000046' };
}

ffi.cdef [[

	typedef enum {
		CLSCTX_INPROC_SERVER            = 0x1,
		CLSCTX_INPROC_HANDLER           = 0x2,
		CLSCTX_LOCAL_SERVER             = 0x4,
		CLSCTX_INPROC_SERVER16          = 0x8,
		CLSCTX_REMOTE_SERVER            = 0x10,
		CLSCTX_INPROC_HANDLER16         = 0x20,
		CLSCTX_RESERVED1                = 0x40,
		CLSCTX_RESERVED2                = 0x80,
		CLSCTX_RESERVED3                = 0x100,
		CLSCTX_RESERVED4                = 0x200,
		CLSCTX_NO_CODE_DOWNLOAD         = 0x400,
		CLSCTX_RESERVED5                = 0x800,
		CLSCTX_NO_CUSTOM_MARSHAL        = 0x1000,
		CLSCTX_ENABLE_CODE_DOWNLOAD     = 0x2000,
		CLSCTX_NO_FAILURE_LOG           = 0x4000,
		CLSCTX_DISABLE_AAA              = 0x8000,
		CLSCTX_ENABLE_AAA               = 0x10000,
		CLSCTX_FROM_DEFAULT_CONTEXT     = 0x20000,
		CLSCTX_ACTIVATE_32_BIT_SERVER   = 0x40000,
		CLSCTX_ACTIVATE_64_BIT_SERVER   = 0x80000,
		CLSCTX_ENABLE_CLOAKING          = 0x100000,
		CLSCTX_PS_DLL                   = 0x80000000,

		CLSCTX_ALL = CLSCTX_INPROC_SERVER | CLSCTX_INPROC_HANDLER | CLSCTX_LOCAL_SERVER
	} CLSCTX;
	
	int32_t CoCreateInstance(GUID* clsid, IUnknown* outer, CLSCTX context, GUID* iid, void** out_obj);
	int32_t CoInitialize(void* must_be_null);
	
]]

function com.iidof(typename)
	local typedef = com_objects[typename]
	if not typedef then
		error('COM type not defined: ' .. tostring(typename), 2)
	end
	return typedef.iid
end

local ole32 = ffi.load 'ole32'

ole32.CoInitialize(nil)

local function com_gc(v)
	v:Release()
end

function com.gc(v)
	if (v == nil) then
		return nil
	end
	return ffi.gc(v, com_gc)
end

function com.release(...)
	for i = 1, select('#', ...) do
		local v = select(i, ...)
		if v ~= nil then
			ffi.gc(v, nil)
			v:Release()
		end
	end
end

function com.cast(newtype, value)
	local temp = ffi.new(newtype .. '*[1]')
	if (value:QueryInterface(com.iidof(newtype), ffi.cast('void**', temp)) == 0) then
		return ffi.gc(temp[0], com_gc)
	else
		return nil
	end
end

function com.new(clsid, name)
	name = name or 'IUnknown'
	local temp = ffi.new(name .. '*[1]')
	if (ole32.CoCreateInstance(
    		winguids.guid(clsid),
    		nil,
			ole32.CLSCTX_INPROC_SERVER,
			com.iidof(name),
			ffi.cast('void**', temp)) == 0) then
		return ffi.gc(temp[0], com_gc)
	else
		return nil, 'unable to create class: ' .. tostring(clsid)
	end
end

function com.check_out(type, callback)
	local result, message = winchecks.out(type, callback)
	if not result then
		return result, message
	end
	return com.gc(result)
end

return com
