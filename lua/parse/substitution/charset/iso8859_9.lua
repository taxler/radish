
local byte = require 'parse.substitution.charset.byte'

return byte + {
	['\xd0'] = '\u{11e}'; -- latin capital letter g with breve
	['\xdd'] = '\u{130}'; -- latin capital letter i with dot above
	['\xde'] = '\u{15e}'; -- latin capital letter s with cedilla
	['\xf0'] = '\u{11f}'; -- latin small letter g with breve
	['\xfd'] = '\u{131}'; -- latin small letter dotless i
	['\xfe'] = '\u{15f}'; -- latin small letter s with cedilla
}
