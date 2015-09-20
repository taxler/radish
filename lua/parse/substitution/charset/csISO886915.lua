
local byte = require 'parse.substitution.charset.byte'

return byte + {
	['\xa4'] = '\u{20ac}'; -- euro sign
	['\xa6'] = '\u{160}'; -- latin capital letter s with caron
	['\xa8'] = '\u{161}'; -- latin small letter s with caron
	['\xb4'] = '\u{17d}'; -- latin capital letter z with caron
	['\xb8'] = '\u{17e}'; -- latin small letter z with caron
	['\xbc'] = '\u{152}'; -- latin capital ligature oe
	['\xbd'] = '\u{153}'; -- latin small ligature oe
	['\xbe'] = '\u{178}'; -- latin capital letter y with diaeresis
}
