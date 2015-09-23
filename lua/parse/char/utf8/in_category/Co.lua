-- Other, Private use
local m_utf8 = require "parse.match.utf8"

return m_utf8 {
	S = '\u{e000}\u{f8ff}\u{f0000}\u{ffffd}\u{100000}\u{10fffd}';
}
