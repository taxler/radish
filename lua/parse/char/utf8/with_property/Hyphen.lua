
local m_utf8 = require 'parse.match.utf8'

return m_utf8 {
	S = '-\u{ad}\u{58a}\u{1806}\u{2010}\u{2011}\u{2e17}\u{30fb}\u{fe63}\u{ff0d}\u{ff65}';
}
