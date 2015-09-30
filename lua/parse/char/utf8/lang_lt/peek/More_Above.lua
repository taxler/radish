
local combining_class = require 'parse.char.utf8.set.combining_class'

local cc_not_0 = combining_class.where(function(v)  return v > 0 and v ~= 230;  end):compile()
local cc_230 = combining_class.where('=', 230):compile()

return #(cc_not_0^0 * cc_230)
