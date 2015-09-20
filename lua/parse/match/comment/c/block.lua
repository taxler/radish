
local re = require 're'

return re.compile [[

	'/*' (!'*/' .)* '*/'

]]
