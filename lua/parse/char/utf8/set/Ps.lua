-- Punctuation, Open
local make_set = require 'parse.char.utf8.make.set'

return make_set {
	S = '([{'
		.. '\u{f3a}\u{f3c}'
		.. '\u{169b}\u{201a}\u{201e}\u{2045}\u{207d}\u{208d}\u{2308}\u{230a}\u{2329}\u{2768}\u{276a}'
		.. '\u{276c}\u{276e}\u{2770}\u{2772}\u{2774}\u{27c5}\u{27e6}\u{27e8}\u{27ea}\u{27ec}\u{27ee}'
		.. '\u{2983}\u{2985}\u{2987}\u{2989}\u{298b}\u{298d}\u{298f}\u{2991}\u{2993}\u{2995}\u{2997}'
		.. '\u{29d8}\u{29da}\u{29fc}\u{2e22}\u{2e24}\u{2e26}\u{2e28}\u{2e42}\u{3008}\u{300a}\u{300c}'
		.. '\u{300e}\u{3010}\u{3014}\u{3016}\u{3018}\u{301a}\u{301d}\u{fd3f}\u{fe17}\u{fe35}\u{fe37}'
		.. '\u{fe39}\u{fe3b}\u{fe3d}\u{fe3f}\u{fe41}\u{fe43}\u{fe47}\u{fe59}\u{fe5b}\u{fe5d}\u{ff08}'
		.. '\u{ff3b}\u{ff5b}\u{ff5f}\u{ff62}';
}
