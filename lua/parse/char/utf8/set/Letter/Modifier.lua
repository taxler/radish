-- Letter, Modifier
local make_set = require 'parse.char.utf8.make.set'

return make_set {
	S = '\u{2ec}\u{2ee}\u{374}\u{37a}\u{559}\u{640}\u{6e5}\u{6e6}\u{7f4}\u{7f5}\u{7fa}\u{81a}\u{824}'
		.. '\u{828}\u{971}\u{e46}\u{ec6}'
		.. '\u{10fc}\u{17d7}\u{1843}\u{1aa7}\u{1d78}\u{2071}\u{207f}\u{2c7c}\u{2c7d}\u{2d6f}\u{2e2f}'
		.. '\u{3005}\u{303b}\u{309d}\u{309e}\u{a015}\u{a60c}\u{a67f}\u{a69c}\u{a69d}\u{a770}\u{a788}'
		.. '\u{a7f8}\u{a7f9}\u{a9cf}\u{a9e6}\u{aa70}\u{aadd}\u{aaf3}\u{aaf4}\u{ff70}\u{ff9e}\u{ff9f}';
	R = {
		"\u{2b0}\u{2c1}","\u{2c6}\u{2d1}","\u{2e0}\u{2e4}";
		"\u{1c78}\u{1c7d}","\u{1d2c}\u{1d6a}","\u{1d9b}\u{1dbf}","\u{2090}\u{209c}","\u{3031}\u{3035}";
		"\u{30fc}\u{30fe}","\u{a4f8}\u{a4fd}","\u{a717}\u{a71f}","\u{ab5c}\u{ab5f}";
		"\u{16b40}\u{16b43}","\u{16f93}\u{16f9f}"
	};
}
