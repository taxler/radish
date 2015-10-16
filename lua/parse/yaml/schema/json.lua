
local m = require 'lpeg'
local re = require 're'
local make_schema = require 'parse.yaml.make.schema'

local frac_part = re.compile [[ '.' %d* ]]
local exp_part = re.compile [[ [eE] [-+]? %d+ ]]

local json_schema = make_schema()

json_schema.scalar_tag_resolvers = {
	re.compile[[ 'null' !. ]] * m.Cc'tag:yaml.org,2002:null';
	re.compile[[ ('true' / 'false') !. ]] * m.Cc'tag:yaml.org,2002:bool';
	re.compile[[ '-'? ('0' / [1-9] [0-9]*) ]] * (
		(frac_part * exp_part^-1 + exp_part * -1) * m.Cc'tag:yaml.org,2002:float'
		+ -1 * m.Cc'tag:yaml.org,2002:int'
	);
	default = nil; -- no default tag: error if no resolver matches
}

return json_schema
