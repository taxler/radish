
local bit = require 'bit'
local m = require 'lpeg'
local re = require 're'

local to_utf8 = require 'parse.convert.to_utf8.from_utf'

local json = require 'parse.json'

local lib = {}

local make_context = require 'parse.json.make.context'
local context = make_context(
	'comments',
	'hex_literals',
	'trailing_commas',
	'string_concat',
	'single_quoted_strings')
local make_read_document = require 'parse.json.make.read.document'
local read_document = make_read_document(context)

function lib.read(source)
	local utf8, result = to_utf8:match(source)
	if utf8 == nil then
		return nil, result
	end
	return read_document:match(utf8)
end

return lib
