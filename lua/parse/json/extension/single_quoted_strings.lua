
local re = require 're'

local c_single_quoted = re.compile([[
	c_string <- "'" {~ chunk* ~} "'"
	chunk <- [^'\]+ / escape
	escape <- &'\' {: esc_self / esc_control / esc_unicode :}
	esc_self <- '\' {['"\/]}
	esc_control <- '\' ([bfnrt] -> to_control)
	esc_unicode <- %ESC_UNICODE
]], {
	to_control = require 'parse.substitution.c.escape_sequence.single_letter';
	ESC_UNICODE = require 'parse.json.read.u_escape';
})

return {
	priority = 10;
	apply = function(self, context)
		context.C_STRING_LITERAL = context.C_STRING_LITERAL + c_single_quoted
		context.C_STRING_FULL = context.C_STRING_FULL + c_single_quoted
	end;
}
