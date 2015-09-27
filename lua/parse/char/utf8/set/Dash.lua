
local make_set = require 'parse.char.utf8.make.set'

return make_set {
	S = '-'
		.. '\u{58a}'
		.. '\u{1400}\u{1806}\u{2053}\u{207B}\u{208b}\u{2212}\u{2e3a}\u{2e3b}'
		.. '\u{fe31}\u{fe32}\u{2e17}\u{2e1a}\u{2e40}\u{301c}\u{3030}\u{30a0}'
		.. '\u{fe58}\u{fe63}\u{ff0d}';
	R = '\u{2010}\u{2015}';
}
