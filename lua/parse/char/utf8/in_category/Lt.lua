-- Letter, Titlecase
local m_utf8 = require "parse.match.utf8"

return m_utf8 {
	S = '\u{1c5}\u{1c8}\u{1cb}\u{1f2}\u{1fbc}\u{1fcc}\u{1ffc}';
	R = {"\u{1f88}\u{1f8f}","\u{1f98}\u{1f9f}","\u{1fa8}\u{1faf}"};
}
