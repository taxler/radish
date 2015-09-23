-- Other, Surrogate
local m_utf8 = require "parse.match.utf8"

return m_utf8 {
	-- luajit parser won't accept surrogates
	--S = [[\u{d800}\u{db7f}\u{db80}\u{dbff}\u{dc00}\u{dfff}]];
}
