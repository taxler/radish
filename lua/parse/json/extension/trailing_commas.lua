local re = require 're'

return {
	apply = function(self, patterns)
		patterns.LIST_TRAIL = re.compile([[
			(',' %SPACE)?
		]], {
			SPACE = assert(patterns.SPACE)
		})
	end
}
