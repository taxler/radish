
local m_utf8 = require 'parse.match.utf8'

return m_utf8 {
	S = '\u{b7}\u{2d0}\u{2d1}\u{640}\u{7fa}\u{e46}\u{ec6}'
		.. '\u{180a}\u{1843}\u{1aa7}\u{1c36}\u{1c7b}\u{3005}\u{309d}\u{309e}\u{30fc}\u{30fe}'
		.. '\u{a015}\u{a60c}\u{a9cf}\u{a9e6}\u{aa70}\u{aadd}\u{aaf3}\u{aaf4}\u{ff70}'
		.. '\u{1135d}\u{16b42}\u{16b43}';
	R = {'\u{3031}\u{3035}', '\u{115c6}\u{115c8}'};
}
