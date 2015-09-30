
local lib = {}

local aliases = {
	C = 'Other';
		Cc = 'Other.Control';
		Cf = 'Other.Format';
		Cs = 'Other.Surrogate';
		Co = 'Other.Private_Use';
	L = 'Letter';
		Ll = 'Letter.Lowercase';
		Lu = 'Letter.Uppercase';
		Lt = 'Letter.Titlecase';
		Lo = 'Letter.Other';
		Lm = 'Letter.Modifier';
	M = 'Mark';
		Mc = 'Mark.Spacing_Combining';
		Me = 'Mark.Enclosing';
		Mn = 'Mark.Nonspacing';
	N = 'Number';
		Nd = 'Number.Decimal_Digit';
		Nl = 'Number.Letter';
		No = 'Number.Other';
	P = 'Punctuation';
		Pc = 'Punctuation.Connector';
		Pd = 'Punctuation.Dash';
		Pe = 'Punctuation.Close';
		Pf = 'Punctuation.Final_Quote';
		Pi = 'Punctuation.Initial_Quote';
		Po = 'Punctuation.Other';
		Ps = 'Punctuation.Open';
	S = 'Symbol';
		Sc = 'Symbol.Currency';
		Sk = 'Symbol.Modifier';
		Sm = 'Symbol.Math';
		So = 'Symbol.Other';
	Z = 'Separator';
		Zl = 'Separator.Line';
		Zp = 'Separator.Paragraph';
		Zs = 'Separator.Space';
}

function lib.get(v)
	return require('parse.char.utf8.set.' .. (aliases[v] or v))
end

return lib
