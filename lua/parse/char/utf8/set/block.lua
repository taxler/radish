local make_set = require 'parse.char.utf8.make.set'

local function r(range)
	return make_set {R=range}
end

local blocks = {
	{'Basic Latin', r'\x00\x7f'};
	{'Latin-1 Supplement', r'\u{80}\u{FF}'};
	{'Latin Extended-A', r'\u{100}\u{17F}'};
	{'Latin Extended-B', r'\u{180}\u{24F}'};
	{'IPA Extensions', r'\u{250}\u{2AF}'};
	{'Spacing Modifier Letters', r'\u{2B0}\u{2FF}'};
	{'Combining Diacritical Marks', r'\u{300}\u{36F}'};
	{'Greek and Coptic', r'\u{370}\u{3FF}'};
	{'Cyrillic', r'\u{400}\u{4FF}'};
	{'Cyrillic Supplement', r'\u{500}\u{52F}'};
	{'Armenian', r'\u{530}\u{58F}'};
	{'Hebrew', r'\u{590}\u{5FF}'};
	{'Arabic', r'\u{600}\u{6FF}'};
	{'Syriac', r'\u{700}\u{74F}'};
	{'Arabic Supplement', r'\u{750}\u{77F}'};
	{'Thaana', r'\u{780}\u{7BF}'};
	{'NKo', r'\u{7C0}\u{7FF}'};
	{'Samaritan', r'\u{800}\u{83F}'};
	{'Mandaic', r'\u{840}\u{85F}'};
	{'Arabic Extended-A', r'\u{8A0}\u{8FF}'};
	{'Devanagari', r'\u{900}\u{97F}'};
	{'Bengali', r'\u{980}\u{9FF}'};
	{'Gurmukhi', r'\u{A00}\u{A7F}'};
	{'Gujarati', r'\u{A80}\u{AFF}'};
	{'Oriya', r'\u{B00}\u{B7F}'};
	{'Tamil', r'\u{B80}\u{BFF}'};
	{'Telugu', r'\u{C00}\u{C7F}'};
	{'Kannada', r'\u{C80}\u{CFF}'};
	{'Malayalam', r'\u{D00}\u{D7F}'};
	{'Sinhala', r'\u{D80}\u{DFF}'};
	{'Thai', r'\u{E00}\u{E7F}'};
	{'Lao', r'\u{E80}\u{EFF}'};
	{'Tibetan', r'\u{F00}\u{FFF}'};
	{'Myanmar', r'\u{1000}\u{109F}'};
	{'Georgian', r'\u{10A0}\u{10FF}'};
	{'Hangul Jamo', r'\u{1100}\u{11FF}'};
	{'Ethiopic', r'\u{1200}\u{137F}'};
	{'Ethiopic Supplement', r'\u{1380}\u{139F}'};
	{'Cherokee', r'\u{13A0}\u{13FF}'};
	{'Unified Canadian Aboriginal Syllabics', r'\u{1400}\u{167F}'};
	{'Ogham', r'\u{1680}\u{169F}'};
	{'Runic', r'\u{16A0}\u{16FF}'};
	{'Tagalog', r'\u{1700}\u{171F}'};
	{'Hanunoo', r'\u{1720}\u{173F}'};
	{'Buhid', r'\u{1740}\u{175F}'};
	{'Tagbanwa', r'\u{1760}\u{177F}'};
	{'Khmer', r'\u{1780}\u{17FF}'};
	{'Mongolian', r'\u{1800}\u{18AF}'};
	{'Unified Canadian Aboriginal Syllabics Extended', r'\u{18B0}\u{18FF}'};
	{'Limbu', r'\u{1900}\u{194F}'};
	{'Tai Le', r'\u{1950}\u{197F}'};
	{'New Tai Lue', r'\u{1980}\u{19DF}'};
	{'Khmer Symbols', r'\u{19E0}\u{19FF}'};
	{'Buginese', r'\u{1A00}\u{1A1F}'};
	{'Tai Tham', r'\u{1A20}\u{1AAF}'};
	{'Combining Diacritical Marks Extended', r'\u{1AB0}\u{1AFF}'};
	{'Balinese', r'\u{1B00}\u{1B7F}'};
	{'Sundanese', r'\u{1B80}\u{1BBF}'};
	{'Batak', r'\u{1BC0}\u{1BFF}'};
	{'Lepcha', r'\u{1C00}\u{1C4F}'};
	{'Ol Chiki', r'\u{1C50}\u{1C7F}'};
	{'Sundanese Supplement', r'\u{1CC0}\u{1CCF}'};
	{'Vedic Extensions', r'\u{1CD0}\u{1CFF}'};
	{'Phonetic Extensions', r'\u{1D00}\u{1D7F}'};
	{'Phonetic Extensions Supplement', r'\u{1D80}\u{1DBF}'};
	{'Combining Diacritical Marks Supplement', r'\u{1DC0}\u{1DFF}'};
	{'Latin Extended Additional', r'\u{1E00}\u{1EFF}'};
	{'Greek Extended', r'\u{1F00}\u{1FFF}'};
	{'General Punctuation', r'\u{2000}\u{206F}'};
	{'Superscripts and Subscripts', r'\u{2070}\u{209F}'};
	{'Currency Symbols', r'\u{20A0}\u{20CF}'};
	{'Combining Diacritical Marks for Symbols', r'\u{20D0}\u{20FF}'};
	{'Letterlike Symbols', r'\u{2100}\u{214F}'};
	{'Number Forms', r'\u{2150}\u{218F}'};
	{'Arrows', r'\u{2190}\u{21FF}'};
	{'Mathematical Operators', r'\u{2200}\u{22FF}'};
	{'Miscellaneous Technical', r'\u{2300}\u{23FF}'};
	{'Control Pictures', r'\u{2400}\u{243F}'};
	{'Optical Character Recognition', r'\u{2440}\u{245F}'};
	{'Enclosed Alphanumerics', r'\u{2460}\u{24FF}'};
	{'Box Drawing', r'\u{2500}\u{257F}'};
	{'Block Elements', r'\u{2580}\u{259F}'};
	{'Geometric Shapes', r'\u{25A0}\u{25FF}'};
	{'Miscellaneous Symbols', r'\u{2600}\u{26FF}'};
	{'Dingbats', r'\u{2700}\u{27BF}'};
	{'Miscellaneous Mathematical Symbols-A', r'\u{27C0}\u{27EF}'};
	{'Supplemental Arrows-A', r'\u{27F0}\u{27FF}'};
	{'Braille Patterns', r'\u{2800}\u{28FF}'};
	{'Supplemental Arrows-B', r'\u{2900}\u{297F}'};
	{'Miscellaneous Mathematical Symbols-B', r'\u{2980}\u{29FF}'};
	{'Supplemental Mathematical Operators', r'\u{2A00}\u{2AFF}'};
	{'Miscellaneous Symbols and Arrows', r'\u{2B00}\u{2BFF}'};
	{'Glagolitic', r'\u{2C00}\u{2C5F}'};
	{'Latin Extended-C', r'\u{2C60}\u{2C7F}'};
	{'Coptic', r'\u{2C80}\u{2CFF}'};
	{'Georgian Supplement', r'\u{2D00}\u{2D2F}'};
	{'Tifinagh', r'\u{2D30}\u{2D7F}'};
	{'Ethiopic Extended', r'\u{2D80}\u{2DDF}'};
	{'Cyrillic Extended-A', r'\u{2DE0}\u{2DFF}'};
	{'Supplemental Punctuation', r'\u{2E00}\u{2E7F}'};
	{'CJK Radicals Supplement', r'\u{2E80}\u{2EFF}'};
	{'Kangxi Radicals', r'\u{2F00}\u{2FDF}'};
	{'Ideographic Description Characters', r'\u{2FF0}\u{2FFF}'};
	{'CJK Symbols and Punctuation', r'\u{3000}\u{303F}'};
	{'Hiragana', r'\u{3040}\u{309F}'};
	{'Katakana', r'\u{30A0}\u{30FF}'};
	{'Bopomofo', r'\u{3100}\u{312F}'};
	{'Hangul Compatibility Jamo', r'\u{3130}\u{318F}'};
	{'Kanbun', r'\u{3190}\u{319F}'};
	{'Bopomofo Extended', r'\u{31A0}\u{31BF}'};
	{'CJK Strokes', r'\u{31C0}\u{31EF}'};
	{'Katakana Phonetic Extensions', r'\u{31F0}\u{31FF}'};
	{'Enclosed CJK Letters and Months', r'\u{3200}\u{32FF}'};
	{'CJK Compatibility', r'\u{3300}\u{33FF}'};
	{'CJK Unified Ideographs Extension A', r'\u{3400}\u{4DBF}'};
	{'Yijing Hexagram Symbols', r'\u{4DC0}\u{4DFF}'};
	{'CJK Unified Ideographs', r'\u{4E00}\u{9FFF}'};
	{'Yi Syllables', r'\u{A000}\u{A48F}'};
	{'Yi Radicals', r'\u{A490}\u{A4CF}'};
	{'Lisu', r'\u{A4D0}\u{A4FF}'};
	{'Vai', r'\u{A500}\u{A63F}'};
	{'Cyrillic Extended-B', r'\u{A640}\u{A69F}'};
	{'Bamum', r'\u{A6A0}\u{A6FF}'};
	{'Modifier Tone Letters', r'\u{A700}\u{A71F}'};
	{'Latin Extended-D', r'\u{A720}\u{A7FF}'};
	{'Syloti Nagri', r'\u{A800}\u{A82F}'};
	{'Common Indic Number Forms', r'\u{A830}\u{A83F}'};
	{'Phags-pa', r'\u{A840}\u{A87F}'};
	{'Saurashtra', r'\u{A880}\u{A8DF}'};
	{'Devanagari Extended', r'\u{A8E0}\u{A8FF}'};
	{'Kayah Li', r'\u{A900}\u{A92F}'};
	{'Rejang', r'\u{A930}\u{A95F}'};
	{'Hangul Jamo Extended-A', r'\u{A960}\u{A97F}'};
	{'Javanese', r'\u{A980}\u{A9DF}'};
	{'Myanmar Extended-B', r'\u{A9E0}\u{A9FF}'};
	{'Cham', r'\u{AA00}\u{AA5F}'};
	{'Myanmar Extended-A', r'\u{AA60}\u{AA7F}'};
	{'Tai Viet', r'\u{AA80}\u{AADF}'};
	{'Meetei Mayek Extensions', r'\u{AAE0}\u{AAFF}'};
	{'Ethiopic Extended-A', r'\u{AB00}\u{AB2F}'};
	{'Latin Extended-E', r'\u{AB30}\u{AB6F}'};
	{'Cherokee Supplement', r'\u{AB70}\u{ABBF}'};
	{'Meetei Mayek', r'\u{ABC0}\u{ABFF}'};
	{'Hangul Syllables', r'\u{AC00}\u{D7AF}'};
	{'Hangul Jamo Extended-B', r'\u{D7B0}\u{D7FF}'};
	--{'High Surrogates', r'\u{D800}\u{DB7F}'};
	--{'High Private Use Surrogates', r'\u{DB80}\u{DBFF}'};
	--{'Low Surrogates', r'\u{DC00}\u{DFFF}'};
	{'Private Use Area', r'\u{E000}\u{F8FF}'};
	{'CJK Compatibility Ideographs', r'\u{F900}\u{FAFF}'};
	{'Alphabetic Presentation Forms', r'\u{FB00}\u{FB4F}'};
	{'Arabic Presentation Forms-A', r'\u{FB50}\u{FDFF}'};
	{'Variation Selectors', r'\u{FE00}\u{FE0F}'};
	{'Vertical Forms', r'\u{FE10}\u{FE1F}'};
	{'Combining Half Marks', r'\u{FE20}\u{FE2F}'};
	{'CJK Compatibility Forms', r'\u{FE30}\u{FE4F}'};
	{'Small Form Variants', r'\u{FE50}\u{FE6F}'};
	{'Arabic Presentation Forms-B', r'\u{FE70}\u{FEFF}'};
	{'Halfwidth and Fullwidth Forms', r'\u{FF00}\u{FFEF}'};
	{'Specials', r'\u{FFF0}\u{FFFF}'};
	{'Linear B Syllabary', r'\u{10000}\u{1007F}'};
	{'Linear B Ideograms', r'\u{10080}\u{100FF}'};
	{'Aegean Numbers', r'\u{10100}\u{1013F}'};
	{'Ancient Greek Numbers', r'\u{10140}\u{1018F}'};
	{'Ancient Symbols', r'\u{10190}\u{101CF}'};
	{'Phaistos Disc', r'\u{101D0}\u{101FF}'};
	{'Lycian', r'\u{10280}\u{1029F}'};
	{'Carian', r'\u{102A0}\u{102DF}'};
	{'Coptic Epact Numbers', r'\u{102E0}\u{102FF}'};
	{'Old Italic', r'\u{10300}\u{1032F}'};
	{'Gothic', r'\u{10330}\u{1034F}'};
	{'Old Permic', r'\u{10350}\u{1037F}'};
	{'Ugaritic', r'\u{10380}\u{1039F}'};
	{'Old Persian', r'\u{103A0}\u{103DF}'};
	{'Deseret', r'\u{10400}\u{1044F}'};
	{'Shavian', r'\u{10450}\u{1047F}'};
	{'Osmanya', r'\u{10480}\u{104AF}'};
	{'Elbasan', r'\u{10500}\u{1052F}'};
	{'Caucasian Albanian', r'\u{10530}\u{1056F}'};
	{'Linear A', r'\u{10600}\u{1077F}'};
	{'Cypriot Syllabary', r'\u{10800}\u{1083F}'};
	{'Imperial Aramaic', r'\u{10840}\u{1085F}'};
	{'Palmyrene', r'\u{10860}\u{1087F}'};
	{'Nabataean', r'\u{10880}\u{108AF}'};
	{'Hatran', r'\u{108E0}\u{108FF}'};
	{'Phoenician', r'\u{10900}\u{1091F}'};
	{'Lydian', r'\u{10920}\u{1093F}'};
	{'Meroitic Hieroglyphs', r'\u{10980}\u{1099F}'};
	{'Meroitic Cursive', r'\u{109A0}\u{109FF}'};
	{'Kharoshthi', r'\u{10A00}\u{10A5F}'};
	{'Old South Arabian', r'\u{10A60}\u{10A7F}'};
	{'Old North Arabian', r'\u{10A80}\u{10A9F}'};
	{'Manichaean', r'\u{10AC0}\u{10AFF}'};
	{'Avestan', r'\u{10B00}\u{10B3F}'};
	{'Inscriptional Parthian', r'\u{10B40}\u{10B5F}'};
	{'Inscriptional Pahlavi', r'\u{10B60}\u{10B7F}'};
	{'Psalter Pahlavi', r'\u{10B80}\u{10BAF}'};
	{'Old Turkic', r'\u{10C00}\u{10C4F}'};
	{'Old Hungarian', r'\u{10C80}\u{10CFF}'};
	{'Rumi Numeral Symbols', r'\u{10E60}\u{10E7F}'};
	{'Brahmi', r'\u{11000}\u{1107F}'};
	{'Kaithi', r'\u{11080}\u{110CF}'};
	{'Sora Sompeng', r'\u{110D0}\u{110FF}'};
	{'Chakma', r'\u{11100}\u{1114F}'};
	{'Mahajani', r'\u{11150}\u{1117F}'};
	{'Sharada', r'\u{11180}\u{111DF}'};
	{'Sinhala Archaic Numbers', r'\u{111E0}\u{111FF}'};
	{'Khojki', r'\u{11200}\u{1124F}'};
	{'Multani', r'\u{11280}\u{112AF}'};
	{'Khudawadi', r'\u{112B0}\u{112FF}'};
	{'Grantha', r'\u{11300}\u{1137F}'};
	{'Tirhuta', r'\u{11480}\u{114DF}'};
	{'Siddham', r'\u{11580}\u{115FF}'};
	{'Modi', r'\u{11600}\u{1165F}'};
	{'Takri', r'\u{11680}\u{116CF}'};
	{'Ahom', r'\u{11700}\u{1173F}'};
	{'Warang Citi', r'\u{118A0}\u{118FF}'};
	{'Pau Cin Hau', r'\u{11AC0}\u{11AFF}'};
	{'Cuneiform', r'\u{12000}\u{123FF}'};
	{'Cuneiform Numbers and Punctuation', r'\u{12400}\u{1247F}'};
	{'Early Dynastic Cuneiform', r'\u{12480}\u{1254F}'};
	{'Egyptian Hieroglyphs', r'\u{13000}\u{1342F}'};
	{'Anatolian Hieroglyphs', r'\u{14400}\u{1467F}'};
	{'Bamum Supplement', r'\u{16800}\u{16A3F}'};
	{'Mro', r'\u{16A40}\u{16A6F}'};
	{'Bassa Vah', r'\u{16AD0}\u{16AFF}'};
	{'Pahawh Hmong', r'\u{16B00}\u{16B8F}'};
	{'Miao', r'\u{16F00}\u{16F9F}'};
	{'Kana Supplement', r'\u{1B000}\u{1B0FF}'};
	{'Duployan', r'\u{1BC00}\u{1BC9F}'};
	{'Shorthand Format Controls', r'\u{1BCA0}\u{1BCAF}'};
	{'Byzantine Musical Symbols', r'\u{1D000}\u{1D0FF}'};
	{'Musical Symbols', r'\u{1D100}\u{1D1FF}'};
	{'Ancient Greek Musical Notation', r'\u{1D200}\u{1D24F}'};
	{'Tai Xuan Jing Symbols', r'\u{1D300}\u{1D35F}'};
	{'Counting Rod Numerals', r'\u{1D360}\u{1D37F}'};
	{'Mathematical Alphanumeric Symbols', r'\u{1D400}\u{1D7FF}'};
	{'Sutton SignWriting', r'\u{1D800}\u{1DAAF}'};
	{'Mende Kikakui', r'\u{1E800}\u{1E8DF}'};
	{'Arabic Mathematical Alphabetic Symbols', r'\u{1EE00}\u{1EEFF}'};
	{'Mahjong Tiles', r'\u{1F000}\u{1F02F}'};
	{'Domino Tiles', r'\u{1F030}\u{1F09F}'};
	{'Playing Cards', r'\u{1F0A0}\u{1F0FF}'};
	{'Enclosed Alphanumeric Supplement', r'\u{1F100}\u{1F1FF}'};
	{'Enclosed Ideographic Supplement', r'\u{1F200}\u{1F2FF}'};
	{'Miscellaneous Symbols and Pictographs', r'\u{1F300}\u{1F5FF}'};
	{'Emoticons', r'\u{1F600}\u{1F64F}'};
	{'Ornamental Dingbats', r'\u{1F650}\u{1F67F}'};
	{'Transport and Map Symbols', r'\u{1F680}\u{1F6FF}'};
	{'Alchemical Symbols', r'\u{1F700}\u{1F77F}'};
	{'Geometric Shapes Extended', r'\u{1F780}\u{1F7FF}'};
	{'Supplemental Arrows-C', r'\u{1F800}\u{1F8FF}'};
	{'Supplemental Symbols and Pictographs', r'\u{1F900}\u{1F9FF}'};
	{'CJK Unified Ideographs Extension B', r'\u{20000}\u{2A6DF}'};
	{'CJK Unified Ideographs Extension C', r'\u{2A700}\u{2B73F}'};
	{'CJK Unified Ideographs Extension D', r'\u{2B740}\u{2B81F}'};
	{'CJK Unified Ideographs Extension E', r'\u{2B820}\u{2CEAF}'};
	{'CJK Compatibility Ideographs Supplement', r'\u{2F800}\u{2FA1F}'};
	{'Tags', r'\u{E0000}\u{E007F}'};
	{'Variation Selectors Supplement', r'\u{E0100}\u{E01EF}'};
	{'Supplementary Private Use Area-A', r'\u{F0000}\u{FFFFF}'};
	{'Supplementary Private Use Area-B', r'\u{100000}\u{10FFFF}'};	
}

local function make_no_block()
	local no_block = make_set()
	for i, block in ipairs(blocks) do
		no_block = no_block - block[2]
	end
	return no_block
end

local function normalize(name)
	return name:lower():gsub('[%- _]', '')
end

for i = 1, #blocks do
	local block = blocks[i]
	local name = block[1]
	local set = block[2]
	blocks[name] = set
	blocks[normalize(name)] = set
end

setmetatable(blocks, {
	__index = function(self, k)
		if type(k) ~= 'string' then
			return nil
		end
		local normalized = normalize(k)
		if normalized == 'noblock' then
			local no_block = make_no_block()
			self[k] = no_block
			self[normalized] = no_block
			return no_block
		end
		if normalized == k then
			return nil
		end
		local v = self[normalized]
		if v ~= nil then
			self[k] = v
		end
		return v
	end;
})

return blocks
