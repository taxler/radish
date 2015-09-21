
local re = require 're'

return re.compile [[

	'<!--' (!'--' .)* '-->'

]]

-- note xml comments can't contain two dashes in a row
-- e.g. <!-- this is -- a comment --> is invalid
