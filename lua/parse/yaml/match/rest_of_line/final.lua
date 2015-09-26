
local re = require 're'

return re.compile([[

	%LINESPACE* ('#' (!%BREAK_CHAR .)*)? !.

]], {
	LINESPACE = require 'parse.char.ascii7.in_line_space';
	BREAK_CHAR = require 'parse.char.ascii7.break_line';
})
