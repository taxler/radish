local make_set = require 'parse.char.utf8.make.set'

return make_set {
	S = '\u{34f}\u{115f}\u{1160}\u{17b4}\u{17b5}\u{2065}\u{3164}\u{ffa0}\u{e0000}';
	R = {'\u{fff0}\u{fff8}', '\u{e0002}\u{e001f}', '\u{e0080}\u{e00ff}', '\u{e01f0}\u{e0fff}'};
}
