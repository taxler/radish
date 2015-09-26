
local re = require 're'

return re.compile([[
	
	%SCALAR {}

]], {
	SCALAR = require 'parse.yaml.read.scalar';
})
