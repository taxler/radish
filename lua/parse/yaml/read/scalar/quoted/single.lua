
local m = require 'lpeg'
local re = require 're'

return re.compile([[

	"'" {~ (%IN_CHAR+ / ("''" -> "'"))* ~} "'"

]], {
	-- anything except new lines and ASCII control codes
	-- (and the apostrophe/single-quote itself, of course)
	IN_CHAR	= m.R(' &', '(\255') + '\t';
})
