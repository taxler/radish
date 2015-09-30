-- Separator, Space
local make_set = require 'parse.char.utf8.make.set'

return make_set {
	S = ' \u{a0}\u{1680}\u{202f}\u{205f}\u{3000}';
	R = "\u{2000}\u{200a}";
}
