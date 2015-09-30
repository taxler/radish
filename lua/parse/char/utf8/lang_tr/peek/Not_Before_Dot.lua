local m = require 'lpeg'

local combining_class = require 'parse.char.utf8.set.combining_class'
local cc_not_0_or_230 = combining_class.where(function(v)  return v > 0 and v ~= 230;  end):compile()

return -(cc_not_0_or_230^0 * m.P'\u{307}')
