
local byte = require 'parse.substitution.charset.byte'

return byte + {
	['\xa1'] = '\u{104}'; -- latin capital letter a with ogonek
	['\xa2'] = '\u{105}'; -- latin small letter a with ogonek
	['\xa3'] = '\u{141}'; -- latin capital letter l with stroke
	['\xa4'] = '\u{20ac}'; -- euro sign
	['\xa5'] = '\u{201e}'; -- double low-9 quotation mark
	['\xa6'] = '\u{160}'; -- latin capital letter s with caron
	['\xa8'] = '\u{161}'; -- latin small letter s with caron
	['\xaa'] = '\u{218}'; -- latin capital letter s with comma below
	['\xac'] = '\u{179}'; -- latin capital letter z with acute
	['\xae'] = '\u{17a}'; -- latin small letter z with acute
	['\xaf'] = '\u{17b}'; -- latin capital letter z with dot above
	['\xb2'] = '\u{10c}'; -- latin capital letter c with caron
	['\xb3'] = '\u{142}'; -- latin small letter l with stroke
	['\xb4'] = '\u{17d}'; -- latin capital letter z with caron
	['\xb5'] = '\u{201d}'; -- right double quotation mark
	['\xb8'] = '\u{17e}'; -- latin small letter z with caron
	['\xb9'] = '\u{10d}'; -- latin small letter c with caron
	['\xba'] = '\u{219}'; -- latin small letter s with comma below
	['\xbc'] = '\u{152}'; -- latin capital ligature oe
	['\xbd'] = '\u{153}'; -- latin small ligature oe
	['\xbe'] = '\u{178}'; -- latin capital letter y with diaeresis
	['\xbf'] = '\u{17c}'; -- latin small letter z with dot above
	['\xc3'] = '\u{102}'; -- latin capital letter a with breve
	['\xc5'] = '\u{106}'; -- latin capital letter c with acute
	['\xd0'] = '\u{110}'; -- latin capital letter d with stroke
	['\xd1'] = '\u{143}'; -- latin capital letter n with acute
	['\xd5'] = '\u{150}'; -- latin capital letter o with double acute
	['\xd7'] = '\u{15a}'; -- latin capital letter s with acute
	['\xd8'] = '\u{170}'; -- latin capital letter u with double acute
	['\xdd'] = '\u{118}'; -- latin capital letter e with ogonek
	['\xde'] = '\u{21a}'; -- latin capital letter t with comma below
	['\xe3'] = '\u{103}'; -- latin small letter a with breve
	['\xe5'] = '\u{107}'; -- latin small letter c with acute
	['\xf0'] = '\u{111}'; -- latin small letter d with stroke
	['\xf1'] = '\u{144}'; -- latin small letter n with acute
	['\xf5'] = '\u{151}'; -- latin small letter o with double acute
	['\xf7'] = '\u{15b}'; -- latin small letter s with acute
	['\xf8'] = '\u{171}'; -- latin small letter u with double acute
	['\xfd'] = '\u{119}'; -- latin small letter e with ogonek
	['\xfe'] = '\u{21b}'; -- latin small letter t with comma below
}
