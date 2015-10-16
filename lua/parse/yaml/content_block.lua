
local m = require 'lpeg'
local re = require 're'

local content_block = {}

local Carg_indent = m.Carg(1)
local Carg_tag_unquoted = m.Carg(2)
local Carg_tag_quoted = m.Carg(3)

local prefix_content_block = re.compile([[

	prefix_content_block <- content_block {}

	content_block <- literal / folded / sequence / map / flow

	literal  <- &('|') %ENTER_LITERAL
	folded   <- &('<') %ENTER_FOLDED
	sequence <- (' ')+ -' %ENTER_SEQUENCE
	map      <- '?' %ENTER_MAP

	flow <- flow_sequence / flow_map / flow_scalar_sq / flow_scalar_dq / flow_plain
	flow_scalar_sq <- ['] {|
		{:data: {~ ([^']+ / ("''" -> "'"))* ~} ['] :}
		{:tag: %TAG_QUOTED :}
		{:primitive: '' -> 'scalar' :}
	|}

	flow_sequence <- '['

	flow_map <- '{'

]], {
	TAG_QUOTED = Carg_tag_quoted;
	ENTER_LITERAL = m.Cmt(
		Carg_indent * Carg_tag_quoted,
		function(source, pos, indent, tag)

		end);
	ENTER_FOLDED = m.Cmt(
		Carg_indent * Carg_tag_quoted,
		function(source, pos, indent, tag)

		end);
	ENTER_SEQUENCE = m.Cmt(
		Carg_indent * Carg_tag_unquoted,
		function(source, pos, indent, tag)
		end);
	ENTER_MAP = m.Cmt(
		Carg_indent * Carg_tag_unquoted,
		function(source, pos, indent, tag)
		end);
})

return content_block
