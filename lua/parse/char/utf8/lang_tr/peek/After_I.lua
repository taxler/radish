local m = require 'lpeg'
local strbyte = string.byte
local byte_I = strbyte 'I'
local combining_class = require 'parse.char.utf8.set.combining_class'
local utf8_trailer = require 'parse.char.utf8.tools'.is_trailer_byte

local cc_not_0_or_230 = combining_class.where(function(v)  return v > 0 and v ~= 230;  end):compile()

return m.Cmt('', function(source, pos)
	pos = pos - (#'\u{307}' + 1)
	while pos >= 1 do
		while utf8_trailer(source, pos) do
			pos = pos - 1
		end
		if pos < 1 then
			return false
		end
		if strbyte(source, pos) == byte_I then
			return true
		end
		if cc_not_0_or_230:match(source, pos) then
			return false
		end
		pos = pos - 1
	end
end)
