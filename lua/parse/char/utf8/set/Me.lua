-- Mark, Enclosing
local make_set = require 'parse.char.utf8.make.set'

return make_set {
	S = '\u{488}\u{489}\u{1abe}';
	R = {"\u{20dd}\u{20e0}","\u{20e2}\u{20e4}","\u{a670}\u{a672}"};
}
