local make_set = require 'parse.char.utf8.make.set'

return make_set {
	S = '\u{3006}\u{3007}';
	R = {
		'\u{3021}\u{3029}', '\u{3038}\u{303a}', '\u{3400}\u{4db5}', '\u{4e00}\u{9fd5}';
		'\u{f900}\u{fa6d}', '\u{fa70}\u{fad9}';
		'\u{20000}\u{2a6d6}', '\u{2a700}\u{2b734}', '\u{2b740}\u{2b81d}',
		'\u{2b820}\u{2cea1}', '\u{2f800}\u{2fa1d}';
	};
}
