-- Lithuanian mode:
-- Introduce an explicit dot above when lowercasing capital I's and J's
-- whenever there are more accents above.
-- (of the accents used in Lithuanian: grave, acute, tilde above, and ogonek)

local m = require 'lpeg'

return require 'parse.char.utf8.map.to_lower' + {
	'\u{cc}' .. '\u{69}\u{307}\u{300}';
	'\u{cd}' .. '\u{69}\u{307}\u{301}';
	'\u{128}' .. '\u{69}\u{307}\u{303}';
	{
		{char='I', on_success='i\u{307}', on_failure='i'};
		{char='J', on_success='j\u{307}', on_failure='j'};
		{char='\u{12e}', on_success='\u{12f}\u{307}', on_failure='\u{12f}'};
		check_suffix = require 'parse.char.utf8.lang_lt.peek.More_Above';
	};
}
