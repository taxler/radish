
local re = require 're'

return re.compile([[

	directives <- {| directive* |} end_marker {}

	end_marker <- '---' !%S %s*

	directive <- {|
		'%'
		-- name
		{:name: {ns_char+} :}

		-- parameters
		{:arguments: {| ( %LINESPACE+ !'#' {ns_char+} )+ |} :}?

		-- comment(s) & line break(s)
		%REST_OF_LINE+

		-- if there's no space between the name/final param and
		-- the comments, the # will be part of the name/param
	|}

	ns_char <- !%BOM %S

]], {
	LINESPACE = require 'parse.char.ascii7.in_line_space';
	BOM = require 'parse.match.utf8.bom';
	REST_OF_LINE = require 'parse.yaml.match.rest_of_line.not_final';
})
