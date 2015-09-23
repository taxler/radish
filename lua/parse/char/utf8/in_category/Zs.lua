-- Separator, Space
local m_utf8 = require "parse.match.utf8"

return m_utf8 {
	S = ' \u{a0}\u{1680}\u{202f}\u{205f}\u{3000}';
	R = "\u{2000}\u{200a}";
}
