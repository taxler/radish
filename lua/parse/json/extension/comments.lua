local re = require 're'

return {
	priority = 100;
	apply = function(self, patterns)
		patterns.SPACE = re.compile([[
			%SPACE (%COMMENT %SPACE)*
		]], {
			SPACE = assert(patterns.SPACE);
			COMMENT = require 'parse.match.comment.c';
		})
	end
}
