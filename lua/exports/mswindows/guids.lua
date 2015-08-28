
local crt = require 'exports.crt'
local ffi = require 'ffi'

ffi.cdef [[

	typedef struct GUID { uint32_t Data1; uint16_t Data2, Data3; uint8_t Data4[8]; } GUID;	

	int32_t CoCreateGuid(GUID* out_guid);

]]

local ole32 = ffi.load 'ole32'

local t_guid; t_guid = ffi.metatype('GUID', {
	__tostring = function(guid)
		if ffi.cast('void*', guid) == nil then
			return '<NULL GUID>'
		end
		return string.format('%08x-%04x-%04x-%02x%02x-%02x%02x%02x%02x%02x%02x',
			guid.Data1,
			guid.Data2, guid.Data3,
			guid.Data4[0], guid.Data4[1], guid.Data4[2], guid.Data4[3],
			guid.Data4[4], guid.Data4[5], guid.Data4[6], guid.Data4[7])
	end;
	__eq = function(a, b)
		if ffi.cast('void*', a) == nil then
			return ffi.cast('void*', b) == nil
		elseif ffi.cast('void*', b) == nil then
			return false
		end
		return crt.memcmp(a, b, ffi.sizeof 'GUID') == 0
	end;
	__new = function(t_guid, v)
		if ffi.istype(t_guid, v) then
			return v
		elseif ffi.istype('GUID*', v) then
			if v == nil then
				return nil, 'null guid'
			end
			local guid = ffi.new(t_guid)
			ffi.copy(guid, v, ffi.sizeof(t_guid))
			return guid
		end
		if v == nil then
			local guid = ffi.new(t_guid)
			ole32.CoCreateGuid(guid)
			return guid
		end
		local a, b, c, d1, d2, d3, d4, d5, d6, d7, d8 = string.match(v,
			'^{?(%x%x%x%x%x%x%x%x)%-?(%x%x%x%x)%-?(%x%x%x%x)%-?(%x%x)(%x%x)%-?(%x%x)(%x%x)(%x%x)(%x%x)(%x%x)(%x%x)}?$')
		if not a then
			error('invalid guid string')
		end
		return ffi.new(t_guid, tonumber(a, 16), tonumber(b, 16), tonumber(c, 16),
			{tonumber(d1, 16), tonumber(d2, 16), tonumber(d3, 16), tonumber(d4, 16),
			tonumber(d5, 16), tonumber(d6, 16), tonumber(d7, 16), tonumber(d8, 16)})
	end;
})

return {
	guid = t_guid;
}
