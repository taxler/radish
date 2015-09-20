
local bit = require 'bit'
local bor, band = bit.bor, bit.band
local lshift, rshift = bit.lshift, bit.rshift
local t = {}

for codepoint = 0, 127 do
	local c = string.char(codepoint)
	local wide_c = c
	t[c] = wide_c
end

for codepoint = 128, 255 do
	local c = string.char(codepoint)
	local wide_c = string.char(
		bor(0xC0,      rshift(codepoint,  6)       ),
		bor(0x80, band(       codepoint     , 0x3F)))
	t[c] = wide_c
end

local meta; meta = {
	__add = function(self, extension)
		local extended = {}
		for k,v in pairs(self) do
			extended[k] = extension[k] or self[k]
		end
		return setmetatable(extended, meta)
	end;
}

return setmetatable(t, meta)
