
local m_utf8 = require 'parse.match.utf8'

return m_utf8 {
	S = '\u{19ba}\u{aab9}\u{aab5}\u{aab6}\u{aabb}\u{aabc}';
	R = {'\u{e40}\u{e44}', '\u{ec0}\u{ec4}', '\u{19b5}\u{19b7}'};
}
