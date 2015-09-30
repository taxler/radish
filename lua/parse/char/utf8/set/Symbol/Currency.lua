-- Symbol, Currency
local make_set = require 'parse.char.utf8.make.set'

return make_set {
	S = '$'
		.. '\u{58f}\u{60b}\u{9f2}\u{9f3}\u{9fb}\u{af1}\u{bf9}\u{e3f}'
		.. '\u{17db}\u{a838}\u{fdfc}\u{fe69}\u{ff04}\u{ffe0}\u{ffe1}\u{ffe5}\u{ffe6}';
	R = {"\u{a2}\u{a5}","\u{20a0}\u{20be}"};
}
