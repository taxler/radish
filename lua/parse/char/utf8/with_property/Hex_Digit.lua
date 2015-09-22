
local m_utf8 = require 'parse.match.utf8'

return m_utf8 {
	R = {
		'09', 'af', 'AF';
		-- fullwidth
		'\u{ff10}\u{ff19}', '\u{ff21}\u{ff26}', '\u{ff41}\u{ff46}';
	};
}
