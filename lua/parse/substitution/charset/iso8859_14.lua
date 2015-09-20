
local byte = require 'parse.substitution.charset.byte'

return byte + {
	['\xa1'] = '\u{1e02}'; -- latin capital letter b with dot above
	['\xa2'] = '\u{1e03}'; -- latin small letter b with dot above
	['\xa4'] = '\u{10a}'; -- latin capital letter c with dot above
	['\xa5'] = '\u{10b}'; -- latin small letter c with dot above
	['\xa6'] = '\u{1e0a}'; -- latin capital letter d with dot above
	['\xa8'] = '\u{1e80}'; -- latin capital letter w with grave
	['\xaa'] = '\u{1e82}'; -- latin capital letter w with acute
	['\xab'] = '\u{1e0b}'; -- latin small letter d with dot above
	['\xac'] = '\u{1ef2}'; -- latin capital letter y with grave
	['\xaf'] = '\u{178}'; -- latin capital letter y with diaeresis
	['\xb0'] = '\u{1e1e}'; -- latin capital letter f with dot above
	['\xb1'] = '\u{1e1f}'; -- latin small letter f with dot above
	['\xb2'] = '\u{120}'; -- latin capital letter g with dot above
	['\xb3'] = '\u{121}'; -- latin small letter g with dot above
	['\xb4'] = '\u{1e40}'; -- latin capital letter m with dot above
	['\xb5'] = '\u{1e41}'; -- latin small letter m with dot above
	['\xb7'] = '\u{1e56}'; -- latin capital letter p with dot above
	['\xb8'] = '\u{1e81}'; -- latin small letter w with grave
	['\xb9'] = '\u{1e57}'; -- latin small letter p with dot above
	['\xba'] = '\u{1e83}'; -- latin small letter w with acute
	['\xbb'] = '\u{1e60}'; -- latin capital letter s with dot above
	['\xbc'] = '\u{1ef3}'; -- latin small letter y with grave
	['\xbd'] = '\u{1e84}'; -- latin capital letter w with diaeresis
	['\xbe'] = '\u{1e85}'; -- latin small letter w with diaeresis
	['\xbf'] = '\u{1e61}'; -- latin small letter s with dot above
	['\xd0'] = '\u{174}'; -- latin capital letter w with circumflex
	['\xd7'] = '\u{1e6a}'; -- latin capital letter t with dot above
	['\xde'] = '\u{176}'; -- latin capital letter y with circumflex
	['\xf0'] = '\u{175}'; -- latin small letter w with circumflex
	['\xf7'] = '\u{1e6b}'; -- latin small letter t with dot above
	['\xfe'] = '\u{177}'; -- latin small letter y with circumflex
}
