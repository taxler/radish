
local m = require 'lpeg'
local re = require 're'

local ARG_INDENT = m.Carg(1)
local REST_OF_LINE = require 'parse.yaml.match.rest_of_line'

local enter_block_sequence = m.Cmt(
	#re.compile[[ (' ')* '-' !%S ]] * ARG_INDENT,
	function(source, pos, indent)
		-- 
	end)

local indicate_chomp = m.Cg(m.S '+-', 'chomp')
local indicate_indent = m.Cg(m.R '19' / tonumber, 'indent')

local block_scalar_header = m.Ct(
	(
		(indicate_chomp * indicate_indent^-1)
		+
		(indicate_indent * indicate_chomp^-1)
	)^-1
)

local enter_block_literal = m.Cmt(
	#re.compile[[ (' ')* '|'  ]] * ARG_INDENT * block_scalar_header * rest_of_line,
	function(source, pos, indent)

	end)

local enter_block_folded = m.Cmt(
	#re.compile[[ (' ')* '>' ]] * ARG_IDENT * block_scalar_header * rest_of_line,
	function(source, pos, indent)
	end)

local enter_block_map = m.Cmt(
	#re.compile[[ (' ')* '?' !%S ]] * ARG_IDENT,
	function(source, pos, indent)
	end)

local 

local function make_context()
	return {
		INDENT = '';
		REST_OF_LINE = require 'parse.yaml.read.rest_of_line';
		enter_block_sequence = function(new_indent)

		end;
	}
end

return function(indentation_level)
	local context = make_context()
	context.INDENT = string.rep(' ', indentation_level)
	return re.compile(pdef_content_block, context)
end
