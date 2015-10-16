
local schema_proto = {}
local schema_meta = {__index = schema_proto}

return function(def)
	return setmetatable(def or {}, schema_meta)
end
