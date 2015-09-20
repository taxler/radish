
local m = require 'lpeg'

return #(require('parse.char.ascii7.printable') * '\0' * -m.P'\0\0')
