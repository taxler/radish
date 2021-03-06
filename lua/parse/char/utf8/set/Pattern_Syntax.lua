local make_set = require 'parse.char.utf8.make.set'

return make_set {
	S = [["'\]] .. '!#$&()*+,-./:;<=>?@[]^`{|}~'
		.. '\u{a9}\u{ab}\u{ac}\u{ae}\u{b0}\u{b1}\u{b6}\u{bb}\u{bf}\u{d7}\u{f7}'
		.. '\u{3030}\u{fd3e}\u{fd3f}\u{fe45}\u{fe46}';
	R = {
		'\u{a1}\u{a7}';
		'\u{2010}\u{2015}', '\u{2016}\u{2027}', '\u{2030}\u{203e}', '\u{2041}\u{2053}';
		'\u{2055}\u{205e}', '\u{2190}\u{245f}', '\u{2500}\u{2775}', '\u{2794}\u{2bff}';
		'\u{2e00}\u{2e7f}'; '\u{3001}\u{3003}', '\u{3008}\u{3020}';
	};
}
