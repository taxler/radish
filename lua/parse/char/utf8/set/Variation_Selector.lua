local make_set = require 'parse.char.utf8.make.set'

return make_set {
	R = {'\u{180b}\u{180d}', '\u{fe00}\u{fe0f}', '\u{e0100}\u{e01ef}'};
}
