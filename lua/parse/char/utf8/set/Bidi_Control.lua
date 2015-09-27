
local make_set = require 'parse.char.utf8.make.set'

return make_set {
	S = '\u{61c}';
	R = {'\u{200e}\u{200f}', '\u{202a}\u{202e}'};
}
