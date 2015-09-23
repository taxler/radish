-- Other, Control
local m_utf8 = require "parse.match.utf8"

return m_utf8 {
	R = {"\x00\x1F","\u{7f}\u{9f}"};
}
