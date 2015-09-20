
-- the first character in the document should be a character in ASCII-7 range
--  (including linebreaks and tab, not including other control characters
--  or the null character) which should be guaranteed for various kinds
--  of documents e.g. XML, JSON, most programming language source code

-- in cases where the document may not start with an ASCII-7 character,
--  hopefully it's not too onerous to either add an extra newline or space
--  character or something at the beginning, or if all else fails, use the BOM
--  prefix character U+FEFF (which will be removed)

-- special case when the string is empty: successfully match the empty string

local m = require 'lpeg'
local re = require 're'

return re.compile([[

	converted <- first_char_ascii_doc / bom_doc / { !. }

	first_char_ascii_doc <- (
		(%PEEK_ASCII utf8_doc)
		/ (%PEEK_UTF16LE_ASCII utf16le_doc)
		/ (%PEEK_UTF16BE_ASCII utf16be_doc)
		/ (%PEEK_UTF32LE_ASCII utf32le_doc)
		/ (%PEEK_UTF32BE_ASCII utf32be_doc)
	)

	bom_doc <- (
		(%UTF8_BOM utf8_doc)
		/ (%UTF16LE_BOM utf16le_doc)
		/ (%UTF16BE_BOM utf16be_doc)
		/ (%UTF32LE_BOM utf32le_doc)
		/ (%UTF32BE_BOM utf32be_doc)
	)

	utf8_doc    <- { .* } !.
	utf16le_doc <- {~ %FROM_UTF16LE_CHAR* ~} !.
	utf16be_doc <- {~ %FROM_UTF16BE_CHAR* ~} !.
	utf32le_doc <- {~ %FROM_UTF32LE_CHAR* ~} !.
	utf32be_doc <- {~ %FROM_UTF32BE_CHAR* ~} !.

]], {
	UTF16LE_BOM = require 'parse.match.utf16le.bom';
	UTF16BE_BOM = require 'parse.match.utf16be.bom';
	UTF32LE_BOM = require 'parse.match.utf32le.bom';
	UTF32BE_BOM = require 'parse.match.utf32be.bom';
	UTF8_BOM    = require 'parse.match.utf8.bom';

	PEEK_UTF16LE_ASCII = require 'parse.peek.printable_ascii7_as_utf16le';
	PEEK_UTF16BE_ASCII = require 'parse.peek.printable_ascii7_as_utf16be';
	PEEK_UTF32LE_ASCII = require 'parse.peek.printable_ascii7_as_utf32le';
	PEEK_UTF32BE_ASCII = require 'parse.peek.printable_ascii7_as_utf32be';
	PEEK_ASCII         = #(require('parse.char.ascii7.printable') * -m.P'\0');

	FROM_UTF16LE_CHAR = require 'parse.convert.to_utf8.from_utf16le_char';
	FROM_UTF16BE_CHAR = require 'parse.convert.to_utf8.from_utf16be_char';
	FROM_UTF32LE_CHAR = require 'parse.convert.to_utf8.from_utf32le_char';
	FROM_UTF32BE_CHAR = require 'parse.convert.to_utf8.from_utf32be_char';
})
