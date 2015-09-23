-- Mark, Enclosing
local m_utf8 = require "parse.match.utf8"

return m_utf8 {
	S = '\u{488}\u{489}\u{1abe}';
	R = {"\u{20dd}\u{20e0}","\u{20e2}\u{20e4}","\u{a670}\u{a672}"};
}
