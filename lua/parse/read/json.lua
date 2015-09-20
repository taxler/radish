
local bit = require 'bit'
local m = require 'lpeg'
local re = require 're'

-- json extension: allow javascript-style line & block comments
local EXTENSION_COMMENTS = true
-- json extension: allow concatenations of string literals
local EXTENSION_STRING_CONCAT = true
-- json extension: allow trailing commas in arrays and objects
local EXTENSION_TRAILING_COMMAS = true
-- json extension: allow hexadecimal number literals
local EXTENSION_HEX_LITERALS = true

local lib = {}

local object_meta = {}
local array_meta = {}
local null_placeholder = {}

lib.object_meta = object_meta
lib.array_meta = array_meta
lib.null_placeholder = null_placeholder

local function encode(v)
	if type(v) == 'string' then
		-- TODO: proper compatible encoding with \n \u0000 etc.
		return string.format('%q', v)
	end
	if v == nil then
		return 'null'
	end
	return tostring(v)
end

lib.encode = encode

function object_meta:__tostring()
	local buf = {}
	for k, v in pairs(self) do
		buf[#buf+1] = encode(k) .. ': ' .. encode(v)
	end
	return '{' .. table.concat(buf, ', ') .. '}'
end
function array_meta:__tostring()
	local buf = {}
	for i, v in ipairs(self) do
		buf[i] = encode(v)
	end
	return '[' .. table.concat(buf, ', ') .. ']'
end

setmetatable(null_placeholder, {__tostring = function()  return 'null';  end})

local m_space = re.compile '%s*'

local c_string_literal = re.compile([[
	c_string <- '"' {~ chunk* ~} '"'
	chunk <- [^"\]+ / escape
	escape <- ('\'->'') (esc_self / esc_control / esc_utf8)
	esc_self <- ["\/]
	esc_control <- [bfnrt] -> to_control
	esc_utf8 <- ('u'->'') ((%x %x %x %x) -> to_utf8)
]], {
	to_control = require 'parse.substitution.c.escape_sequence.single_letter';
	to_utf8 = function(hex)
		local codepoint = tonumber(hex, 16)
		if codepoint < 128 then
			return string.char(codepoint)
		elseif codepoint < 0x800 then
			return string.char(
				bit.bor(0xC0, bit.rshift(codepoint, 6)),
				bit.bor(0x80, bit.band(codepoint, 0x3F)))
		else
			return string.char(
				bit.bor(0xE0, bit.band(bit.rshift(codepoint, 12), 0x3F)),
				bit.bor(0x80, bit.band(bit.rshift(codepoint, 6), 0x3F)),
				bit.bor(0x80, bit.band(codepoint, 0x3F)))
		end
	end;
})

local m_list_trail = m.P ''

local m_number = re.compile([[
	number   <- '-'? integer fraction? exponent? ![a-zA-Z_]
	integer  <- '0' / ([1-9] [0-9]*)
	fraction <- '.' [0-9]+
	exponent <- [eE] [+-]? [0-9]+
]])

-- how extensions affect the basic matches

if EXTENSION_HEX_LITERALS then
	m_number = re.compile([[ '-'? '0x' %x+ ]]) + m_number
end

if EXTENSION_COMMENTS then
	-- must come before any 'if EXTENSION_...' block that uses m_space!
	m_space = re.compile([[
		%SPACE (%COMMENT %SPACE)*
	]], {
		SPACE = assert(m_space);
		COMMENT = require 'parse.match.comment.c';
	})
end

local c_string_full = c_string_literal * m_space

if EXTENSION_STRING_CONCAT then
	c_string_full = re.compile([[
		%STRING ('+' %SPACE %STRING)*
	]], {
		STRING = assert(c_string_full);
		SPACE = assert(m_space);
	})
	c_string_full = m.Cf(c_string_full, function(a,b)  return a..b;  end)
end

if EXTENSION_TRAILING_COMMAS then
	m_list_trail = re.compile([[ (',' %SPACE)? ]], {SPACE = assert(m_space)})
end

local c_document = re.compile([[

	document <- %SPACE c_value !.

	c_value <- c_object / c_string / c_array / c_keyword / c_number

	c_object <- {|
		'{' %SPACE
		(
			c_kvpair
			(',' %SPACE c_kvpair)*
			%LIST_TRAIL
		)?
		'}' %SPACE
	|} -> to_object

	c_kvpair <- {| %C_STRING_LITERAL ':' %SPACE c_value |}

	c_array  <- {|
		'[' %SPACE
		(
			c_value
			(',' %SPACE c_value)*
			%LIST_TRAIL
		)?
		']' %SPACE
	|} -> to_array

	c_string <- %C_STRING_FULL

	c_keyword <- (c_true / c_false / c_null) %SPACE
	c_true    <- 'true'  end_word %C_TRUE
	c_false   <- 'false' end_word %C_FALSE
	c_null    <- 'null'  end_word %C_NULL

	end_word <- !%IDENTIFIER_CHAR

	c_number <- (%NUMBER -> to_number) %SPACE

]], {
	SPACE = assert(m_space);
	C_STRING_LITERAL = assert(c_string_literal);
	C_STRING_FULL = assert(c_string_full);
	LIST_TRAIL = assert(m_list_trail);
	to_object = function(t)
		local obj = setmetatable({}, object_meta)
		for i, kvpair in ipairs(t) do
			local k, v = kvpair[1], kvpair[2]
			obj[k] = v
		end
		return obj
	end;
	to_array = function(t)
		return setmetatable(t, array_meta)
	end;
	C_TRUE = m.Cc(true);
	C_FALSE = m.Cc(false);
	C_NULL = m.Cc(assert(null_placeholder));
	to_number = assert(tonumber);
	NUMBER = assert(m_number);
	IDENTIFIER_CHAR = require 'parse.match.identifier.char';
})

function lib.type(v)
	local t = type(v)
	if t == 'string' or t == 'boolean' then
		return t
	end
	if v == null_placeholder then
		return 'null'
	end
	local m = getmetatable(v)
	if m == object_meta then
		return 'object'
	elseif m == array_meta then
		return 'array'
	end
	return nil
end

local to_utf8 = require 'parse.convert.to_utf8.from_utf'

function lib.read(source)
	local utf8, result = to_utf8:match(source)
	if utf8 == nil then
		return nil, result
	end
	return c_document:match(utf8)
end

return lib
