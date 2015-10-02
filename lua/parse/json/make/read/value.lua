
local bit = require 'bit'
local bor = bit.bor, bit.band
local lshift, rshift = bit.lshift, bit.rshift
local m = require 'lpeg'
local re = require 're'
local make_context = require 'parse.json.make.context'

local json = require 'parse.json'

local pdef_value = [[

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

	c_kvpair <- {| %C_STRING_LITERAL %SPACE ':' %SPACE c_value |}

	c_array  <- {|
		'[' %SPACE
		(
			c_value
			(',' %SPACE c_value)*
			%LIST_TRAIL
		)?
		']' %SPACE
	|} -> to_array

	c_string <- %C_STRING_FULL %SPACE

	c_keyword <- (c_true / c_false / c_null) %SPACE
	c_true    <- 'true'  end_word %C_TRUE
	c_false   <- 'false' end_word %C_FALSE
	c_null    <- 'null'  end_word %C_NULL

	end_word <- !%IDENTIFIER_CHAR

	c_number <- (%NUMBER -> to_number) %SPACE

]]

return function(context)
	return re.compile(pdef_value, context or make_context())
end
