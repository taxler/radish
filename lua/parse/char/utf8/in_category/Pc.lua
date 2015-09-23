-- Punctuation, Connector
local m_utf8 = require "parse.match.utf8"

return m_utf8 {
	S = '_\u{203f}\u{2040}\u{2054}\u{fe33}\u{fe34}\u{ff3f}';
	R = "\u{fe4d}\u{fe4f}";
}
