
local null_placeholder = require 'parse.json.null_placeholder'

local lib = {}

local array_meta = {}
lib.array_meta = array_meta

function lib.make_array(def)
	return setmetatable(def or {}, array_meta)
end

local object_meta = {}
lib.object_meta = object_meta

function lib.make_object(def)
	return setmetatable(def or {}, object_meta)
end

lib.null_placeholder = null_placeholder
lib.null = null_placeholder

function lib.type(v)
	local t = type(v)
	if t == 'string' or t == 'boolean' then
		return t
	end
	if v == null_placeholder then
		return 'null'
	end
	local m = getmetatable(v)
	if m == object_meta then
		return 'object'
	elseif m == array_meta then
		return 'array'
	end
	return nil
end

return lib
