
local m_utf8 = require 'parse.match.utf8'

return m_utf8 {
	S = ' \t\r\n\11\12\u{85}\u{A0}\u{1680}\u{2028}\u{2029}\u{202f}\u{205f}\u{3000}';
	R = '\u{2000}\u{200A}';
}
