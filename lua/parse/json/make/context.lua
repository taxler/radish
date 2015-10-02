local m = require 'lpeg'
local re = require 're'
local strchar = string.char
local bit = require 'bit'
local bor, band = bit.bor, bit.band
local lshift, rshift = bit.lshift, bit.rshift
local tonumber = tonumber
local json = require 'parse.json'

local c_string_literal = re.compile([[
	c_string <- '"' {~ chunk* ~} '"'
	chunk <- [^"\]+ / escape
	escape <- ('\'->'') (esc_self / esc_control / esc_utf8)
	esc_self <- ["\/]
	esc_control <- [bfnrt] -> to_control
	esc_utf8 <- ('u'->'') (esc_utf8_surrogate / esc_utf8_normal)
	esc_utf8_surrogate <- &([dD][8-9a-bA-B]) ( {..%x%x} '\u' {[dD][c-fC-F]%x%x} ) -> from_surrogate
	esc_utf8_normal <- ((%x %x %x %x) -> to_utf8)
]], {
	to_control = require 'parse.substitution.c.escape_sequence.single_letter';
	to_utf8 = function(hex)
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
	end;
	from_surrogate = function(leading, trailing)
		leading = tonumber(leading, 16) - 0xD800
		trailing = tonumber(trailing, 16) - 0xDC00
		local codepoint = bor(0x100000, lshift(leading, 10), trailing)
		return strchar(
			bor(0xF0,      rshift(codepoint, 18)       ),
			bor(0x80, band(rshift(codepoint, 12), 0x3F)),
			bor(0x80, band(rshift(codepoint,  6), 0x3F)),
			bor(0x80, band(       codepoint     , 0x3F)))
	end;
})

return function(...)
	local extensions = {}
	for i = 1, select('#', ...) do
		local extension = select(i, ...)
		if type(extension) == 'string' then
			extension = require('parse.json.extension.' .. extension)
		end
		extensions[i] = extension
	end
	table.sort(extensions,
		function(a, b)
			return (a.priority or 0) > (b.priority or 0)
		end)
	local context = {
		SPACE = require 'parse.match.ascii7.whitespace.optional';
		NUMBER = re.compile [[
			number   <- '-'? integer fraction? exponent? ![a-zA-Z_]
			integer  <- '0' / ([1-9] [0-9]*)
			fraction <- '.' [0-9]+
			exponent <- [eE] [+-]? [0-9]+
		]];
		C_STRING_LITERAL = assert(c_string_literal);
		C_STRING_FULL = assert(c_string_literal);
		LIST_TRAIL = m.P '';
		to_object = function(t)
			local obj = {}
			for i, kvpair in ipairs(t) do
				local k, v = kvpair[1], kvpair[2]
				obj[k] = v
			end
			return json.make_object(obj)
		end;
		to_array = function(t)
			return json.make_array(t)
		end;
		C_TRUE = m.Cc(true);
		C_FALSE = m.Cc(false);
		C_NULL = m.Cc(assert(json.null));
		to_number = assert(tonumber);
		IDENTIFIER_CHAR = require 'parse.match.identifier.char';
	}
	for i, extension in ipairs(extensions) do
		extension:apply(context)
	end
	return context
end
