-- Symbol, Math
local make_set = require 'parse.char.utf8.make.set'

return make_set {
	S = '+|~<=>'
		.. '\u{ac}\u{b1}\u{d7}\u{f7}'
		.. '\u{3f6}'
		.. '\u{2044}\u{2052}\u{2118}\u{214b}\u{219a}\u{219b}\u{21a0}\u{21a3}\u{21a6}\u{21ae}'
		.. '\u{21ce}\u{21cf}\u{21d2}\u{21d4}\u{2320}\u{2321}\u{237c}\u{25b7}\u{25c1}\u{266f}'
		.. '\u{fb29}\u{fe62}\u{ff0b}\u{ff5c}\u{ff5e}\u{ffe2}'
		.. '\u{1d6c1}\u{1d6db}\u{1d6fb}\u{1d715}\u{1d735}\u{1d74f}\u{1d76f}\u{1d789}\u{1d7a9}'
		.. '\u{1d7c3}\u{1eef0}\u{1eef1}';
	R = {
		"\u{606}\u{608}",
		"\u{207a}\u{207c}","\u{208a}\u{208c}","\u{2140}\u{2144}","\u{2190}\u{2194}","\u{21f4}\u{22ff}",
		"\u{239b}\u{23b3}","\u{23dc}\u{23e1}","\u{25f8}\u{25ff}","\u{27c0}\u{27c4}","\u{27c7}\u{27e5}",
		"\u{27f0}\u{27ff}","\u{2900}\u{2982}","\u{2999}\u{29d7}","\u{29dc}\u{29fb}","\u{29fe}\u{2aff}",
		"\u{2b30}\u{2b44}","\u{2b47}\u{2b4c}","\u{fe64}\u{fe66}","\u{ff1c}\u{ff1e}","\u{ffe9}\u{ffec}"
	};
}
