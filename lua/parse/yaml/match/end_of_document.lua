
local re = require 're'

return re.compile([[

	!. / &(%BOM) / ( '...' !%S %s* %INNER_LINE* %FINAL_LINE? )

]], {
	BOM = require 'parse.match.utf8.bom'
		+ require 'parse.match.utf16le.bom' + require 'parse.match.utf16be.bom'
		+ require 'parse.match.utf32le.bom' + require 'parse.match.utf32be.bom';
	SKIP_LINES = require 'parse.yaml.prefix.skip_lines';
	INNER_LINE = require 'parse.yaml.match.rest_of_line.not_final';
	FINAL_LINE = require 'parse.yaml.match.rest_of_line.final';
})
