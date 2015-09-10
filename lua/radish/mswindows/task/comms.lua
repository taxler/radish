
local ffi = require 'ffi'

local comms = {}

local tostring_types = {number=true, boolean=true, ['nil']=true}

local function append_value(buf, value)
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
	-- TODO: check for & error on table cycles
	if vtype == 'table' then
		buf[#buf+1] = '{'
		for k, v in pairs(value) do
			buf[#buf+1] = '['
			append_value(buf, k)
			buf[#buf+1] = ']='
			append_value(buf, v)
			buf[#buf+1] = ';'
		end
		buf[#buf+1] = '}'
		return
	end
	-- TODO: support cdata pointers
	error('unable to serialize:' .. tostring(value))
end

function comms.serialize(...)
	local buf = {}
	for i = 1, select('#', ...) do
		if i > 1 then
			buf[#buf+1] = ', '
		end
		append_value(buf, select(i, ...))
	end
	return table.concat(buf)
end

function comms.deserialize(serialized)
	return assert(loadstring('return ' .. serialized))()
end

return comms
