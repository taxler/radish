
local re = require 're'

return re.compile([[

	'<?' {|
		{:target: %NAME :}
		(%s+ {:arguments: (!'?>' .)* :})?
		{:type: '' -> 'processing_instruction' :}
	|} '?>'

]], {
	NAME = require 'parse.match.identifier.xml';
})
