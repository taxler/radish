
local re = require 're'

return re.compile([[

	{|
		{:data: %SINGLE_QUOTED :}
		{:primitive: '' -> 'scalar' :}
		{:tag: '' -> '!' :}
	|}

]], {
	SINGLE_QUOTED = require 'parse.yaml.read.scalar.quoted.single';
})
