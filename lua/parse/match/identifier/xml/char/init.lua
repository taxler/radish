
local m = require 'lpeg'
return require 'parse.match.identifier.xml.char.first' + m.R'09' + m.S '-.'

-- TODO: support #xB7 | [#x0300-#x036F] | [#x203F-#x2040]
