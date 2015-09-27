
return {
	{'\x00\x7F';
		min='\u{0}', max='\u{7f}'};
	{'\xC2\xDF', '\x80\xBF';
		min='\u{80}', max='\u{7ff}'};
	{'\xE0\xE0', '\xA0\xBF', '\x80\xBF';
		min='\u{800}', max='\u{fff}'};
	{'\xE1\xEC', '\x80\xBF', '\x80\xBF';
		min='\u{1000}', max='\u{cfff}'};
	{'\xED\xED', '\x80\x9F', '\x80\xBF';
		min='\u{d000}', max='\u{d7ff}'};
	{'\xEE\xEF', '\x80\xBF', '\x80\xBF';
		min='\u{e000}', max='\u{ffff}'};
	{'\xF0\xF0', '\x90\xBF', '\x80\xBF', '\x80\xBF';
		min='\u{10000}', max='\u{3ffff}'};
	{'\xF1\xF3', '\x80\xBF', '\x80\xBF', '\x80\xBF';
		min='\u{40000}', max='\u{fffff}'};
	{'\xF4\xF4', '\x80\x8F', '\x80\xBF', '\x80\xBF';
		min='\u{100000}', max='\u{10ffff}'};
}
