
local re = require 're'

return re.compile([[

	%LINESPACE* ('#' (!%BREAK_CHAR .)*)? (%BREAK / !.)

]], {
	LINESPACE = require 'parse.char.ascii7.whitespace.horizontal';
	BREAK_CHAR = require 'parse.char.ascii7.whitespace.vertical';
	BREAK = require 'parse.match.ascii7.linebreak';
})
