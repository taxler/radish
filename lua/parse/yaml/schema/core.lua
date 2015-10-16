
local m = require 'lpeg'
local re = require 're'
local make_schema = require 'parse.yaml.make.schema'

local schema = make_schema()

local core_schema = {}

core_schema.scalar_tag_resolvers = {
	re.compile[[
		('null' / ('N' ('ull' / 'ULL')) / '~')?
		!.
	]] * m.Cc'tag:yaml.org,2002:null';
	re.compile[[
		(
			'true' / ('T' ('rue' / 'RUE'))
			/ 'false' / ('F' ('alse' / 'ALSE'))
		)
		!.
	]] * m.Cc'tag:yaml.org,2002:bool';
	re.compile[[ [-+]? %d+ !. ]] * m.Cc'tag:yaml.org,2002:int';
	re.compile[[ '0o' [0-7]+ !. ]] * m.Cc'tag:yaml.org,2002:int';
	re.compile[[ '0x' %x+ !. ]] * m.Cc'tag:yaml.org,2002:int';
	re.compile[[
		[-+]?
		( ('.' %d+) / (%d+ ('.' %d*)?) )
		([eE] [-+]? %d+)?
		!.
	]] * m.Cc'tag:yaml.org,2002:float';
	re.compile[[
		[-+]?
		('.inf' / ('.I' ('nf' / 'NF')))
		!.
	]] * m.Cc'tag:yaml.org,2002:float';
	re.compile[[
		('.nan' / ('.N' [aA] 'N'))
		!.
	]] * m.Cc'tag:yaml.org,2002:float';
	default = 'tag:yaml.org,2002:str';
}

return core_schema
