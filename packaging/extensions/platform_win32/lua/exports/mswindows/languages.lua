
return setmetatable({
	neutral = 0;
}, {
	__index = function(self, k)
		if k == nil then
			return self.neutral
		end
		if type(k) == 'number' then
			return k
		end
	end;
})
