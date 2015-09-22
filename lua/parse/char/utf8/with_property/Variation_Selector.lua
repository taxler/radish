
local m_utf8 = require 'parse.match.utf8'

return m_utf8 {
	R = {'\u{180b}\u{180d}', '\u{fe00}\u{fe0f}', '\u{e0100}\u{e01ef}'};
}
