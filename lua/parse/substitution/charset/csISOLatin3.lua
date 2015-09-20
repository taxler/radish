
local byte = require 'parse.substitution.charset.byte'

return byte + {
	['\xa1'] = '\u{126}'; -- latin capital letter h with stroke
	['\xa2'] = '\u{2d8}'; -- breve
	['\xa5'] = require 'parse.substitution.undefined_char';
	['\xa6'] = '\u{124}'; -- latin capital letter h with circumflex
	['\xa9'] = '\u{130}'; -- latin capital letter i with dot above
	['\xaa'] = '\u{15e}'; -- latin capital letter s with cedilla
	['\xab'] = '\u{11e}'; -- latin capital letter g with breve
	['\xac'] = '\u{134}'; -- latin capital letter j with circumflex
	['\xae'] = require 'parse.substitution.undefined_char';
	['\xaf'] = '\u{17b}'; -- latin capital letter z with dot above
	['\xb1'] = '\u{127}'; -- latin small letter h with stroke
	['\xb6'] = '\u{125}'; -- latin small letter h with circumflex
	['\xb9'] = '\u{131}'; -- latin small letter dotless i
	['\xba'] = '\u{15f}'; -- latin small letter s with cedilla
	['\xbb'] = '\u{11f}'; -- latin small letter g with breve
	['\xbc'] = '\u{135}'; -- latin small letter j with circumflex
	['\xbe'] = require 'parse.substitution.undefined_char';
	['\xbf'] = '\u{17c}'; -- latin small letter z with dot above
	['\xc3'] = require 'parse.substitution.undefined_char';
	['\xc5'] = '\u{10a}'; -- latin capital letter c with dot above
	['\xc6'] = '\u{108}'; -- latin capital letter c with circumflex
	['\xd0'] = require 'parse.substitution.undefined_char';
	['\xd5'] = '\u{120}'; -- latin capital letter g with dot above
	['\xd8'] = '\u{11c}'; -- latin capital letter g with circumflex
	['\xdd'] = '\u{16c}'; -- latin capital letter u with breve
	['\xde'] = '\u{15c}'; -- latin capital letter s with circumflex
	['\xe3'] = require 'parse.substitution.undefined_char';
	['\xe5'] = '\u{10b}'; -- latin small letter c with dot above
	['\xe6'] = '\u{109}'; -- latin small letter c with circumflex
	['\xf0'] = require 'parse.substitution.undefined_char';
	['\xf5'] = '\u{121}'; -- latin small letter g with dot above
	['\xf8'] = '\u{11d}'; -- latin small letter g with circumflex
	['\xfd'] = '\u{16d}'; -- latin small letter u with breve
	['\xfe'] = '\u{15d}'; -- latin small letter s with circumflex
	['\xff'] = '\u{2d9}'; -- dot above
}
