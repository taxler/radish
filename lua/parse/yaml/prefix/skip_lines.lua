
local re = require 're'

return re.compile([[

	%INNER_LINE* %FINAL_LINE? {}

]], {
	INNER_LINE = require 'parse.yaml.match.rest_of_line.not_final';
	FINAL_LINE = require 'parse.yaml.match.rest_of_line.final';
})
