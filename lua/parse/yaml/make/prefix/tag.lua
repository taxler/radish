
local m = require 'lpeg'
local re = require 're'

local pdef_tag = [[

	read_tag_prefix <- &'!' (verbatim / prefixed / {'!'}) (%s+ / !.) {}
	verbatim <- '!<' {[^>]*} '>'
	prefixed <- {~ (handle -> HANDLE_TO_PREFIX) tag_name ~}
	handle <- '!' (tag_name? '!')?

	tag_name <- ([-#;/?:@&=+$_.~*'()a-zA-Z0-9]+ / ('%' %x %x))+

]]

local function hex_encode(xx)
	return string.char(tonumber(xx, 16))
end

local Cc_true = m.Cc(true)

return function(handle_to_prefix)
	return re.compile(pdef_tag, {
		HANDLE_TO_PREFIX = handle_to_prefix;
		HEX_ENCODE = hex_encode;
		TRUE = Cc_true;
	})
end
