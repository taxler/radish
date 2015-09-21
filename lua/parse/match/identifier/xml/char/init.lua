
local m = require 'lpeg'
local m_utf8 = require 'parse.match.utf8'

return m.R '09' + m.S'-.' + require 'parse.match.identifier.xml.char.first'
	+ m_utf8.P '\u{B7}' + m_utf8.R('\u{300}\u{36f}', '\u{203f}\u{2040}')
