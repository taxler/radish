
local m_utf8 = require 'parse.match.utf8'

return m_utf8 {
	S = '\u{b7}\u{387}\u{19da}';
	R = '\u{1369}\u{1371}';
}
