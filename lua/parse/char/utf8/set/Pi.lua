-- Punctuation, Initial Quote
local make_set = require 'parse.char.utf8.make.set'

return make_set {
	S = '\u{ab}\u{2018}\u{201b}\u{201c}\u{201f}\u{2039}\u{2e02}\u{2e04}\u{2e09}\u{2e0c}\u{2e1c}\u{2e20}';
}
