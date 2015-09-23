-- Symbol, Modifier
local m_utf8 = require "parse.match.utf8"

return m_utf8 {
	S = '^`'
		.. '\u{a8}\u{af}\u{b4}\u{b8}'
		.. '\u{2ed}\u{375}\u{384}\u{385}'
		.. '\u{1fbd}\u{1ffd}\u{1ffe}\u{309b}\u{309c}\u{a720}\u{a721}\u{a789}\u{a78a}\u{ab5b}\u{ff3e}\u{ff40}\u{ffe3}';
	R = {
		"\u{2c2}\u{2c5}","\u{2d2}\u{2df}","\u{2e5}\u{2eb}","\u{2ef}\u{2ff}",
		"\u{1fbf}\u{1fc1}","\u{1fcd}\u{1fcf}","\u{1fdd}\u{1fdf}",
		"\u{1fed}\u{1fef}","\u{a700}\u{a716}","\u{fbb2}\u{fbc1}",
		"\u{1f3fb}\u{1f3ff}"
	};
}
