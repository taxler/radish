local make_set = require 'parse.char.utf8.make.set'

return make_set {

	S = '\u{aa}\u{ba}'
		.. '\u{2c0}\u{2c1}\u{345}\u{37a}'
		.. '\u{1d78}\u{2071}\u{207f}\u{2c7c}\u{2c7d}\u{a69c}\u{a69d}\u{a770}\u{a7f8}\u{a7f9}';

	R = {
		'\u{2b0}\u{2b8}', '\u{2e0}\u{2e4}', '\u{1d2c}\u{1d6a}', '\u{1d9b}\u{1dbf}',
		'\u{2090}\u{209c}', '\u{2170}\u{217f}', '\u{24d0}\u{24e9}', '\u{ab5c}\u{ab5f}'
	};

}
