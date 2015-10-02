local m = require 'lpeg'

return {
	apply = function(self, patterns)
		patterns.C_STRING_FULL = m.Cf(
			re.compile([[
				%STRING (%SPACE '+' %SPACE %STRING)*
			]], {
				STRING = assert(patterns.C_STRING_FULL);
				SPACE = assert(patterns.SPACE);
			}),
			function(a, b)
				return a .. b
			end)
	end
}