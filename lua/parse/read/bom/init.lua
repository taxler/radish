
local m = require 'lpeg'

-- the "byte order" mark is a bit of a misnomer.
-- it is just as good for differentiating width-encodings from each
-- other (e.g. to tell a utf-16 stream from a utf-32 one).

return (require 'parse.match.utf8.bom' / 'utf8')
+ (
    m.P'\xFF\xFE'
    * (
    	(m.P'\x00\x00' / 'utf32le')
    	+ (m.P'' / 'utf16le')
    )
)
+ (require 'parse.match.utf16be.bom' / 'utf16be')
+ (require 'parse.match.utf32be.bom' / 'utf32be')
