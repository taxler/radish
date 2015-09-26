
local m = require 'lpeg'
local re = require 're'

local prefix_utf_type = require 'parse.read.prefix.utf_type'
local prefix_directives = require 'parse.yaml.prefix.directives'
local prefix_content = require 'parse.yaml.prefix.content'
local skip_lines = require 'parse.yaml.prefix.skip_lines'
local end_of_document = require 'parse.yaml.prefix.end_of_document'

local document_stream = {}

function document_stream.read(source)
	local utf_type, pos = prefix_utf_type:match(source)
	if utf_type == nil then
		return nil, 'unknown encoding'
	elseif utf_type ~= 'utf-8' then
		local from_utf = require 'parse.convert.to_utf8.from_utf'
		source = from_utf:match(source)
		pos = 1
	end
	local documents = {}
	pos = skip_lines:match(source, pos)
	while pos <= #source do
		local directives, new_pos = prefix_directives:match(source, pos)
		if directives ~= nil then
			pos = skip_lines:match(source, new_pos)
		end
		local end_pos = end_of_document:match(source, pos)
		if end_pos ~= nil then
			if directives ~= nil then
				if next(directives) == nil then
					directives = nil
				end
				documents[#documents+1] = {
					directives = directives;
					content = {
						tag = 'tag:yaml.org,2002:null';
						primitive = 'scalar';
						data = '';
					};
				}
			elseif end_pos ~= pos then
				return nil, 'encountered "..." without matching "---"'
			end
			pos = end_pos
		else
			local content, new_pos = prefix_content:match(source, pos)
			if content == nil then
				return nil, 'unrecognized content'
			end
			if next(directives) == nil then
				directives = nil
			end
			documents[#documents+1] = {
				directives = directives;
				content = content;
			}
			pos = skip_lines:match(source, new_pos)
			local end_pos = end_of_document:match(source, pos)
			if end_pos then
				pos = end_pos
			end
		end
	end
	return documents
end

return document_stream
