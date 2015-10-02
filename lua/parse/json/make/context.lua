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
	escape <- &'\' {: esc_self / esc_control / esc_unicode :}
	esc_self <- '\' {["\/]}
	esc_control <- '\' ([bfnrt] -> to_control)
	esc_unicode <- %ESC_UNICODE
]], {
	to_control = require 'parse.substitution.c.escape_sequence.single_letter';
	ESC_UNICODE = require 'parse.json.read.u_escape';
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
