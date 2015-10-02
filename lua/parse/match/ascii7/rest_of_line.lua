
local re = require 're'

return re.compile([[

	(!%BREAK_CHAR .)* (%FULL_BREAK / !.)

]], {
	BREAK_CHAR = require 'parse.char.ascii7.whitespace.vertical';
	FULL_BREAK = require 'parse.match.ascii7.linebreak';
})
