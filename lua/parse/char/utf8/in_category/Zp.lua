-- Separator, Paragraph
local m_utf8 = require "parse.match.utf8"

return m_utf8 {
	S = '\u{2029}';
}

