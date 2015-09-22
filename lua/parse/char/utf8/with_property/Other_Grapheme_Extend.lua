
local m_utf8 = require 'parse.match.utf8'

return m_utf8 {
	S = '\u{9be}\u{9d7}\u{b3e}\u{b57}\u{bbe}\u{bd7}\u{cc2}\u{cd5}\u{cd6}\u{d3e}\u{d57}\u{dcf}\u{ddf}'
		.. '\u{200c}\u{200d}\u{302e}\u{302f}\u{ff9e}\u{ff9f}'
		.. '\u{1133e}\u{11357}\u{114b0}\u{114bd}\u{115af}\u{1d165}';
	R = '\u{1d16e}\u{1d172}';
}
