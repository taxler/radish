-- Other, Control
local make_set = require 'parse.char.utf8.make.set'

return make_set {
	R = {"\x00\x1F","\u{7f}\u{9f}"};
}
