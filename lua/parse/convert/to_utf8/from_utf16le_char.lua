
local m = require 'lpeg'
local re = require 're'

local bit = require 'bit'
local bor, band = bit.bor, bit.band
local lshift, rshift = bit.lshift, bit.rshift
local strbyte, strchar = string.byte, string.char

return re.compile([[

	result <- ascii7 / surrogate_pair / codepoint

	ascii7 <- %ASCII7_CHAR (%NULL_CHAR -> '')

	surrogate_pair <- (
		{%SURROGATE_LEADING} {%SURROGATE_TRAILING}
	) -> from_surrogate_pair

	codepoint <- (..) -> from_codepoint

]], {
	ASCII7_CHAR = require 'parse.char.ascii7';
	NULL_CHAR = m.P '\0';
	from_codepoint = function(v)
		local low, high = strbyte(v, 1, 2)
		local codepoint = bor(low, lshift(high, 16))
		if high < 8 then
			return strchar(
				bor(0xC0,      rshift(codepoint,  6)       ),
				bor(0x80, band(             low     , 0x3F)))
		else
			return strchar(
				bor(0xE0,      rshift(     high,  4)       ),
				bor(0x80, band(rshift(codepoint,  6), 0x3F)),
				bor(0x80, band(             low     , 0x3F)))
		end
	end;
	SURROGATE_LEADING = m.P(1) * require 'parse.match.utf16_surrogate.leading_high';
	SURROGATE_TRAILING = m.P(1) * require 'parse.match.utf16_surrogate.trailing_high';
	from_surrogate_pair = function(high, low)
		local hilo, hihi = strbyte(high, 1, 2)
		local lolo, lohi = strbyte( low, 1, 2)
		local codepoint = 0x10000 + bor(
			       band(lolo, 0x1F)     ,
			lshift(band(lohi, 0x1F),  5),
			lshift(band(hilo, 0x1F), 10),
			lshift(band(hihi, 0x1F), 15))
		return string.char(
			bor(0xF0,      rshift(codepoint, 18)       ),
			bor(0x80, band(rshift(codepoint, 12), 0x3F)),
			bor(0x80, band(rshift(codepoint,  6), 0x3F)),
			bor(0x80, band(       codepoint     , 0x3F)))
	end;
})
