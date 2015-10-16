
local m = require 'lpeg'
local re = require 're'

local cache = {}

local pdef = [[

	indented <- {~ line* ~} {}
	line <- (non_empty_line / rest_of_line) (%BREAK / !.)
	rest_of_line <- (%LINESPACE* comment?) -> ''
	comment <- '#' (!%BREAK_CHAR .)*
	non_empty_line <- %INDENT (!(%LINESPACE+ ('#' / %BREAK)) .)+ rest_of_line

]]

return function(n)
	local cached = cache[n]
	if cached then
		return cached
	end
	local matcher = re.compile(pdef, {
		REST_OF_LINE = require 'parse.yaml.match.rest_of_line.not_final';
		INDENT = string.rep(' ', n);
		LINESPACE = require 'parse.char.ascii7.whitespace.horizontal';
		BREAK_CHAR = require 'parse.char.ascii7.whitespace.vertical';
		BREAK = require 'parse.match.ascii7.linebreak';
	})
end
