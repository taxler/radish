
local m_utf8 = require 'parse.match.utf8'

return m_utf8 {
	S = '\u{2ff0}\u{2ff1}';
	R = '\u{2ff4}\u{2ffb}';
}
