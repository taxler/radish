
local m = require 'lpeg'

-- same as
-- require 'parse.char.ascii7.printable'
--   + require 'parse.char.ascii7.control'
--   + require 'parse.char.ascii7.null'

return m.R'\0\127'
