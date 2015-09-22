
local m_utf8 = require 'parse.match.utf8'

return m_utf8 {
	S = '\u{149}\u{673}\u{f77}\u{f79}\u{17a3}\u{17a4}\u{2329}\u{232a}\u{e0001}\u{e007f}';
	R = '\u{206a}\u{206f}';
}
