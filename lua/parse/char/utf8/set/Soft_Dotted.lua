local make_set = require 'parse.char.utf8.make.set'

return make_set {
	S = 'ij'
		.. '\u{12f}\u{249}\u{268}\u{29d}\u{2b2}\u{3f3}\u{456}\u{458}'
		.. '\u{1d62}\u{1d96}\u{1da4}\u{1da8}\u{1e2d}\u{1ecb}\u{2071}\u{2148}\u{2149}\u{2c7c}'
		.. '\u{1d422}\u{1d423}\u{1d456}\u{1d457}\u{1d48a}\u{1d48b}\u{1d4be}\u{1d4bf}\u{1d4f2}\u{1d4f3}'
		.. '\u{1d526}\u{1d527}\u{1d55a}\u{1d55b}\u{1d58e}\u{1d58f}\u{1d5c2}\u{1d5c3}\u{1d5f6}\u{1d5f7}'
		.. '\u{1d62a}\u{1d62b}\u{1d65e}\u{1d65f}\u{1d692}\u{1d693}';
}
