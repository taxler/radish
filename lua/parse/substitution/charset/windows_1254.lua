
local byte = require 'parse.substitution.charset.byte'

return byte + {
	['\x80'] = '\u{20ac}'; -- euro sign
	['\x81'] = require 'parse.substitution.undefined_char';
	['\x82'] = '\u{201a}'; -- single low-9 quotation mark
	['\x83'] = '\u{192}'; -- latin small letter f with hook
	['\x84'] = '\u{201e}'; -- double low-9 quotation mark
	['\x85'] = '\u{2026}'; -- horizontal ellipsis
	['\x86'] = '\u{2020}'; -- dagger
	['\x87'] = '\u{2021}'; -- double dagger
	['\x88'] = '\u{2c6}'; -- modifier letter circumflex accent
	['\x89'] = '\u{2030}'; -- per mille sign
	['\x8a'] = '\u{160}'; -- latin capital letter s with caron
	['\x8b'] = '\u{2039}'; -- single left-pointing angle quotation mark
	['\x8c'] = '\u{152}'; -- latin capital ligature oe
	['\x8d'] = require 'parse.substitution.undefined_char';
	['\x8e'] = require 'parse.substitution.undefined_char';
	['\x8f'] = require 'parse.substitution.undefined_char';
	['\x90'] = require 'parse.substitution.undefined_char';
	['\x91'] = '\u{2018}'; -- left single quotation mark
	['\x92'] = '\u{2019}'; -- right single quotation mark
	['\x93'] = '\u{201c}'; -- left double quotation mark
	['\x94'] = '\u{201d}'; -- right double quotation mark
	['\x95'] = '\u{2022}'; -- bullet
	['\x96'] = '\u{2013}'; -- en dash
	['\x97'] = '\u{2014}'; -- em dash
	['\x98'] = '\u{2dc}'; -- small tilde
	['\x99'] = '\u{2122}'; -- trade mark sign
	['\x9a'] = '\u{161}'; -- latin small letter s with caron
	['\x9b'] = '\u{203a}'; -- single right-pointing angle quotation mark
	['\x9c'] = '\u{153}'; -- latin small ligature oe
	['\x9d'] = require 'parse.substitution.undefined_char';
	['\x9e'] = require 'parse.substitution.undefined_char';
	['\x9f'] = '\u{178}'; -- latin capital letter y with diaeresis
	['\xd0'] = '\u{11e}'; -- latin capital letter g with breve
	['\xdd'] = '\u{130}'; -- latin capital letter i with dot above
	['\xde'] = '\u{15e}'; -- latin capital letter s with cedilla
	['\xf0'] = '\u{11f}'; -- latin small letter g with breve
	['\xfd'] = '\u{131}'; -- latin small letter dotless i
	['\xfe'] = '\u{15f}'; -- latin small letter s with cedilla
}
