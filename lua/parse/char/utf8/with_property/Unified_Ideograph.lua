
local m_utf8 = require 'parse.match.utf8'

return m_utf8 {
	S = '\u{fa0e}\u{fa0f}\u{fa11}\u{fa13}\u{fa14}\u{fa21}\u{fa23}\u{fa24}';
	R = {
		'\u{3400}\u{4db5}', '\u{4e00}\u{9fd5}', '\u{fa27}\u{fa29}';
		'\u{20000}\u{2a6d6}', '\u{2a700}\u{2b734}', '\u{2b740}\u{2b81d}', '\u{2b820}\u{2cea1}';
	};
}
