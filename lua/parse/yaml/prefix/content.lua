
local re = require 're'

return re.compile([[
	
	(%SCALAR / %SEQUENCE) {}

]], {
	SCALAR = require 'parse.yaml.read.scalar';
	SEQUENCE = require 'parse.yaml.read.sequence.flow';
})
