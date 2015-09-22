
local m_utf8 = require 'parse.match.utf8'

return m_utf8 {
	S = [["']] .. '\u{ab}\u{bb}\u{2039}\u{203a}\u{2e42}\u{ff02}\u{ff07}\u{ff62}\u{ff63}';
	R = {'\u{2018}\u{201f}', '\u{300c}\u{300f}', '\u{301d}\u{301f}', '\u{fe41}\u{fe44}'};
}
