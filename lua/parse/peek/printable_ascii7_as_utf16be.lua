
local m = require 'lpeg'

return #('\0' * require('parse.char.ascii7.printable'))
