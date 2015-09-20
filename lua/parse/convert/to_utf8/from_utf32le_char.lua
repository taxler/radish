
local m = require 'lpeg'
local re = require 're'

local strbyte, strchar = string.byte, string.char
local bit = require 'bit'
local bor, band = bit.bor, bit.band
local lshift, rshift = bit.lshift, bit.rshift

return re.compile([[

	result <- ascii7 / codepoint

	ascii7 <- %ASCII7_CHAR ((%NULL_CHAR %NULL_CHAR %NULL_CHAR) -> '')

	codepoint <- (....) -> from_codepoint

]], {
	ASCII7_CHAR = require 'parse.char.ascii7';
	NULL_CHAR = m.P '\0';
	from_codepoint = function(v)
		local lowest, lower, higher, highest = strbyte(v, 1, 4)
		local codepoint = bor(
			        lowest     ,
			lshift(  lower,  8),
			lshift( higher, 16),
			lshift(highest, 24))
		if codepoint < 0 then
			-- codepoints >= 0x80000000 are out of range
			return '?'
		elseif codepoint < 0x800 then
			return string.char(
				bor(0xC0,      rshift(codepoint,  6)       ),
				bor(0x80, band(       codepoint     , 0x3F)))
		elseif codepoint < 0x10000 then
			return string.char(
				bor(0xE0,      rshift(codepoint, 12)       ),
				bor(0x80, band(rshift(codepoint,  6), 0x3F)),
				bor(0x80, band(       codepoint     , 0x3F)))
		elseif codepoint < 0x200000 then
			return string.char(
				bor(0xF0,      rshift(codepoint, 18)       ),
				bor(0x80, band(rshift(codepoint, 12), 0x3F)),
				bor(0x80, band(rshift(codepoint,  6), 0x3F)),
				bor(0x80, band(       codepoint     , 0x3F)))
		elseif codepoint < 0x4000000 then
			return string.char(
				bor(0xF8,      rshift(codepoint, 24)       ),
				bor(0x80, band(rshift(codepoint, 18), 0x3F)),
				bor(0x80, band(rshift(codepoint, 12), 0x3F)),
				bor(0x80, band(rshift(codepoint,  6), 0x3F)),
				bor(0x80, band(       codepoint     , 0x3F)))
		else
			return string.char(
				bor(0xFC,      rshift(codepoint, 30)       ),
				bor(0x80, band(rshift(codepoint, 24), 0x3F)),
				bor(0x80, band(rshift(codepoint, 18), 0x3F)),
				bor(0x80, band(rshift(codepoint, 12), 0x3F)),
				bor(0x80, band(rshift(codepoint,  6), 0x3F)),
				bor(0x80, band(       codepoint     , 0x3F)))
		end	
	end;
})
