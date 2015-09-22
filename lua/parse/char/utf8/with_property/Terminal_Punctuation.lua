
local m_utf8 = require 'parse.match.utf8'

return m_utf8 {
	S = '!,.:;?\u{37e}\u{387}\u{589}\u{5c3}\u{60c}\u{61b}\u{61f}\u{6d4}\u{70c}\u{7f8}\u{7f9}'
		.. '\u{85e}\u{964}\u{965}\u{e5a}\u{e5b}\u{f08}\u{104a}\u{104b}\u{166d}\u{166e}'
		.. '\u{1735}\u{1736}\u{17da}\u{1808}\u{1809}\u{1944}\u{1945}\u{1B5A}\u{1B5B}\u{1C7E}\u{1C7F}'
		.. '\u{203C}\u{203D}\u{2E2E}\u{2E3C}\u{2E41}\u{3001}\u{3002}\u{A4FE}\u{A4FF}\u{A876}\u{A877}'
		.. '\u{A8CE}\u{A8CF}\u{A92F}\u{AADF}\u{AAF0}\u{AAF1}\u{ABEB}\u{FF01}\u{FF0C}\u{FF0E}\u{FF1A}\u{FF1B}'
		.. '\u{FF1F}\u{FF61}\u{FF64}\u{1039F}\u{103D0}\u{10857}\u{1091F}\u{10A56}\u{10A57}\u{111C5}\u{111C6}'
		.. '\u{111CD}\u{111DE}\u{111DF}\u{112A9}\u{11641}\u{11642}\u{16A6E}\u{16A6F}\u{16AF5}\u{16B44}\u{1BC9F}';
	R = {
		'\u{700}\u{70a}', '\u{830}\u{83e}', '\u{f0d}\u{f12}', '\u{1361}\u{1368}', '\u{16eb}\u{16ed}',
		'\u{17d4}\u{17d6}', '\u{1802}\u{1805}', '\u{1aa8}\u{1aab}', '\u{1B5D}\u{1B5F}', '\u{1C3B}\u{1C3F}',
		'\u{2047}\u{2049}', '\u{A60D}\u{A60F}', '\u{A6F3}\u{A6F7}', '\u{A9C7}\u{A9C9}', '\u{AA5D}\u{AA5F}';
		'\u{FE50}\u{FE52}', '\u{FE54}\u{FE57}', '\u{10AF0}\u{10AF5}', '\u{10B3A}\u{10B3F}', '\u{10B99}\u{10B9C}';
		'\u{11047}\u{1104D}', '\u{110BE}\u{110C1}', '\u{11141}\u{11143}', '\u{11238}\u{1123C}', '\u{115C2}\u{115C5}'
		'\u{115C9}\u{115D7}', '\u{1173C}\u{1173E}', '\u{12470}\u{12474}', '\u{16B37}\u{16B39}', '\u{1DA87}\u{1DA8A}';
	};
}
