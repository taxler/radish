local make_set = require 'parse.char.utf8.make.set'

return make_set {
	S = ' \t\r\n\11\12\u{85}\u{200e}\u{200f}\u{2028}\u{2029}';
}
