local make_set = require 'parse.char.utf8.make.set'

return make_set {
	S = '\u{fffe}\u{ffff}'
		.. '\u{1fffe}\u{1ffff}'
		.. '\u{2fffe}\u{2ffff}'
		.. '\u{3fffe}\u{3ffff}'
		.. '\u{4fffe}\u{4ffff}'
		.. '\u{5fffe}\u{5ffff}'
		.. '\u{6fffe}\u{6ffff}'
		.. '\u{7fffe}\u{7ffff}'
		.. '\u{8fffe}\u{8ffff}'
		.. '\u{9fffe}\u{9ffff}'
		.. '\u{afffe}\u{affff}'
		.. '\u{bfffe}\u{bffff}'
		.. '\u{cfffe}\u{cffff}'
		.. '\u{dfffe}\u{dffff}'
		.. '\u{efffe}\u{effff}'
		.. '\u{ffffe}\u{fffff}'
		.. '\u{10fffe}\u{10ffff}';
	R = {'\u{fdd0}\u{fdef}'};
}
