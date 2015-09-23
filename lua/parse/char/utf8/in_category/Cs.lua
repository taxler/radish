-- Other, Surrogate
local m = require 'lpeg'

-- luajit parser won't accept surrogates in \u escapes
return '\xED' * (
	'\xA0\x80' + (
		'\xAD\xBF' + (
			'\xAE\x80' + (
				'\xAF\xBF' + (
					'\xB0\x80' + m.P'\xBF\xBF')))))