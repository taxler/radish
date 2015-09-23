-- Number, Letter
local m_utf8 = require "parse.match.utf8"

return m_utf8 {
	S = '\u{3007}\u{10341}\u{1034a}';
	R = {
		"\u{16ee}\u{16f0}","\u{2160}\u{2182}","\u{2185}\u{2188}",
		"\u{3021}\u{3029}","\u{3038}\u{303a}","\u{a6e6}\u{a6ef}",
		"\u{10140}\u{10174}","\u{103d1}\u{103d5}","\u{12400}\u{1246e}"
	};
}
