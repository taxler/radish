
local bit = require 'bit'

return setmetatable({}, {
	__newindex = function(self, k, v)
		if type(k) ~= 'string' or type(v) ~= 'number' then
			error('bad error definition', 2)
		end
		v = bit.tobit(v)
		rawset(self, k, v)
		rawset(self, v, k)
	end;
	__index = function(self, k)
		if type(k) == 'string' then
			error('undefined error: ' .. k, 2)
		end
		if type(k) ~= 'number' then
			return nil
		end
		local bk = bit.tobit(k)
		if bk ~= k then
			local entry = self[bk]
			if entry ~= nil then
				return entry
			end
		end
		return '(error 0x' .. bit.tohex(bk) .. ')'
	end;
	__call = function(self, def)
		for k,v in pairs(def) do
			self[k] = v
		end
		return self
	end;
})
