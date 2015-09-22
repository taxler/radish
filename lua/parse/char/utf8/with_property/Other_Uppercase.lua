
local m_utf8 = require 'parse.match.utf8'

return m_utf8 {
	R = {
		'\u{2160}\u{216f}', '\u{24b6}\u{24cf}',
		'\u{1f130}\u{1f149}', '\u{1f150}\u{1f169}', '\u{1f170}\u{1f189}'
	};
}
