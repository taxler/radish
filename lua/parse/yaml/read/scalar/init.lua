
local m = require 'lpeg'
local re = require 're'

return re.compile([[

	{|
		{:data: %SINGLE_QUOTED :}
		{:primitive: '' -> 'scalar' :}
		{:tag: %QUOTED_TAG :}
	|}

]], {
	SINGLE_QUOTED = require 'parse.yaml.read.scalar.quoted.single';
	QUOTED_TAG = m.Carg(2);
})
