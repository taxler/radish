
local m = require 'lpeg'
local V = m.V
local re = require 're'
local bit = require 'bit'
local bor, band = bit.bor, bit.band
local lshift, rshift = bit.lshift, bit.rshift
local strbyte, strchar, strsub = string.byte, string.char, string.sub
local make_set = require 'parse.char.utf8.make.set'

local peek_end_of_document = require 'parse.yaml.peek.end_of_document'

local set_c_printable = make_set {
	S = '\r\n\t\u{85}';
	R = {' ~', '\u{a0}\u{d7ff}', '\u{e000}\u{fffd}', '\u{10000}\u{10ffff}'};
}
local c_printable = set_c_printable:compile()

local set_nb_char = set_c_printable - {S = '\r\n\u{feff}'}
local nb_char = set_nb_char:compile()

local s_white = m.S ' \t'

local set_ns_char = set_nb_char - {S=' \t'}
local ns_char = set_ns_char:compile()

local set_c_indicator = make_set {S=[[-?:,[]{}#&*!|>'"%@`]]}
local set_c_flow_indicator = make_set {S=',[]{}'}
local c_flow_indicator = set_c_flow_indicator:compile()

local set_ns_char_NOT_c_indicator = set_ns_char - set_c_indicator
local ns_char_NOT_c_indicator = set_ns_char_NOT_c_indicator:compile()

local set_ns_char_NOT_c_flow_indicator = set_ns_char - set_c_flow_indicator
local ns_char_NOT_c_flow_indicator = set_ns_char_NOT_c_flow_indicator:compile()

local set_ns_plain_safe_out = set_ns_char
local set_ns_plain_safe_in  = set_ns_char_NOT_c_flow_indicator

local ns_plain_safe_out = set_ns_plain_safe_out:compile()
local ns_plain_safe_in  = set_ns_plain_safe_in:compile()

local ns_plain_char_out = (set_ns_plain_safe_out - {S=":#"}):compile()
	+ ( -(m.B(m.S' \t\r\n') + m.B('\u{feff}')) * "#" )
	+ ( ":" * #ns_plain_safe_out )

local ns_plain_safe_in_NOT_colon_hash = (set_ns_plain_safe_in - {S=":#"}):compile()

local ns_plain_char_in = ns_plain_safe_in_NOT_colon_hash
	+ ( -(m.B(m.S' \t\r\n') + m.B('\u{feff}')) * "#" )
	+ ( ":" * #ns_plain_safe_in )

local ns_plain_first_out = ns_char_NOT_c_indicator + ((m.S '?:-') * #ns_plain_safe_out)
local ns_plain_first_in  = ns_char_NOT_c_indicator + ((m.S '?:-') * #ns_plain_safe_in)
local nb_ns_plain_in_line_out  = ( s_white^0 * ns_plain_char_out )^0
local nb_ns_plain_in_line_in   = ( s_white^0 * ns_plain_char_in )^0

local s_separate_in_line = s_white^1 + m.B(m.S'\r\n') + -m.B(1)
local s_separate_in_line_nonfinal = s_white^1 + m.B(m.S'\r\n')
local s_separate_in_line_final = -m.B(1)

local b_break = m.P'\r\n' + '\r' + '\n'

local b_non_content  = m.Cg(b_break * m.Cc'')
local b_as_line_feed = m.Cg(b_break * m.Cc'\n')
local b_as_space     = m.Cg(b_break * m.Cc' ')

local s_flow_line_prefix = m.Cg(m.Cmt(
	m.Cb('indent') * m.C(m.P' '^0) * (m.P'\t' * m.S'\t '^0)^-1,
	function(source, pos, required_indent_size, given_indent)
		if #given_indent < required_indent_size then
			return false
		end
		return pos, ''
	end))

local s_flow_line_prefix_NOCAP = m.Cmt(
	m.Cb('indent') * m.C(m.P' '^0) * (m.P'\t' * m.S'\t '^0)^-1,
	function(source, pos, required_indent_size, given_indent)
		if #given_indent < required_indent_size then
			return false
		end
		return pos
	end)

local s_line_prefix_flow_in = s_flow_line_prefix


local s_indent = m.Cmt(
	m.Cb('indent'),
	function(source, pos, required_indent_size)
		for i = 0, required_indent_size-1 do
			if strsub(source, pos+i, pos+i) ~= ' ' then
				return false
			end
		end
		return pos + required_indent_size
	end)

local l_empty_flow_in = (s_line_prefix_flow_in + s_indent) * b_as_line_feed

local s_flow_folded = (
	m.Cg(s_separate_in_line^-1 * m.Cc '')
	* (b_non_content * l_empty_flow_in^1 + b_as_space)
	* -peek_end_of_document
	* s_flow_line_prefix
)

local s_ns_plain_next_line_flow_out = s_flow_folded * ns_plain_char_out * nb_ns_plain_in_line_out
local s_ns_plain_next_line_flow_in = s_flow_folded * ns_plain_char_in * nb_ns_plain_in_line_in

local ns_plain_one_line_flow_key = m.Cs(ns_plain_first_in * nb_ns_plain_in_line_in)
local ns_plain_one_line_block_key = m.Cs(ns_plain_first_out * nb_ns_plain_in_line_out)
local ns_plain_multi_line_flow_in = m.Cs(ns_plain_first_in * nb_ns_plain_in_line_in * s_ns_plain_next_line_flow_in^0)
local ns_plain_multi_line_flow_out = m.Cs(ns_plain_first_out * nb_ns_plain_in_line_out * s_ns_plain_next_line_flow_out^0)

local c_nb_comment_text = '#' * nb_char^0

local b_comment_nonfinal = b_break
local b_comment_final = m.P(-1)
local b_comment = b_comment_nonfinal + b_comment_final

local s_b_comment = (s_separate_in_line * c_nb_comment_text^-1)^-1 * b_comment

local l_comment_nonfinal = s_separate_in_line_nonfinal * c_nb_comment_text^-1 * b_comment_nonfinal
local l_comment_final = s_separate_in_line_final * c_nb_comment_text^-1 * b_comment_final

local s_l_comments =
	(
		s_b_comment
		+ m.B(m.S'\r\n')
		+ -m.B(1)
	)
	* l_comment_nonfinal^0 * l_comment_final^-1

local s_separate_lines = (s_l_comments * s_flow_line_prefix_NOCAP) + s_separate_in_line

local function add(a,b)  return a+b;  end

local increment_indent = m.Cg(m.Cf(m.Cb('indent') * m.Cc(1), add), 'indent')
local decrement_indent = m.Cg(m.Cf(m.Cb('indent') * m.Cc(-1), add), 'indent')

local ns_anchor_char = ns_char_NOT_c_indicator

local ns_anchor_name = ns_anchor_char^1

local c_ns_alias_node = '*' * m.Ct(m.Cg(m.Cc'alias', 'primitive') * m.Cg(ns_anchor_name, 'anchor'))

local e_node = m.Ct(
	m.Cg(m.Cc('scalar'), 'primitive')
	* m.Cg(m.Cc(''), 'data')
	* m.Cg(m.Cb('tag_other'), 'tag')
	* m.Cg(m.Cb('anchor'), 'anchor'))

local reset_node_properties = (
	m.Cg(m.Cc(nil), 'anchor')
	* m.Cg(m.Cc('!'), 'tag_scalar_unplain')
	* m.Cg(m.Cc('?'), 'tag_other'))

local clear_node_properties = (
	m.Cg(m.Cc(nil), 'tag_scalar_unplain')
	* m.Cg(m.Cc(nil), 'tag_other'))

local ns_flow_yaml_content_flow_in = m.Ct(
	m.Cg(ns_plain_multi_line_flow_in, 'data')
	* m.Cg(m.Cc 'scalar', 'primitive')
	* m.Cg(m.Cb 'tag_other', 'tag')
	* m.Cg(m.Cb 'anchor', 'anchor')
)
local ns_flow_yaml_content_flow_key = m.Ct(
	m.Cg(ns_plain_one_line_flow_key, 'data')
	* m.Cg(m.Cc 'scalar', 'primitive')
	* m.Cg(m.Cb 'tag_other', 'tag')
	* m.Cg(m.Cb 'anchor', 'anchor')
)
local ns_flow_yaml_content_flow_out = m.Ct(
	m.Cg(ns_plain_multi_line_flow_out, 'data')
	* m.Cg(m.Cc 'scalar', 'primitive')
	* m.Cg(m.Cb 'tag_other', 'tag')
	* m.Cg(m.Cb 'anchor', 'anchor')
)
local ns_flow_yaml_content_block_key = m.Ct(
	m.Cg(ns_plain_one_line_block_key, 'data')
	* m.Cg(m.Cc 'scalar', 'primitive')
	* m.Cg(m.Cb 'tag_other', 'tag')
	* m.Cg(m.Cb 'anchor', 'anchor')
)

local e_scalar = e_node

local ns_uri_char = m.R('AZ', 'az', '09') + m.S"-#;/?:@&=+$,_.!~*'()[]" + re.compile[['%'%x%x]]

local c_verbatim_tag = '!<' * m.C(ns_uri_char^1) * '>'

local c_named_tag_handle = '!' * (m.R('AZ', 'az', '09') + '-')^1 * '!'

local c_secondary_tag_handle = '!!'

local c_primary_tag_handle = '!'

local c_tag_handle = c_named_tag_handle + c_secondary_tag_handle + c_primary_tag_handle

local ns_tag_char = ns_uri_char - ('!' + c_flow_indicator)

local c_ns_shorthand_tag = m.C( c_tag_handle * ns_tag_char^1 )

local c_non_specific_tag = m.C '!'

local c_ns_tag_property = (
	m.Cg(c_verbatim_tag + c_ns_shorthand_tag + c_non_specific_tag, 'tag_other')
	*
	m.Cg(m.Cb('tag_other'), 'tag_scalar_unplain')
)

local c_ns_anchor_property = '&' * m.Cg(ns_anchor_name, 'anchor')

local c_ns_properties_multiline = (
	c_ns_tag_property * (s_separate_lines * c_ns_anchor_property)^-1
	+ c_ns_anchor_property * (s_separate_lines * c_ns_tag_property)^-1)

local c_ns_properties_in_line = (
	c_ns_tag_property * (s_separate_in_line * c_ns_anchor_property)^-1
	+ c_ns_anchor_property * (s_separate_in_line * c_ns_tag_property)^-1)

local ns_flow_yaml_node_flow_in = (
	c_ns_alias_node
	+ ns_flow_yaml_content_flow_in
	+ c_ns_properties_multiline * (
		(s_separate_lines * ns_flow_yaml_content_flow_in)
		+ e_scalar
	)
)

local ns_flow_yaml_node_flow_key = (
	c_ns_alias_node
	+ ns_flow_yaml_content_flow_key
	+ c_ns_properties_in_line * (
		(s_separate_in_line * ns_flow_yaml_content_flow_key)
		+
		e_scalar
	)
)

local ns_flow_yaml_node_block_key = (
	c_ns_alias_node
	+ ns_flow_yaml_content_block_key
	+ c_ns_properties_in_line * (
		(s_separate_in_line * ns_flow_yaml_content_block_key)
		+
		e_scalar
	)
)

local ns_s_implicit_yaml_key_flow_key  = ns_flow_yaml_node_flow_key * s_separate_in_line^-1
local ns_s_implicit_yaml_key_block_key = ns_flow_yaml_node_block_key * s_separate_in_line^-1

local c_quoted_quote = "'" * m.Cg("'" * m.Cc"")

local set_nb_json = make_set { S='\t', R=' \u{10ffff}' }
local set_nb_json_NOT_single_quote = set_nb_json - { S="'" }

local nb_single_char = set_nb_json_NOT_single_quote:compile() + c_quoted_quote

local set_nb_json_NOT_single_quote_OR_whitespace = set_nb_json_NOT_single_quote - make_set { S = ' \t' }

local ns_single_char = set_nb_json_NOT_single_quote_OR_whitespace:compile() + c_quoted_quote

local nb_ns_single_in_line = (s_white^0 * ns_single_char)^0

local s_single_next_line = m.P {
	's_single_next_line';
	s_single_next_line = s_flow_folded * (
		ns_single_char
		* nb_ns_single_in_line
		* (V's_single_next_line' + s_white^0)
	)^-1;
}

local nb_single_multi_line = nb_ns_single_in_line * (s_single_next_line + s_white^0)
local nb_single_one_line = nb_single_char^0

local c_single_quoted_multi_line = (
	"'" * m.Ct(
		m.Cg(m.Cs(nb_single_multi_line), 'data')
		* m.Cg(m.Cc'scalar', 'primitive')
		* m.Cg(m.Cb 'tag_scalar_unplain', 'tag')
		* m.Cg(m.Cb 'anchor', 'anchor')
	)
	* "'"
)
local c_single_quoted_one_line = (
	"'" * m.Ct(
		m.Cg(m.Cs(nb_single_one_line), 'data')
		* m.Cg(m.Cc 'scalar', 'primitive')
		* m.Cg(m.Cb 'tag_scalar_unplain', 'tag')
		* m.Cg(m.Cb 'anchor', 'anchor')
	)
	* "'"
)

local c_ns_esc_char = m.Cg('\\' * (
	(m.S'abfnrtv' / require 'parse.substitution.c.escape_sequence.single_letter')
	+ m.C(m.S(' \t\\"/'))
	+ m.S'0ePLN_' / {['0']='\0', e='\x1B', P='\u{2029}', L='\u{2028}', N='\u{85}', _='\u{a0}'}
	+ re.compile [[ 'x' {%x%x} ]]
		/ function(byte)
			return strchar(tonumber(byte, 16))
		end
	+ re.compile [[ 'u' &([dD][8-9a-bA-B]) {..%x%x} '\u' {[dD][c-fC-F]%x%x} ]]
		/ function(leading, trailing)
			-- surrogate pair
			leading = tonumber(leading, 16) - 0xD800
			trailing = tonumber(trailing, 16) - 0xDC00
			local codepoint = bor(0x100000, lshift(leading, 10), trailing)
			return strchar(
				bor(0xF0,      rshift(codepoint, 18)       ),
				bor(0x80, band(rshift(codepoint, 12), 0x3F)),
				bor(0x80, band(rshift(codepoint,  6), 0x3F)),
				bor(0x80, band(       codepoint     , 0x3F)))
		end
	+ re.compile [[ ('u' {%x%x%x%x}) / ('U' {%x%x%x%x%x%x%x%x}) ]]
		/ function(hex)
			local codepoint = tonumber(hex, 16)
			if codepoint < 128 then
				return strchar(codepoint)
			elseif codepoint < 0x800 then
				return strchar(
					bor(0xC0,      rshift(codepoint,  6)        ),
					bor(0x80, band(       codepoint      , 0x3F)))
			elseif codepoint < 0x10000 then
				return strchar(
					bor(0xE0,      rshift(codepoint, 12)       ),
					bor(0x80, band(rshift(codepoint,  6), 0x3F)),
					bor(0x80, band(       codepoint     , 0x3F)))
			elseif codepoint < 0x110000 then
				return strchar(
					bor(0xF0,      rshift(codepoint, 18)       ),
					bor(0x80, band(rshift(codepoint, 12), 0x3F)),
					bor(0x80, band(rshift(codepoint,  6), 0x3F)),
					bor(0x80, band(       codepoint     , 0x3F)))
			else
				error('Unicode codepoint out of range: ' .. hex)
			end
		end
))

local nb_double_char = c_ns_esc_char + (set_nb_json - {S=[[\"]]}):compile()

local ns_double_char = (set_nb_json - {S=' \t\\"'}):compile() + c_ns_esc_char

local nb_ns_double_in_line = (s_white^0 * ns_double_char)^0

local s_double_escaped = s_white^0 * m.Cg('\\' * b_break * m.Cc'') * l_empty_flow_in^0 * s_flow_line_prefix

local s_double_break = s_double_escaped + s_flow_folded

local s_double_next_line = {
	's_double_next_line';
	s_double_next_line = s_double_break * (
		ns_double_char
		* nb_ns_double_in_line
		* (V's_double_next_line' + s_white^0)
	)^-1;
}

local nb_double_multi_line = (
	nb_ns_double_in_line * (s_double_next_line + s_white^0)
)

local nb_double_one_line = nb_double_char^0

local c_double_quoted_multi_line = (
	'"' * m.Ct(
		m.Cg(m.Cs(nb_double_multi_line), 'data')
		* m.Cg(m.Cc'scalar', 'primitive')
		* m.Cg(m.Cb 'tag_scalar_unplain', 'tag')
		* m.Cg(m.Cb 'anchor', 'anchor')
	)
	* '"'
)
local c_double_quoted_one_line = (
	'"' * m.Ct(
		m.Cg(m.Cs(nb_double_one_line), 'data')
		* m.Cg(m.Cc'scalar', 'primitive')
		* m.Cg(m.Cb 'tag_scalar_unplain', 'tag')
		* m.Cg(m.Cb 'anchor', 'anchor')
	)
	* '"'
)


local read_chomping_indicator = ('+' * m.Cc 'keep') + ('-' * m.Cc 'strip')
local default_chomping_indicator = m.Cc 'clip'

local read_indentation_indicator = (re.compile '%d+' / tonumber)
local default_indentation_indicator = m.Cc 'auto'

local read_block_scalar_header = re.compile([[
	(
		(
			{:chomp: %CHOMP :}
			{:add_indent: %OPT_INDENT :}
		)
		/
		(
			{:add_indent: %OPT_INDENT :}
			{:chomp: %OPT_CHOMP :}
		)
	)
	!%S
	%REST_OF_LINE
]], {
	CHOMP = read_chomping_indicator;
	OPT_CHOMP = read_chomping_indicator + default_chomping_indicator;
	OPT_INDENT = read_indentation_indicator + default_indentation_indicator;
	REST_OF_LINE = require 'parse.yaml.match.rest_of_line';
})

local prefix_line = m.C(m.P' '^0)
	* m.C(require 'parse.char.ascii7.horizontal'^0)
	* m.Cg((require 'parse.match.ascii7.linebreak' * m.Cc'\n')^-1)
	* m.Cp()

local function aux_block_scalar(source, pos, chomp, base_indent, add_indent)
	local buf = {}
	local block_indent
	if add_indent == 'auto' then
		block_indent = base_indent + 1
		while true do
			if peek_end_of_document:match(source, pos) then
				break
			end
			local line_indent, line, line_break, new_pos = prefix_line:match(source, pos)
			if line == '' then
				block_indent = math.max(block_indent, #line_indent)
				buf[#buf+1] = line .. line_break
			else
				if #line_indent < block_indent then
					break
				end
				buf[#buf+1] = line .. line_break
				block_indent = #line_indent
				pos = new_pos
				break
			end
			pos = new_pos
			if pos > #source then
				break
			end
		end
	else
		block_indent = base_indent + add_indent
	end
	while not (pos > #source) do
		if peek_end_of_document:match(source, pos) then
			break
		end
		local line_indent, line, line_break, new_pos = prefix_line:match(source, pos)
		if #line_indent > block_indent then
			line = string.rep(' ', #line_indent - block_indent) .. line
			line_indent = string.rep(' ', block_indent)
		end
		if line ~= '' and #line_indent < block_indent then
			if line:sub(1,1) == '#' then
				while buf[#buf] == '\n' do
					buf[#buf] = nil
				end
				pos = new_pos
				while pos <= #source do
					local line_indent, line, line_break, new_pos = prefix_line:match(source, pos)
					if line ~= '' and line:sub(1,1) ~= '#' then
						break
					end
					pos = new_pos
				end
			end
			break
		end
		buf[#buf+1] = line .. line_break
		pos = new_pos
	end
	if chomp ~= 'keep' then
		while buf[#buf] == '\n' do
			buf[#buf] = nil
		end
		if chomp == 'strip' then
			if (buf[#buf] or ''):sub(-1) == '\n' then
				buf[#buf] = buf[#buf]:sub(1, -2)
			end
		end
	end
	return buf, pos
end

local c_l_literal = '|' * (
	read_block_scalar_header * m.Cg(m.Cmt(
	m.Cb('tag_scalar_unplain') * m.Cb('anchor') * m.Cb('chomp') * m.Cb('indent') * m.Cb('add_indent'),
	function(source, pos, tag, anchor, chomp, base_indent, add_indent)
		local buf, pos = aux_block_scalar(source, pos, chomp, base_indent, add_indent)
		return pos, table.concat(buf)
	end), 'data')
)

local c_l_folded = '>' * (
	read_block_scalar_header * m.Cg(m.Cmt(
	m.Cb('tag_scalar_unplain') * m.Cb('anchor') * m.Cb('chomp') * m.Cb('indent') * m.Cb('add_indent'),
	function(source, pos, tag, anchor, chomp, base_indent, add_indent)
		local buf, pos = aux_block_scalar(source, pos, chomp, base_indent, add_indent)
		local i = 1
		while buf[i+1] ~= nil do
			if buf[i]:match('^[^ \r\n\t]') and buf[i+1] == '\n' and (buf[i+2] or ''):match('^[^ \t]') then
				table.remove(buf, i+1)
				i = i + 1
			elseif buf[i]:match('^[^ \r\n]') and buf[i+1]:match('^[^ \r\n]') then
				repeat
					buf[i] = strsub(buf[i], 1, -2) .. ' ' .. buf[i+1]
					table.remove(buf, i+1)
				until not (buf[i+1] or ''):match('^[^ \r\n]')
			else
				i = i + 1
			end
		end
		return pos, table.concat(buf)
	end), 'data')
)

local s_l_block_scalar = m.Ct(
	increment_indent
	* s_separate_lines
	* (c_ns_properties_multiline * s_separate_lines)^-1
	* decrement_indent
	* (c_l_literal + c_l_folded)
	* m.Cg(m.Cc(nil), 'chomp')
	* m.Cg(m.Cc(nil), 'add_indent')
	* m.Cg(m.Cc'scalar', 'primitive')
	* m.Cg(m.Cb'tag_scalar_unplain', 'tag')
	* m.Cg(m.Cb'anchor', 'anchor')
	* m.Cg(m.Cc(nil), 'tag_scalar_unplain')
	* m.Cg(m.Cc(nil), 'tag_other')
	* m.Cg(m.Cc(nil), 'indent')
)



local bigger_indent = m.Cg(
	m.Cmt(
		m.Cb('indent'),
		function(source, pos, old_indent)
			local new_indent = 0
			while source:sub(pos + new_indent, pos + new_indent) == ' ' do
				new_indent = new_indent + 1
			end
			if new_indent <= old_indent then
				return false
			end
			return pos, new_indent
		end),
	'indent')

local s_l_block_node_block_in = m.P {
	's_l_block_node_block_in';
	s_l_block_node_block_in = V's_l_block_in_block_block_in' + V's_l_flow_in_block';
	s_l_block_node_block_out = V's_l_block_in_block_block_out' + V's_l_flow_in_block';
	s_l_flow_in_block = increment_indent * s_separate_lines * V'ns_flow_node_flow_out' * s_l_comments * decrement_indent;
	s_l_block_in_block_block_in = s_l_block_scalar + V's_l_block_collection_block_in';
	s_l_block_in_block_block_out = s_l_block_scalar + V's_l_block_collection_block_out';
	s_l_block_collection_block_in = m.Ct(
		(
			(
				increment_indent
				* s_separate_lines
				* c_ns_properties_multiline
				* decrement_indent
		 		* s_l_comments
				* m.Cg(m.Cb('tag_other'), 'tag')
				* m.Cg(m.Cb('anchor'), 'anchor')
				* (V'l_block_sequence_block_in' + V'l_block_mapping')
			)
			+
			(
		 		s_l_comments
				* m.Cg(m.Cb('tag_other'), 'tag')
				* m.Cg(m.Cb('anchor'), 'anchor')
				* (V'l_block_sequence_block_in' + V'l_block_mapping')
			)
		)
		* m.Cg(m.Cc(nil), 'indent')
		* m.Cg(m.Cc(nil), 'tag_other')
		* m.Cg(m.Cc(nil), 'tag_scalar_unplain')
	);
	s_l_block_collection_block_out = m.Ct(
		(
			(
				increment_indent
				* s_separate_lines
				* c_ns_properties_multiline
				* decrement_indent
				* s_l_comments
				* m.Cg(m.Cb('tag_other'), 'tag')
				* m.Cg(m.Cb('anchor'), 'anchor')
				* (V'l_block_sequence_block_out' + V'l_block_mapping')
			)
			+
			(
				s_l_comments
				* m.Cg(m.Cb('tag_other'), 'tag')
				* m.Cg(m.Cb('anchor'), 'anchor')
				* (V'l_block_sequence_block_out' + V'l_block_mapping')
			)
		)
		* m.Cg(m.Cc(nil), 'indent')
		* m.Cg(m.Cc(nil), 'tag_other')
		* m.Cg(m.Cc(nil), 'tag_scalar_unplain')
	);
	l_block_sequence_block_in = (
		m.Cg(m.Ct(
			bigger_indent
			* (s_indent * reset_node_properties * V'c_l_block_seq_entry')^1
			* m.Cg(m.Cc(nil), 'indent')
			* clear_node_properties
		), 'data')
		* m.Cg(m.Cc'sequence', 'primitive')
	);
	l_block_sequence_block_out = (
		m.Cg(m.Ct(
			decrement_indent
			* bigger_indent
			* (s_indent * reset_node_properties * V'c_l_block_seq_entry')^1
			* m.Cg(m.Cc(nil), 'indent')
			* clear_node_properties
		), 'data')
		* m.Cg(m.Cc'sequence', 'primitive')
	);
	c_l_block_seq_entry =
		'-'
		* -ns_char
		* V's_l_block_indented_block_in'
		;
	s_l_block_indented_block_in = (
		m.Ct(
			m.Cg(
				m.Cmt(
					m.C(m.P' '^0) * m.Cb'indent',
					function(source, pos, added, indent)
						return pos, indent + 1 + #added
					end),
				'indent')
			*
			(
				V'ns_l_compact_sequence'
				+
				V'ns_l_compact_mapping'
			)
		)
		+
		V's_l_block_node_block_in'
		+
		( e_node * s_l_comments )
	);
	s_l_block_indented_block_out = (
		m.Ct(
			m.Cg(
				m.Cmt(
					m.C(m.P' '^1) * m.Cb'indent',
					function(source, pos, added, indent)
						return pos, indent + 1 + #added
					end),
				'indent')
			* (
				V'ns_l_compact_sequence'
				+
				V'ns_l_compact_mapping'
			)
		)
		+
		V's_l_block_node_block_out'
		+
		( e_node * s_l_comments )
	);
	ns_l_compact_sequence =
		m.Cg(m.Ct(
			V'c_l_block_seq_entry' * (s_indent * V'c_l_block_seq_entry')^0
			* m.Cg(m.Cc(nil), 'indent')
		), 'data')
		* m.Cg(m.Cc('sequence'), 'primitive')
		* m.Cg(m.Cb('anchor'), 'anchor')
		* m.Cg(m.Cb('tag_other'), 'tag')
		* m.Cg(m.Cc(nil), 'indent')
	;
	ns_l_compact_mapping =
		m.Cg(m.Ct(
			V'ns_l_block_map_entry' * (s_indent * V'ns_l_block_map_entry')^0
			* m.Cg(m.Cc(nil), 'indent')
		), 'data')
		* m.Cg(m.Cc('mapping'), 'primitive')
		* m.Cg(m.Cb('anchor'), 'anchor')
		* m.Cg(m.Cb('tag_other'), 'tag')
		* m.Cg(m.Cc(nil), 'indent')
	;
	ns_l_block_map_entry = m.Ct(
		V'c_l_block_map_explicit_entry'
		+ V'ns_l_block_map_implicit_entry');
	c_l_block_map_explicit_entry = (
		reset_node_properties
		* m.Cg(V'c_l_block_map_explicit_key', 'key')
		* reset_node_properties
		* m.Cg(V'l_block_map_explicit_value' + e_node, 'value')
		* m.Cg(m.Cc(nil), 'tag_scalar_unplain')
		* m.Cg(m.Cc(nil), 'tag_other')
	);
	c_l_block_map_explicit_key =
		'?'
		* V's_l_block_indented_block_out'
		;
	l_block_map_explicit_value = s_indent * ':' * V's_l_block_indented_block_out';
	ns_l_block_map_implicit_entry = (
		reset_node_properties
		* m.Cg(V'ns_s_block_map_implicit_key' + e_node, 'key')
		* reset_node_properties
		* m.Cg(V'c_l_block_map_implicit_value', 'value')
		* m.Cg(m.Cc(nil), 'tag_scalar_unplain')
		* m.Cg(m.Cc(nil), 'tag_other')
	);
	ns_s_block_map_implicit_key =
		V'c_s_implicit_json_key_block_key'
		+ ns_s_implicit_yaml_key_block_key;
	c_s_implicit_json_key_block_key = V'c_flow_json_node_block_key' * s_separate_in_line^-1;
	c_s_implicit_json_key_flow_key = V'c_flow_json_node_flow_key' * s_separate_in_line^-1;
	c_flow_json_node_block_key = (c_ns_properties_in_line * s_separate_in_line)^-1 * V'c_flow_json_content_flow_key';
	c_flow_json_node_flow_key = (c_ns_properties_in_line * s_separate_in_line)^-1 * V'c_flow_json_content_flow_key';

	c_l_block_map_implicit_value =
		':'
		* (V's_l_block_node_block_out' + (e_node * s_l_comments))
		;

	l_block_mapping = (
		m.Cg(m.Ct(
			bigger_indent
			* (s_indent * V'ns_l_block_map_entry')^1
			* m.Cg(m.Cc(nil), 'indent')
		), 'data')
		* m.Cg(m.Cc'mapping', 'primitive')
	);

	ns_flow_node_flow_out = c_ns_alias_node + V'ns_flow_content_flow_out' + (
		c_ns_properties_multiline * (
	    	(
	    		s_separate_lines
	        	* V'ns_flow_content_flow_out'
	        )
	      	+
	      	e_scalar
		)
	);

	ns_flow_content_flow_out = (
		ns_flow_yaml_content_flow_out
		+ V'c_flow_json_content_flow_in');
	ns_flow_content_flow_in = (
		ns_flow_yaml_content_flow_in
		+ V'c_flow_json_content_flow_in');
	ns_flow_content_flow_key = (
		ns_flow_yaml_content_flow_key
		+ V'c_flow_json_content_flow_key');
	ns_flow_content_block_key = (
		ns_flow_yaml_content_block_key
		+ V'c_flow_json_content_flow_key');
	c_flow_json_content_flow_in = (
		V'c_flow_sequence_flow_in'
		+ V'c_flow_mapping_flow_in'
		+ c_single_quoted_multi_line
		+ c_double_quoted_multi_line);
	c_flow_json_content_flow_key = (
		V'c_flow_sequence_flow_key'
		+ V'c_flow_mapping_flow_key'
		+ c_single_quoted_one_line
		+ c_double_quoted_one_line);
	c_flow_sequence_flow_in = (
		'[' * s_separate_lines^-1
		* m.Ct(
			m.Cg(m.Ct(
				V'ns_s_flow_seq_entries_flow_in'^-1
			), 'data')
			* m.Cg(m.Cc 'sequence', 'primitive')
			* m.Cg(m.Cb 'tag_other', 'tag')
			* m.Cg(m.Cb 'anchor', 'anchor')
		)
		* ']');
	c_flow_sequence_flow_key = (
		'[' * s_separate_in_line^-1
		* m.Ct(
			m.Cg(m.Ct(
				V'ns_s_flow_seq_entries_flow_key'^-1
			), 'data')
			* m.Cg(m.Cc 'sequence', 'primitive')
			* m.Cg(m.Cb 'tag_other', 'tag')
			* m.Cg(m.Cb 'anchor', 'anchor')
		)
		* ']');	
	c_flow_mapping_flow_in = (
		'{' * s_separate_lines^-1
		* m.Ct(
			m.Cg(m.Ct(
				V'ns_s_flow_map_entries_flow_in'^-1
			), 'data')
			* m.Cg(m.Cc 'mapping', 'primitive')
			* m.Cg(m.Cb 'tag_other', 'tag')
			* m.Cg(m.Cb 'anchor', 'anchor')
		)
		* '}');
	c_flow_mapping_flow_key = (
		'{' * s_separate_in_line^-1
		* m.Ct(
			m.Cg(m.Ct(
				V'ns_s_flow_map_entries_flow_key'^-1
			), 'data')
			* m.Cg(m.Cc 'mapping', 'primitive')
			* m.Cg(m.Cb 'tag_other', 'tag')
			* m.Cg(m.Cb 'anchor', 'anchor')
		)
		* '}');
	ns_s_flow_seq_entries_flow_in = (
		V'ns_flow_seq_entry_flow_in' * s_separate_lines^-1
		* (',' * s_separate_lines^-1 * V'ns_s_flow_seq_entries_flow_in'^-1)^-1
		* clear_node_properties
	);
	ns_s_flow_seq_entries_flow_key = (
		V'ns_flow_seq_entry_flow_key' * s_separate_in_line^-1
		* (',' * s_separate_in_line^-1 * V'ns_s_flow_seq_entries_flow_key'^-1)^-1
		* clear_node_properties
	);
	ns_s_flow_map_entries_flow_in = (
		V'ns_flow_map_entry_flow_in' * s_separate_lines^-1
		* (',' * s_separate_lines^-1 * V'ns_s_flow_map_entries_flow_in'^-1)^-1
		* clear_node_properties
	);
	ns_s_flow_map_entries_flow_key = (
		V'ns_flow_map_entry_flow_key' * s_separate_in_line^-1
		* (',' * s_separate_in_line^-1 * V'ns_s_flow_map_entries_flow_key'^-1)^-1
		* clear_node_properties
	);
	ns_flow_seq_entry_flow_in = reset_node_properties * (
		m.Ct(
			m.Cg(m.Ct(V'ns_flow_pair_flow_in'), 'data')
			* m.Cg(m.Cc'mapping', 'primitive')
			* m.Cg(m.Cb'tag_other', 'tag')
			* m.Cg(m.Cb'anchor', 'anchor')
		)
		+ V'ns_flow_node_flow_in');
	ns_flow_seq_entry_flow_key = reset_node_properties * (
		m.Ct(
			m.Cg(m.Ct(V'ns_flow_pair_flow_key'), 'data')
			* m.Cg(m.Cc'mapping', 'primitive')
			* m.Cg(m.Cb'tag_other', 'tag')
			* m.Cg(m.Cb'anchor', 'anchor')
		)
		+ V'ns_flow_node_flow_key');
	ns_flow_pair_flow_in = (
		('?' * s_separate_lines * V'ns_flow_map_explicit_entry_flow_in')
		+ V'ns_flow_pair_entry_flow_in');
	ns_flow_pair_flow_key = (
		('?' * s_separate_in_line * V'ns_flow_map_explicit_entry_flow_key')
		+ V'ns_flow_pair_entry_flow_key');
	ns_flow_map_explicit_entry_flow_in = (
		V'ns_flow_map_implicit_entry_flow_in'
		+ m.Ct(
			reset_node_properties
			* m.Cg(e_node, 'key')
			* m.Cg(e_node, 'value')
			* clear_node_properties)
	);
	ns_flow_map_explicit_entry_flow_key = (
		V'ns_flow_map_implicit_entry_flow_key'
		+ m.Ct(
			reset_node_properties
			* m.Cg(e_node, 'key')
			* m.Cg(e_node, 'value')
			* clear_node_properties)
	);
	ns_flow_map_implicit_entry_flow_in = (
		V'c_ns_flow_map_json_key_entry_flow_in'
		+ V'ns_flow_map_yaml_key_entry_flow_in'
		+ V'c_ns_flow_map_entry_key_entry_flow_in'
	);
	ns_flow_map_implicit_entry_flow_key = (
		V'c_ns_flow_map_json_key_entry_flow_key'
		+ V'ns_flow_map_yaml_key_entry_flow_key'
		+ V'c_ns_flow_map_entry_key_entry_flow_key'
		
	);
	c_ns_flow_map_json_key_entry_flow_in = m.Ct(
		reset_node_properties
		* m.Cg(V'c_flow_json_node_flow_in', 'key')
		* reset_node_properties
		* m.Cg(
			s_separate_lines^-1 * V'c_ns_flow_map_adjacent_value_flow_in'
			+ e_node,
			'value'
		)
		* clear_node_properties
	);
	c_ns_flow_map_json_key_entry_flow_key = m.Ct(
		reset_node_properties
		* m.Cg(V'c_flow_json_node_flow_key', 'key')
		* reset_node_properties
		* m.Cg(
			s_separate_in_line^-1 * V'c_ns_flow_map_adjacent_value_flow_key'
			+ e_node,
			'value'
		)
		* clear_node_properties
	);
	c_ns_flow_map_json_key_entry_block_key = m.Ct(
		reset_node_properties
		* m.Cg(V'c_flow_json_node_block_key', 'key')
		* reset_node_properties
		* m.Cg(
			s_separate_in_line^-1 * V'c_ns_flow_map_adjacent_value_block_key'
			+ e_node,
			'value'
		)
		* clear_node_properties
	);
	c_flow_json_node_flow_in = (
		(c_ns_properties_multiline * s_separate_lines * V'c_flow_json_content_flow_in')
		+ V'c_flow_json_content_flow_in'
	);
	c_ns_flow_map_adjacent_value_flow_in = (
		':' * (
			(s_separate_lines^-1 * V'ns_flow_node_flow_in')
			+ e_node
		)
	);
	c_ns_flow_map_adjacent_value_flow_key = (
		':' * (
			(s_separate_in_line^-1 * V'ns_flow_node_flow_key')
			+ e_node
		)
	);
	c_ns_flow_map_adjacent_value_block_key = (
		':' * (
			(s_separate_in_line^-1 * V'ns_flow_node_block_key')
			+ e_node
		)
	);
	c_ns_flow_map_entry_key_entry_flow_in = m.Ct(
		reset_node_properties
		* m.Cg(e_node, 'key')
		* reset_node_properties
		* m.Cg(V'c_ns_flow_map_separate_value_flow_in', 'value')
		* clear_node_properties
	);
	c_ns_flow_map_entry_key_entry_flow_key = m.Ct(
		reset_node_properties
		* m.Cg(e_node, 'key')
		* reset_node_properties
		* m.Cg(V'c_ns_flow_map_separate_value_flow_key', 'value')
		* clear_node_properties
	);
	c_ns_flow_map_entry_key_entry_block_key = m.Ct(
		reset_node_properties
		* m.Cg(e_node, 'key')
		* reset_node_properties
		* m.Cg(V'c_ns_flow_map_separate_value_block_key', 'value')
		* clear_node_properties
	);
	ns_flow_map_yaml_key_entry_flow_in = m.Ct(
		reset_node_properties
		* m.Cg(ns_flow_yaml_node_flow_in, 'key')
		* reset_node_properties
		* m.Cg(
			(s_separate_lines^-1 * V'c_ns_flow_map_separate_value_flow_in') + e_node,
			'value'
		)
		* clear_node_properties
	);
	ns_flow_map_yaml_key_entry_flow_key = m.Ct(
		reset_node_properties
		* m.Cg(ns_flow_yaml_node_flow_key, 'key')
		* reset_node_properties
		* m.Cg(
			(s_separate_in_line^-1 * V'c_ns_flow_map_separate_value_flow_key') + e_node,
			'value'
		)
		* clear_node_properties
	);
	ns_flow_map_yaml_key_entry_block_key = m.Ct(
		reset_node_properties
		* m.Cg(ns_flow_yaml_node_block_key, 'key')
		* reset_node_properties
		* m.Cg(
			(s_separate_in_line^-1 * V'c_ns_flow_map_separate_value_block_key') + e_node,
			'value'
		)
		* clear_node_properties
	);
	c_ns_flow_map_separate_value_flow_in = ":" * -ns_plain_safe_in * (
		(s_separate_lines * V'ns_flow_node_flow_in')
		+ e_node
	);
	c_ns_flow_map_separate_value_flow_key = ":" * -ns_plain_safe_in * (
		(s_separate_in_line * V'ns_flow_node_flow_key')
		+ e_node
	);
	c_ns_flow_map_separate_value_block_key = ":" * -ns_plain_safe_out * (
		(s_separate_in_line * V'ns_flow_node_block_key')
		+ e_node
	);
	ns_flow_node_flow_in = (
		c_ns_alias_node
		+ V'ns_flow_content_flow_in'
		+ (c_ns_properties_multiline * (
			(s_separate_lines * V'ns_flow_content_flow_in')
			+ e_scalar))
	);
	ns_flow_node_flow_key = (
		c_ns_alias_node
		+ V'ns_flow_content_flow_key'
		+ (c_ns_properties_in_line * (
			(s_separate_in_line * V'ns_flow_content_flow_key')
			+ e_scalar))
	);
	ns_flow_node_block_key = (
		c_ns_alias_node
		+ V'ns_flow_content_block_key'
		+ (c_ns_properties_in_line * (
			(s_separate_in_line * V'ns_flow_content_block_key')
			+ e_scalar))
	);
	ns_flow_pair_entry_flow_in = (
		V'ns_flow_pair_yaml_key_entry_flow_in'
		+ V'c_ns_flow_map_empty_key_entry_flow_in'
		+ V'c_ns_flow_pair_json_key_entry_flow_in'
	);
	ns_flow_pair_entry_flow_key = (
		V'ns_flow_pair_yaml_key_entry_flow_key'
		+ V'c_ns_flow_map_empty_key_entry_flow_key'
		+ V'c_ns_flow_pair_json_key_entry_flow_key'
	);
	ns_flow_pair_entry_block_key = (
		V'ns_flow_pair_yaml_key_entry_block_key'
		+ V'c_ns_flow_map_empty_key_entry_block_key'
		+ V'c_ns_flow_pair_json_key_entry_block_key'
	);
	ns_flow_pair_yaml_key_entry_flow_in = m.Ct(
		reset_node_properties
		* m.Cg(ns_s_implicit_yaml_key_flow_key, 'key')
		* reset_node_properties
		* m.Cg(V'c_ns_flow_map_separate_value_flow_in', 'value')
		* clear_node_properties
	);
	ns_flow_pair_yaml_key_entry_flow_key = m.Ct(
		reset_node_properties
		* m.Cg(ns_s_implicit_yaml_key_flow_key, 'key')
		* reset_node_properties
		* m.Cg(V'c_ns_flow_map_separate_value_flow_key', 'value')
		* clear_node_properties
	);
	ns_flow_pair_yaml_key_entry_block_key = m.Ct(
		reset_node_properties
		* m.Cg(ns_s_implicit_yaml_key_block_key, 'key')
		* reset_node_properties
		* m.Cg(V'c_ns_flow_map_separate_value_block_key', 'value')
		* clear_node_properties
	);
	ns_flow_map_entry_flow_in = (
		('?' * s_separate_lines * V'ns_flow_map_explicit_entry_flow_in')
		+ V'ns_flow_map_implicit_entry_flow_in'
	);
	ns_flow_map_entry_flow_key = (
		('?' * s_separate_in_line * V'ns_flow_map_explicit_entry_flow_key')
		+ V'ns_flow_map_implicit_entry_flow_key'
	);
	c_ns_flow_map_empty_key_entry_flow_in = (
		reset_node_properties
		* m.Cg(e_node, 'key')
		* reset_node_properties
		* m.Cg(V'c_ns_flow_map_separate_value_flow_in', 'value')
		* clear_node_properties
	);
	c_ns_flow_map_empty_key_entry_flow_key = (
		reset_node_properties
		* m.Cg(e_node, 'key')
		* reset_node_properties
		* m.Cg(V'c_ns_flow_map_separate_value_flow_key', 'value')
		* clear_node_properties
	);
	c_ns_flow_map_empty_key_entry_block_key = (
		reset_node_properties
		* m.Cg(e_node, 'key')
		* reset_node_properties
		* m.Cg(V'c_ns_flow_map_separate_value_block_key', 'value')
		* clear_node_properties
	);
	c_ns_flow_pair_json_key_entry_flow_in = (
		reset_node_properties
		* m.Cg(V'c_s_implicit_json_key_flow_key', 'key')
		* reset_node_properties
		* m.Cg(V'c_ns_flow_map_adjacent_value_flow_in', 'value')
		* clear_node_properties
	);
	c_ns_flow_pair_json_key_entry_flow_key = (
		reset_node_properties
		* m.Cg(V'c_s_implicit_json_key_flow_key', 'key')
		* reset_node_properties
		* m.Cg(V'c_ns_flow_map_adjacent_value_flow_key', 'value')
		* clear_node_properties
	);
	c_ns_flow_pair_json_key_entry_block_key = (
		reset_node_properties
		* m.Cg(V'c_s_implicit_json_key_block_key', 'key')
		* reset_node_properties
		* m.Cg(V'c_ns_flow_map_adjacent_value_block_key', 'value')
		* clear_node_properties
	);
}

local l_bare_document = (
	m.Cg(m.Cc(-1), 'indent')
	* reset_node_properties
	* s_l_block_node_block_in)


local prefix_l_bare_document = l_bare_document * m.Cp()


local document_stream = {}

local prefix_utf_type = require 'parse.prefix.utf_type'
local prefix_directives = require 'parse.yaml.prefix.directives'
local skip_lines = require 'parse.yaml.prefix.skip_lines'
local end_of_document = require 'parse.yaml.prefix.end_of_document'
local make_prefix_tag = require 'parse.yaml.make.prefix.tag'

function document_stream.read(source)
	local utf_type, pos = prefix_utf_type:match(source)
	if utf_type == nil then
		return nil, 'unknown encoding'
	elseif utf_type ~= 'utf-8' then
		local from_utf = require 'parse.convert.to_utf8.from_utf'
		source = from_utf:match(source)
		pos = 1
	end
	local documents = {}
	pos = skip_lines:match(source, pos)
	while pos <= #source do
		local directives, new_pos = prefix_directives:match(source, pos)
		if directives ~= nil then
			pos = skip_lines:match(source, new_pos)
		end
		local end_pos = end_of_document:match(source, pos)
		if end_pos ~= nil then
			if directives and next(directives) == nil then
				directives = nil
			end
			documents[#documents+1] = {
				directives = directives;
				content = {
					tag = '?';
					primitive = 'scalar';
					data = '';
				};
			}
			pos = end_pos
		else
			local tag_handle_to_prefix = {['!!'] = 'tag:yaml.org,2002:'; ['!']='!'}
			if directives then
				for i, directive in ipairs(directives) do
					if directive.name == 'TAG' then
						if directive.arguments == nil or #directive.arguments ~= 2 then
							print(directive.arguments)
							return nil, 'wrong number of arguments for %TAG directive'
						end
						local handle, prefix = directive.arguments[1], directive.arguments[2]
						tag_handle_to_prefix[handle] = prefix
					end
				end
				if next(directives) == nil then
					directives = nil
				end
			end
			local unquoted_tag, quoted_tag = '?', '!'
			local prefix_tag = make_prefix_tag(tag_handle_to_prefix)
			do
				local given_tag, new_pos = prefix_tag:match(source, pos)
				if given_tag ~= nil then
					pos = skip_lines:match(source, new_pos)
					unquoted_tag, quoted_tag = given_tag, given_tag
				end
			end
			local end_pos = end_of_document:match(source, pos)
			if end_pos ~= nil then
				pos = end_pos
				documents[#documents+1] = {
					directives = directives;
					content = {
						tag = unquoted_tag;
						primitive = 'scalar';
						data = '';
					};
				}
			else
				local content, new_pos = prefix_l_bare_document:match(source, pos)
				if content == nil then
					return nil, 'unrecognised content'
				end
				documents[#documents+1] = {
					directives = directives;
					content = content;
				}
				pos = skip_lines:match(source, new_pos)
				pos = end_of_document:match(source, pos) or pos
			end
		end
	end
	return documents
end

return document_stream
