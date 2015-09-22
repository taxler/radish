
local m_utf8 = require 'parse.match.utf8'

return m_utf8 {
	S = ' \t\r\n\11\12\u{85}\u{200e}\u{200f}\u{2028}\u{2029}';
}
