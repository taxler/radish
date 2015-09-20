
local iso8859_11 = require 'parse.substitution.charset.iso8859_11'

return iso8859_11 + {
	['\x80'] = '\u{20ac}'; -- euro sign
	['\x81'] = require 'parse.substitution.undefined_char';
	['\x82'] = require 'parse.substitution.undefined_char';
	['\x83'] = require 'parse.substitution.undefined_char';
	['\x84'] = require 'parse.substitution.undefined_char';
	['\x85'] = '\u{2026}'; -- horizontal ellipsis
	['\x86'] = require 'parse.substitution.undefined_char';
	['\x87'] = require 'parse.substitution.undefined_char';
	['\x88'] = require 'parse.substitution.undefined_char';
	['\x89'] = require 'parse.substitution.undefined_char';
	['\x8a'] = require 'parse.substitution.undefined_char';
	['\x8b'] = require 'parse.substitution.undefined_char';
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
	['\x98'] = require 'parse.substitution.undefined_char';
	['\x99'] = require 'parse.substitution.undefined_char';
	['\x9a'] = require 'parse.substitution.undefined_char';
	['\x9b'] = require 'parse.substitution.undefined_char';
	['\x9c'] = require 'parse.substitution.undefined_char';
	['\x9d'] = require 'parse.substitution.undefined_char';
	['\x9e'] = require 'parse.substitution.undefined_char';
	['\x9f'] = require 'parse.substitution.undefined_char';
}
