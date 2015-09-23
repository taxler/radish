-- Punctuation, Close
local m_utf8 = require "parse.match.utf8"

return m_utf8 {
	S = ')]}'
		.. '\u{f3b}\u{f3d}'
		.. '\u{169c}\u{2046}\u{207e}\u{208e}\u{2309}\u{230b}\u{232a}\u{2769}\u{276b}\u{276d}\u{276f}\u{2771}'
		.. '\u{2773}\u{2775}\u{27c6}\u{27e7}\u{27e9}\u{27eb}\u{27ed}\u{27ef}\u{2984}\u{2986}\u{2988}\u{298a}'
		.. '\u{298c}\u{298e}\u{2990}\u{2992}\u{2994}\u{2996}\u{2998}\u{29d9}\u{29db}\u{29fd}\u{2e23}\u{2e25}'
		.. '\u{2e27}\u{2e29}\u{3009}\u{300b}\u{300d}\u{300f}\u{3011}\u{3015}\u{3017}\u{3019}\u{301b}\u{301e}'
		.. '\u{301f}\u{fd3e}\u{fe18}\u{fe36}\u{fe38}\u{fe3a}\u{fe3c}\u{fe3e}\u{fe40}\u{fe42}\u{fe44}\u{fe48}'
		.. '\u{fe5a}\u{fe5c}\u{fe5e}\u{ff09}\u{ff3d}\u{ff5d}\u{ff60}\u{ff63}';
}

