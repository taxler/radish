
local re = require 're'

return re.compile([[

	flow_sequence <- '[' %REST_OF_LINE* entry* (',' (%REST_OF_LINE+ %s*)?) ']'


]], {

	REST_OF_LINE = require 'parse.yaml.match.rest_of_line.not_final';
})