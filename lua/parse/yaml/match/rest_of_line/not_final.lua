
local re = require 're'

return re.compile([[

	%LINESPACE* ('#' (!%BREAK_CHAR .)*)? %BREAK

]], {
	LINESPACE = require 'parse.char.ascii7.in_line_space';
	BREAK_CHAR = require 'parse.char.ascii7.break_line';
	BREAK = require 'parse.match.ascii7.linebreak';
})
