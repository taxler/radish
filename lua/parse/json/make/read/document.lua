
local re = require 're'
local make_context = require 'parse.json.make.context'
local make_read_value = require 'parse.json.make.read.value'

local pdef_document = [[
	%SPACE %VALUE !.
]]

return function(context)
	context = context or make_context()
	context.VALUE = make_read_value(context)
	return re.compile(pdef_document, context)
end
