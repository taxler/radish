-- Punctuation, Initial Quote
local m_utf8 = require "parse.match.utf8"

return m_utf8 {
	S = '\u{ab}\u{2018}\u{201b}\u{201c}\u{201f}\u{2039}\u{2e02}\u{2e04}\u{2e09}\u{2e0c}\u{2e1c}\u{2e20}';
}
