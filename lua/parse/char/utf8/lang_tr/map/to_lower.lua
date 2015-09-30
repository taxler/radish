return require 'parse.char.utf8.map.to_lower' + {
	'\u{130}i';
	{
		{char='\u{307}', on_success=''};
		check_suffix = require 'parse.char.utf8.lang_tr.peek.After_I'
	};
	{
		{char='I', on_success='\u{131}', on_failure='i'};
		check_suffix = require 'parse.char.utf8.lang_tr.peek.Not_Before_Dot'
	};
}
