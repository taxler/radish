
local re = require 're'

local strchar = string.char

local bit = require 'bit'
local bor, band = bit.bor, bit.band
local lshift, rshift = bit.lshift, bit.rshift

local read_surrogate_pair = re.compile [[

	'\u' &([dD][8-9a-bA-B]) ( {..%x%x} '\u' {[dD][c-fC-F]%x%x} )

]] / function(leading, trailing)
		leading = tonumber(leading, 16) - 0xD800
		trailing = tonumber(trailing, 16) - 0xDC00
		local codepoint = bor(0x100000, lshift(leading, 10), trailing)
		return strchar(
			bor(0xF0,      rshift(codepoint, 18)       ),
			bor(0x80, band(rshift(codepoint, 12), 0x3F)),
			bor(0x80, band(rshift(codepoint,  6), 0x3F)),
			bor(0x80, band(       codepoint     , 0x3F)))
	end

local read_codepoint = re.compile [[
	
	'\u' {%x%x%x%x}

]] / function(hex)
		local codepoint = tonumber(hex, 16)
		if codepoint < 128 then
			return strchar(codepoint)
		elseif codepoint < 0x800 then
			return strchar(
				bor(0xC0,      rshift(codepoint,  6)        ),
				bor(0x80, band(       codepoint      , 0x3F)))
		else
			return strchar(
				bor(0xE0,      rshift(codepoint, 12)       ),
				bor(0x80, band(rshift(codepoint,  6), 0x3F)),
				bor(0x80, band(       codepoint     , 0x3F)))
		end
	end

return read_surrogate_pair + read_codepoint
