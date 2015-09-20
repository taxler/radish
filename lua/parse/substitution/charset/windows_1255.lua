
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
	['\x8a'] = require 'parse.substitution.undefined_char';
	['\x8b'] = '\u{2039}'; -- single left-pointing angle quotation mark
	['\x8c'] = require 'parse.substitution.undefined_char';
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
	['\x9a'] = require 'parse.substitution.undefined_char';
	['\x9b'] = '\u{203a}'; -- single right-pointing angle quotation mark
	['\x9c'] = require 'parse.substitution.undefined_char';
	['\x9d'] = require 'parse.substitution.undefined_char';
	['\x9e'] = require 'parse.substitution.undefined_char';
	['\x9f'] = require 'parse.substitution.undefined_char';
	['\xa4'] = '\u{20aa}'; -- new sheqel sign
	['\xaa'] = '\u{d7}'; -- multiplication sign
	['\xba'] = '\u{f7}'; -- division sign
	['\xc0'] = '\u{5b0}'; -- hebrew point sheva
	['\xc1'] = '\u{5b1}'; -- hebrew point hataf segol
	['\xc2'] = '\u{5b2}'; -- hebrew point hataf patah
	['\xc3'] = '\u{5b3}'; -- hebrew point hataf qamats
	['\xc4'] = '\u{5b4}'; -- hebrew point hiriq
	['\xc5'] = '\u{5b5}'; -- hebrew point tsere
	['\xc6'] = '\u{5b6}'; -- hebrew point segol
	['\xc7'] = '\u{5b7}'; -- hebrew point patah
	['\xc8'] = '\u{5b8}'; -- hebrew point qamats
	['\xc9'] = '\u{5b9}'; -- hebrew point holam
	['\xca'] = require 'parse.substitution.undefined_char';
	['\xcb'] = '\u{5bb}'; -- hebrew point qubuts
	['\xcc'] = '\u{5bc}'; -- hebrew point dagesh or mapiq
	['\xcd'] = '\u{5bd}'; -- hebrew point meteg
	['\xce'] = '\u{5be}'; -- hebrew punctuation maqaf
	['\xcf'] = '\u{5bf}'; -- hebrew point rafe
	['\xd0'] = '\u{5c0}'; -- hebrew punctuation paseq
	['\xd1'] = '\u{5c1}'; -- hebrew point shin dot
	['\xd2'] = '\u{5c2}'; -- hebrew point sin dot
	['\xd3'] = '\u{5c3}'; -- hebrew punctuation sof pasuq
	['\xd4'] = '\u{5f0}'; -- hebrew ligature yiddish double vav
	['\xd5'] = '\u{5f1}'; -- hebrew ligature yiddish vav yod
	['\xd6'] = '\u{5f2}'; -- hebrew ligature yiddish double yod
	['\xd7'] = '\u{5f3}'; -- hebrew punctuation geresh
	['\xd8'] = '\u{5f4}'; -- hebrew punctuation gershayim
	['\xd9'] = require 'parse.substitution.undefined_char';
	['\xda'] = require 'parse.substitution.undefined_char';
	['\xdb'] = require 'parse.substitution.undefined_char';
	['\xdc'] = require 'parse.substitution.undefined_char';
	['\xdd'] = require 'parse.substitution.undefined_char';
	['\xde'] = require 'parse.substitution.undefined_char';
	['\xdf'] = require 'parse.substitution.undefined_char';
	['\xe0'] = '\u{5d0}'; -- hebrew letter alef
	['\xe1'] = '\u{5d1}'; -- hebrew letter bet
	['\xe2'] = '\u{5d2}'; -- hebrew letter gimel
	['\xe3'] = '\u{5d3}'; -- hebrew letter dalet
	['\xe4'] = '\u{5d4}'; -- hebrew letter he
	['\xe5'] = '\u{5d5}'; -- hebrew letter vav
	['\xe6'] = '\u{5d6}'; -- hebrew letter zayin
	['\xe7'] = '\u{5d7}'; -- hebrew letter het
	['\xe8'] = '\u{5d8}'; -- hebrew letter tet
	['\xe9'] = '\u{5d9}'; -- hebrew letter yod
	['\xea'] = '\u{5da}'; -- hebrew letter final kaf
	['\xeb'] = '\u{5db}'; -- hebrew letter kaf
	['\xec'] = '\u{5dc}'; -- hebrew letter lamed
	['\xed'] = '\u{5dd}'; -- hebrew letter final mem
	['\xee'] = '\u{5de}'; -- hebrew letter mem
	['\xef'] = '\u{5df}'; -- hebrew letter final nun
	['\xf0'] = '\u{5e0}'; -- hebrew letter nun
	['\xf1'] = '\u{5e1}'; -- hebrew letter samekh
	['\xf2'] = '\u{5e2}'; -- hebrew letter ayin
	['\xf3'] = '\u{5e3}'; -- hebrew letter final pe
	['\xf4'] = '\u{5e4}'; -- hebrew letter pe
	['\xf5'] = '\u{5e5}'; -- hebrew letter final tsadi
	['\xf6'] = '\u{5e6}'; -- hebrew letter tsadi
	['\xf7'] = '\u{5e7}'; -- hebrew letter qof
	['\xf8'] = '\u{5e8}'; -- hebrew letter resh
	['\xf9'] = '\u{5e9}'; -- hebrew letter shin
	['\xfa'] = '\u{5ea}'; -- hebrew letter tav
	['\xfb'] = require 'parse.substitution.undefined_char';
	['\xfc'] = require 'parse.substitution.undefined_char';
	['\xfd'] = '\u{200e}'; -- left-to-right mark
	['\xfe'] = '\u{200f}'; -- right-to-left mark
	['\xff'] = require 'parse.substitution.undefined_char';
}
