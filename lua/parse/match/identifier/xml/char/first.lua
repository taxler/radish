
local m = require 'lpeg'
local m_utf8 = require 'parse.match.utf8'

return m.R('az', 'AZ', '__', '::') + m_utf8.R(
	'\u{C0}\u{D6}', '\u{D8}\u{F6}', '\u{F8}\u{2FF}',
	'\u{370}\u{37D}', '\u{37F}\u{1FFF}', '\u{200C}\u{200D}',
	'\u{2070}\u{218F}', '\u{2C00}\u{2FEF}', '\u{3001}\u{D7FF}',
	'\u{F900}\u{FDCF}', '\u{FDF0}\u{FFFD}', '\u{10000}\u{EFFFF}')
