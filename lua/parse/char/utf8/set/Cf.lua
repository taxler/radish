-- Other, Format
local m_utf8 = require "parse.match.utf8"

return m_utf8 {
	S = '\u{ad}\u{61c}\u{6dd}\u{70f}\u{180e}\u{feff}\u{110bd}\u{e0001}';
	R = {
		"\u{600}\u{605}",
		"\u{200b}\u{200f}","\u{202a}\u{202e}","\u{2060}\u{2064}","\u{2066}\u{206f}","\u{fff9}\u{fffb}",
		"\u{1bca0}\u{1bca3}","\u{1d173}\u{1d17a}","\u{e0020}\u{e007f}"
	};
}
