
-- NOTE: the serialization here is ONLY intended for communication between threads
--  in a running process, NOT for saving to disk...!!

local ffi = require 'ffi'

local comms = {}

local tostring_types = {number=true, boolean=true, ['nil']=true}

local ptr_meta = {
	__serialize = function(self, buf)
		local ptr_buf = ffi.new('void*[1]', self.ptr)
		local stringed = ffi.string(ptr_buf, ffi.sizeof 'void*')
		if self.lib then
			buf[#buf+1] = string.format('ptr(%q, %q, %q)', stringed, self.type, self.lib)
		else
			buf[#buf+1] = string.format('ptr(%q, %q)', stringed, self.type)
		end
	end;
}

function comms.ptr(ptr, type, lib)
	return setmetatable({ptr=ptr, type=type, lib=lib}, ptr_meta)
end

local function append_value(buf, value, tables)
	local vtype = type(value)
	if vtype == 'string' then
		buf[#buf+1] = string.format('%q', value)
		return
	end
	if tostring_types[vtype]
	or (vtype == 'cdata' and (ffi.istype('int64_t', value) or ffi.istype('uint64_t', value))) then
		buf[#buf+1] = tostring(value)
		return
	end
	local m = getmetatable(value)
	if type(m) == 'table' and m.__serialize then
		m.__serialize(value, buf)
		return
	end
	if vtype == 'table' then
		if tables[value] then
			error('cannot serialize table with cycles')
		end
		tables[value] = true
		buf[#buf+1] = '{'
		for k, v in pairs(value) do
			buf[#buf+1] = '['
			append_value(buf, k, tables)
			buf[#buf+1] = ']='
			append_value(buf, v, tables)
			buf[#buf+1] = ';'
		end
		buf[#buf+1] = '}'
		tables[value] = nil
		return
	end
	error('unable to serialize:' .. tostring(value))
end

function comms.serialize(...)
	local buf = {}
	for i = 1, select('#', ...) do
		if i > 1 then
			buf[#buf+1] = ', '
		end
		append_value(buf, select(i, ...), {})
	end
	return table.concat(buf)
end

local function ptr(stringed, type, lib)
	if lib then
		require(lib)
	end
	return ffi.cast(type, ffi.cast('void**', stringed)[0])
end

function comms.deserialize(serialized)
	return assert(loadstring('local ptr=...;return ' .. serialized))(ptr)
end

return comms
