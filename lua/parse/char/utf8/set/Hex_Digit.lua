local make_set = require 'parse.char.utf8.make.set'

return make_set {
	R = {
		'09', 'af', 'AF';
		-- fullwidth
		'\u{ff10}\u{ff19}', '\u{ff21}\u{ff26}', '\u{ff41}\u{ff46}';
	};
}
