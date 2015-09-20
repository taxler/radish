
local alias_list = require 'parse.substitution.charset.alias_list'

return setmetatable({}, {
	__index = function(self, identifier)
		if type(identifier) == 'string' then
			local aliases = alias_list[identifier]
			if aliases ~= nil then
				if type(aliases) == 'string' then
					return aliases
				else
					return aliases[1]
				end
			end
		end
	end;
})
