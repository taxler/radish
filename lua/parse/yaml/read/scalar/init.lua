
local re = require 're'

return re.compile([[

	{|
		{:data: %SINGLE_QUOTED :}
		{:primitive: '' -> 'scalar' :}
		{:tag: '' -> 'tag:yaml.org,2002:str' :}
	|}

]], {
	SINGLE_QUOTED = require 'parse.yaml.read.scalar.quoted.single';
})
