
local byte = require 'parse.substitution.charset.byte'

return byte + {
	['\xa1'] = '\u{401}'; -- cyrillic capital letter io
	['\xa2'] = '\u{402}'; -- cyrillic capital letter dje
	['\xa3'] = '\u{403}'; -- cyrillic capital letter gje
	['\xa4'] = '\u{404}'; -- cyrillic capital letter ukrainian ie
	['\xa5'] = '\u{405}'; -- cyrillic capital letter dze
	['\xa6'] = '\u{406}'; -- cyrillic capital letter byelorussian-ukrainian i
	['\xa7'] = '\u{407}'; -- cyrillic capital letter yi
	['\xa8'] = '\u{408}'; -- cyrillic capital letter je
	['\xa9'] = '\u{409}'; -- cyrillic capital letter lje
	['\xaa'] = '\u{40a}'; -- cyrillic capital letter nje
	['\xab'] = '\u{40b}'; -- cyrillic capital letter tshe
	['\xac'] = '\u{40c}'; -- cyrillic capital letter kje
	['\xae'] = '\u{40e}'; -- cyrillic capital letter short u
	['\xaf'] = '\u{40f}'; -- cyrillic capital letter dzhe
	['\xb0'] = '\u{410}'; -- cyrillic capital letter a
	['\xb1'] = '\u{411}'; -- cyrillic capital letter be
	['\xb2'] = '\u{412}'; -- cyrillic capital letter ve
	['\xb3'] = '\u{413}'; -- cyrillic capital letter ghe
	['\xb4'] = '\u{414}'; -- cyrillic capital letter de
	['\xb5'] = '\u{415}'; -- cyrillic capital letter ie
	['\xb6'] = '\u{416}'; -- cyrillic capital letter zhe
	['\xb7'] = '\u{417}'; -- cyrillic capital letter ze
	['\xb8'] = '\u{418}'; -- cyrillic capital letter i
	['\xb9'] = '\u{419}'; -- cyrillic capital letter short i
	['\xba'] = '\u{41a}'; -- cyrillic capital letter ka
	['\xbb'] = '\u{41b}'; -- cyrillic capital letter el
	['\xbc'] = '\u{41c}'; -- cyrillic capital letter em
	['\xbd'] = '\u{41d}'; -- cyrillic capital letter en
	['\xbe'] = '\u{41e}'; -- cyrillic capital letter o
	['\xbf'] = '\u{41f}'; -- cyrillic capital letter pe
	['\xc0'] = '\u{420}'; -- cyrillic capital letter er
	['\xc1'] = '\u{421}'; -- cyrillic capital letter es
	['\xc2'] = '\u{422}'; -- cyrillic capital letter te
	['\xc3'] = '\u{423}'; -- cyrillic capital letter u
	['\xc4'] = '\u{424}'; -- cyrillic capital letter ef
	['\xc5'] = '\u{425}'; -- cyrillic capital letter ha
	['\xc6'] = '\u{426}'; -- cyrillic capital letter tse
	['\xc7'] = '\u{427}'; -- cyrillic capital letter che
	['\xc8'] = '\u{428}'; -- cyrillic capital letter sha
	['\xc9'] = '\u{429}'; -- cyrillic capital letter shcha
	['\xca'] = '\u{42a}'; -- cyrillic capital letter hard sign
	['\xcb'] = '\u{42b}'; -- cyrillic capital letter yeru
	['\xcc'] = '\u{42c}'; -- cyrillic capital letter soft sign
	['\xcd'] = '\u{42d}'; -- cyrillic capital letter e
	['\xce'] = '\u{42e}'; -- cyrillic capital letter yu
	['\xcf'] = '\u{42f}'; -- cyrillic capital letter ya
	['\xd0'] = '\u{430}'; -- cyrillic small letter a
	['\xd1'] = '\u{431}'; -- cyrillic small letter be
	['\xd2'] = '\u{432}'; -- cyrillic small letter ve
	['\xd3'] = '\u{433}'; -- cyrillic small letter ghe
	['\xd4'] = '\u{434}'; -- cyrillic small letter de
	['\xd5'] = '\u{435}'; -- cyrillic small letter ie
	['\xd6'] = '\u{436}'; -- cyrillic small letter zhe
	['\xd7'] = '\u{437}'; -- cyrillic small letter ze
	['\xd8'] = '\u{438}'; -- cyrillic small letter i
	['\xd9'] = '\u{439}'; -- cyrillic small letter short i
	['\xda'] = '\u{43a}'; -- cyrillic small letter ka
	['\xdb'] = '\u{43b}'; -- cyrillic small letter el
	['\xdc'] = '\u{43c}'; -- cyrillic small letter em
	['\xdd'] = '\u{43d}'; -- cyrillic small letter en
	['\xde'] = '\u{43e}'; -- cyrillic small letter o
	['\xdf'] = '\u{43f}'; -- cyrillic small letter pe
	['\xe0'] = '\u{440}'; -- cyrillic small letter er
	['\xe1'] = '\u{441}'; -- cyrillic small letter es
	['\xe2'] = '\u{442}'; -- cyrillic small letter te
	['\xe3'] = '\u{443}'; -- cyrillic small letter u
	['\xe4'] = '\u{444}'; -- cyrillic small letter ef
	['\xe5'] = '\u{445}'; -- cyrillic small letter ha
	['\xe6'] = '\u{446}'; -- cyrillic small letter tse
	['\xe7'] = '\u{447}'; -- cyrillic small letter che
	['\xe8'] = '\u{448}'; -- cyrillic small letter sha
	['\xe9'] = '\u{449}'; -- cyrillic small letter shcha
	['\xea'] = '\u{44a}'; -- cyrillic small letter hard sign
	['\xeb'] = '\u{44b}'; -- cyrillic small letter yeru
	['\xec'] = '\u{44c}'; -- cyrillic small letter soft sign
	['\xed'] = '\u{44d}'; -- cyrillic small letter e
	['\xee'] = '\u{44e}'; -- cyrillic small letter yu
	['\xef'] = '\u{44f}'; -- cyrillic small letter ya
	['\xf0'] = '\u{2116}'; -- numero sign
	['\xf1'] = '\u{451}'; -- cyrillic small letter io
	['\xf2'] = '\u{452}'; -- cyrillic small letter dje
	['\xf3'] = '\u{453}'; -- cyrillic small letter gje
	['\xf4'] = '\u{454}'; -- cyrillic small letter ukrainian ie
	['\xf5'] = '\u{455}'; -- cyrillic small letter dze
	['\xf6'] = '\u{456}'; -- cyrillic small letter byelorussian-ukrainian i
	['\xf7'] = '\u{457}'; -- cyrillic small letter yi
	['\xf8'] = '\u{458}'; -- cyrillic small letter je
	['\xf9'] = '\u{459}'; -- cyrillic small letter lje
	['\xfa'] = '\u{45a}'; -- cyrillic small letter nje
	['\xfb'] = '\u{45b}'; -- cyrillic small letter tshe
	['\xfc'] = '\u{45c}'; -- cyrillic small letter kje
	['\xfd'] = '\u{a7}'; -- section sign
	['\xfe'] = '\u{45e}'; -- cyrillic small letter short u
	['\xff'] = '\u{45f}'; -- cyrillic small letter dzhe
}
