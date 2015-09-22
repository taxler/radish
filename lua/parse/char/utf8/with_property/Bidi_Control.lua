
local m_utf8 = require 'parse.match.utf8'

return m_utf8 {
	S = '\u{61c}';
	R = {'\u{200e}\u{200f}', '\u{202a}\u{202e}'};
}
