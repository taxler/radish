
local byte = require 'parse.substitution.charset.byte'

return byte + {
	['\xa1'] = '\u{201d}'; -- right double quotation mark
	['\xa5'] = '\u{201e}'; -- double low-9 quotation mark
	['\xa8'] = '\u{d8}'; -- latin capital letter o with stroke
	['\xaa'] = '\u{156}'; -- latin capital letter r with cedilla
	['\xaf'] = '\u{c6}'; -- latin capital letter ae
	['\xb4'] = '\u{201c}'; -- left double quotation mark
	['\xba'] = '\u{157}'; -- latin small letter r with cedilla
	['\xbf'] = '\u{e6}'; -- latin small letter ae
	['\xc0'] = '\u{104}'; -- latin capital letter a with ogonek
	['\xc1'] = '\u{12e}'; -- latin capital letter i with ogonek
	['\xc2'] = '\u{100}'; -- latin capital letter a with macron
	['\xc3'] = '\u{106}'; -- latin capital letter c with acute
	['\xc6'] = '\u{118}'; -- latin capital letter e with ogonek
	['\xc7'] = '\u{112}'; -- latin capital letter e with macron
	['\xc8'] = '\u{10c}'; -- latin capital letter c with caron
	['\xca'] = '\u{179}'; -- latin capital letter z with acute
	['\xcb'] = '\u{116}'; -- latin capital letter e with dot above
	['\xcc'] = '\u{122}'; -- latin capital letter g with cedilla
	['\xcd'] = '\u{136}'; -- latin capital letter k with cedilla
	['\xce'] = '\u{12a}'; -- latin capital letter i with macron
	['\xcf'] = '\u{13b}'; -- latin capital letter l with cedilla
	['\xd0'] = '\u{160}'; -- latin capital letter s with caron
	['\xd1'] = '\u{143}'; -- latin capital letter n with acute
	['\xd2'] = '\u{145}'; -- latin capital letter n with cedilla
	['\xd4'] = '\u{14c}'; -- latin capital letter o with macron
	['\xd8'] = '\u{172}'; -- latin capital letter u with ogonek
	['\xd9'] = '\u{141}'; -- latin capital letter l with stroke
	['\xda'] = '\u{15a}'; -- latin capital letter s with acute
	['\xdb'] = '\u{16a}'; -- latin capital letter u with macron
	['\xdd'] = '\u{17b}'; -- latin capital letter z with dot above
	['\xde'] = '\u{17d}'; -- latin capital letter z with caron
	['\xe0'] = '\u{105}'; -- latin small letter a with ogonek
	['\xe1'] = '\u{12f}'; -- latin small letter i with ogonek
	['\xe2'] = '\u{101}'; -- latin small letter a with macron
	['\xe3'] = '\u{107}'; -- latin small letter c with acute
	['\xe6'] = '\u{119}'; -- latin small letter e with ogonek
	['\xe7'] = '\u{113}'; -- latin small letter e with macron
	['\xe8'] = '\u{10d}'; -- latin small letter c with caron
	['\xea'] = '\u{17a}'; -- latin small letter z with acute
	['\xeb'] = '\u{117}'; -- latin small letter e with dot above
	['\xec'] = '\u{123}'; -- latin small letter g with cedilla
	['\xed'] = '\u{137}'; -- latin small letter k with cedilla
	['\xee'] = '\u{12b}'; -- latin small letter i with macron
	['\xef'] = '\u{13c}'; -- latin small letter l with cedilla
	['\xf0'] = '\u{161}'; -- latin small letter s with caron
	['\xf1'] = '\u{144}'; -- latin small letter n with acute
	['\xf2'] = '\u{146}'; -- latin small letter n with cedilla
	['\xf4'] = '\u{14d}'; -- latin small letter o with macron
	['\xf8'] = '\u{173}'; -- latin small letter u with ogonek
	['\xf9'] = '\u{142}'; -- latin small letter l with stroke
	['\xfa'] = '\u{15b}'; -- latin small letter s with acute
	['\xfb'] = '\u{16b}'; -- latin small letter u with macron
	['\xfd'] = '\u{17c}'; -- latin small letter z with dot above
	['\xfe'] = '\u{17e}'; -- latin small letter z with caron
	['\xff'] = '\u{2019}'; -- right single quotation mark
}