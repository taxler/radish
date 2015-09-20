
local m = require 'lpeg'

return m.P'\xFF\xFE' * -m.P'\x00\x00'
