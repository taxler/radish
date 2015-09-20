
local m = require 'lpeg'

return m.P(string.char(0xEF, 0xBB, 0xBF))
