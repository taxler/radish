-- Punctuation, Connector
local make_set = require 'parse.char.utf8.make.set'

return make_set {
	S = '_\u{203f}\u{2040}\u{2054}\u{fe33}\u{fe34}\u{ff3f}';
	R = "\u{fe4d}\u{fe4f}";
}
