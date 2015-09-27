-- Other, Private use
local make_set = require 'parse.char.utf8.make.set'

return make_set {
	S = '\u{e000}\u{f8ff}\u{f0000}\u{ffffd}\u{100000}\u{10fffd}';
}
