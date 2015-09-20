
local identifier_to_aliases = require 'parse.substitution.charset.alias_list'

local alias_to_identifier = {}

for identifier, aliases in pairs(identifier_to_aliases) do
	do
		alias_to_identifier[identifier] = identifier
		local alias = string.lower(identifier)
		alias_to_identifier[alias] = identifier
	end
	if type(aliases) == 'string' then
		alias_to_identifier[aliases] = identifier
		local alias = string.lower(aliases)
		alias_to_identifier[alias] = identifier
	else
		for i, alias in ipairs(aliases) do
			alias_to_identifier[alias] = identifier
			alias = string.lower(alias)
			alias_to_identifier[alias] = identifier
		end
	end
end

setmetatable(alias_to_identifier, {
	__index = function(self, key)
		if type(key) == 'string' then
			local alias = string.lower(key)
			return rawget(self, alias)
		end
	end;
})

return alias_to_identifier
