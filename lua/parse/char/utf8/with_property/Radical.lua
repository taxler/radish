
local m_utf8 = require 'parse.match.utf8'

return m_utf8 {
	R = {'\u{2e80}\u{2e99}', '\u{2e9b}\u{2ef3}', '\u{2f00}\u{2fd5}'};
}
