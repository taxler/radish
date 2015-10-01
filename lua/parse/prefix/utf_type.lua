
local m = require 'lpeg'
local re = require 're'

return re.compile([[

	result <- (from_first_char_peek / from_bom) {}

	from_first_char_peek <- (
		(%PEEK_ASCII -> 'utf-8')
		/ (%PEEK_UTF16LE_ASCII -> 'utf-16le')
		/ (%PEEK_UTF16BE_ASCII -> 'utf-16be')
		/ (%PEEK_UTF32LE_ASCII -> 'utf-32le')
		/ (%PEEK_UTF32BE_ASCII -> 'utf-32be')
	)

	from_bom <- (
		(%UTF8_BOM -> 'utf-8')
		/ (%UTF16LE_BOM -> 'utf-16le')
		/ (%UTF16BE_BOM -> 'utf-16be')
		/ (%UTF32LE_BOM -> 'utf-32le')
		/ (%UTF32BE_BOM -> 'utf-32be')
	)

]], {
	PEEK_ASCII         = #(require('parse.char.ascii7.printable') * -m.P'\0');
	PEEK_UTF16LE_ASCII = require 'parse.peek.printable_ascii7_as_utf16le';
	PEEK_UTF16BE_ASCII = require 'parse.peek.printable_ascii7_as_utf16be';
	PEEK_UTF32LE_ASCII = require 'parse.peek.printable_ascii7_as_utf32le';
	PEEK_UTF32BE_ASCII = require 'parse.peek.printable_ascii7_as_utf32be';

	UTF8_BOM    = require 'parse.match.utf8.bom';
	UTF16LE_BOM = require 'parse.match.utf16le.bom';
	UTF16BE_BOM = require 'parse.match.utf16be.bom';
	UTF32LE_BOM = require 'parse.match.utf32le.bom';
	UTF32BE_BOM = require 'parse.match.utf32be.bom';
})
