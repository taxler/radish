local m = require 'lpeg'

local utf8_trailer = require 'parse.char.utf8.tools'.is_trailer_byte

local Cased = require 'parse.char.utf8.set.Cased':compile()
local Case_Ignorable = require 'parse.char.utf8.set.Case_Ignorable':compile()
return -(Case_Ignorable^0 * Cased) * m.Cmt('', function(source, pos)
	pos = pos - (#'\u{3a3}' + 1)
	while pos >= 1 do
		while utf8_trailer(source, pos) do
			pos = pos - 1
		end
		if pos < 1 then
			return false
		end
		if Cased:match(source, pos) then
			return true
		end
		if not Case_Ignorable:match(source, pos) then
			return false
		end
		pos = pos - 1
	end
	return false
end)
