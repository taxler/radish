-- Punctuation, Final quote
local m_utf8 = require "parse.match.utf8"

return m_utf8 {
	S = '\u{bb}\u{2019}\u{201d}\u{203a}\u{2e03}\u{2e05}\u{2e0a}\u{2e0d}\u{2e1d}\u{2e21}';
}
