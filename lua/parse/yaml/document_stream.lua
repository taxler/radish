
local m = require 'lpeg'
local re = require 're'

local prefix_utf_type = require 'parse.read.prefix.utf_type'
local prefix_directives = require 'parse.yaml.prefix.directives'
local prefix_content = require 'parse.yaml.prefix.content'
local skip_lines = require 'parse.yaml.prefix.skip_lines'
local end_of_document = require 'parse.yaml.prefix.end_of_document'
local make_prefix_tag = require 'parse.yaml.make.prefix.tag'

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
						tag = '?';
						primitive = 'scalar';
						data = '';
					};
				}
			elseif end_pos ~= pos then
				return nil, 'encountered "..." without matching "---"'
			end
			pos = end_pos
		else
			local tag_handle_to_prefix = {['!!'] = 'tag:yaml.org,2002:'; ['!']='!'}
			if directives then
				for i, directive in ipairs(directives) do
					if directive.name == 'TAG' then
						if directive.arguments == nil or #directive.arguments ~= 2 then
							print(directive.arguments)
							return nil, 'wrong number of arguments for %TAG directive'
						end
						local handle, prefix = directive.arguments[1], directive.arguments[2]
						tag_handle_to_prefix[handle] = prefix
					end
				end
				if next(directives) == nil then
					directives = nil
				end
			end
			local unquoted_tag, quoted_tag = '?', '!'
			local prefix_tag = make_prefix_tag(tag_handle_to_prefix)
			do
				local given_tag, new_pos = prefix_tag:match(source, pos)
				if given_tag ~= nil then
					pos = skip_lines:match(source, new_pos)
					unquoted_tag, quoted_tag = given_tag, given_tag
				end
			end
			local end_pos = end_of_document:match(source, pos)
			if end_pos ~= nil then
				pos = end_pos
				documents[#documents+1] = {
					directives = directives;
					content = {
						tag = unquoted_tag;
						data = '';
						primitive = 'scalar';
					};
				}
			else
				local content
				content, pos = prefix_content:match(source, pos, unquoted_tag, quoted_tag)
				if content == nil then
					return nil, 'unrecognized content'
				end
				documents[#documents+1] = {
					directives = directives;
					content = content;
				}
				pos = skip_lines:match(source, pos)
				pos = end_of_document:match(source, pos) or pos
			end
		end
	end
	return documents
end

return document_stream
