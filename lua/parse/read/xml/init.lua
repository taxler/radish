
local m = require 'lpeg'
local re = require 're'

local prefix_utf_type = require 'parse.read.prefix.utf_type'
local prefix_declaration = require 'parse.read.xml.prefix.declaration'
local prefix_before_document = require 'parse.read.xml.prefix.before_document'

local lib = {}

local c_tag_open = re.compile([[

	tag_open <- '<' {|
		{:name: %NAME :}
		{:attributes: {| attribute+ |} :}?
		%s*
		{:self_closing: '/' %TRUE :}?
		{:type: '' -> 'open' :}
	|} '>'

	attribute <- {|
		%s+
		{:name: %NAME :}
		%s* '=' %s*
		{:value:
			  (['] { [^']* } ['])
			/ (["] { [^"]* } ["])
		:}
	|}

]], {
	NAME = require 'parse.match.identifier.xml';
	TRUE = m.Cc(true);
})

local prefix_tag_open = c_tag_open * m.Cp()

local c_tag_close = re.compile([[

	tag_close <- '</' {|
		{:name: %NAME :}
		%s*
		{:type: '' -> 'close':}
	|} '>'

]], {
	NAME = require 'parse.match.identifier.xml';
})

local c_remaining_content = re.compile([=[

	content <- {| chunk* |}
	
	chunk <- {[^&<]+} / (&'<' tag) / entity / bad_char

	tag <- %TAG_OPEN / %TAG_CLOSE / cdata / %COMMENT / %PI

	cdata <- '<![CDATA[' { (!']]>' .)* } ']]>'

	bad_char <- {| {:bad_char: . :} {:type:''->'bad_char':} |}

	entity <- '&' (named / numeric) ';'

	named <- {| {:name: %NAME :} {:type:''->'entity':} {:entity_type:''->'named':} |}
	numeric <- '#' (('x' hex) / decimal)

	hex <- {| {:hex: %x+ :} {:type:''->'entity':} {:entity_type:''->'hex':} |}
	decimal <- {| {:decimal: %d+ :} {:type:''->'entity':} {:entity_type:''->'decimal':} |}

]=], {
	TAG_OPEN = assert(c_tag_open);
	TAG_CLOSE = assert(c_tag_close);
	COMMENT = require 'parse.match.comment.xml';
	PI = require 'parse.read.xml.processing_instruction';
	NAME = require 'parse.match.identifier.xml';
})

local c_xmlns_prefix = re.compile [[

	'xmlns' (
		(
			':'
			{~  [^:]+  ('' -> ':')  ~}
		)
		/ {''}
	) !.

]]

local element_meta = {
	__tostring = function(self)
		local buf = {'<' .. self.context.prefix .. self.name}
		for prefix, context in pairs(self.contexts or {}) do
			if prefix == '' then
				buf[#buf+1] = string.format('xmlns=%q',
					context.namespace)
			else
				buf[#buf+1] = string.format('xmlns:%s=%q',
					string.sub(prefix,1,-2),
					context.namespace)
			end
		end
		for i, attribute in ipairs(self.attributes or {}) do
			buf[#buf+1] = string.format('%s%s=%q',
				attribute.context.prefix,
				attribute.name,
				attribute.value)
		end
		if self[1] == nil then
			return table.concat(buf, ' ') .. '/>'
		end
		buf[1] = table.concat(buf, ' ') .. '>'
		for i = 1, #self do
			buf[i+1] = tostring(self[i])
		end
		buf[#self + 2] = '</' .. self.context.prefix .. self.name .. '>'
		return table.concat(buf, '', 1, #self + 2)
	end;
}

function lib.read(source)
	local document = {}
	local utf_type, pos = prefix_utf_type:match(source)
	if utf_type ~= 'utf-8' then
		if utf_type == nil then
			return nil, 'unknown encoding'
		end
		local from_utf = require 'parse.convert.to_utf8.from_utf'
		source = from_utf:match(source)
		pos = 1
	end
	document.determined_encoding = utf_type

	-- find the declaration, if any
	local declaration, new_pos = prefix_declaration:match(source, pos)
	if declaration then
		pos = new_pos
		document.xml_version = declaration.version
		document.declared_standalone = declaration.standalone
		local enc = declaration.encoding
		document.declared_encoding = enc
		if enc ~= nil then
			local charset_id = require('parse.substitution.charset.identifier')
			enc = charset_id[enc]
		end
		if enc ~= nil
		and document.determined_encoding == 'utf-8'
		and enc ~= 'csUTF8' then
			-- the document seems to be telling us it is encoded in
			-- another ascii-7 compatible form that is not utf-8.
			-- we need to convert this form to utf-8 before we continue.
			local from_charset = require 'parse.convert.to_utf8.from_8bit_charset'
			local to_utf8, message = from_charset(enc)
			if to_utf8 == nil then
				return nil, message
			end
			-- TODO: add blank lines if declaration was more than one?
			local charset_name = require 'parse.substitution.charset.primary_name'
			document.determined_encoding = charset_name[enc]
			source = source:sub(pos)
			source = to_utf8:match(source)
			pos = 1
		end
	end
	local before_document
	before_document, pos = prefix_before_document:match(source, pos)

	for i = 1, #before_document do
		document[#document+1] = before_document[i]
		if before_document[i] == 'doctype' then
			document.doctype = before_document[i]
		end
	end

	document.element, pos = prefix_tag_open:match(source, pos)

	if document.element == nil then
		return nil, 'invalid document'
	end

	document[#document+1] = document.element

	local function do_element(element, contexts, chunks, ichunk)
		element.type = 'element'
		setmetatable(element, element_meta)
		if element.attributes ~= nil then
			local new_contexts = nil
			for i = #element.attributes, 1, -1 do
				local attribute = element.attributes[i]
				local prefix = c_xmlns_prefix:match(attribute.name)
				if prefix ~= nil then
					if new_contexts == nil then
						local inherit_contexts = contexts
						new_contexts = setmetatable({}, {
							__index = function(self, prefix)
								return inherit_contexts[prefix]
							end;
						})
					end
					new_contexts[prefix] = {
						namespace = attribute.value;
						element = element;
						prefix = prefix}
					table.remove(element.attributes, i)
				end
			end
			if new_contexts then
				element.contexts = {}
				for k,v in pairs(new_contexts) do
					element.contexts[k] = v
				end
				contexts = new_contexts
			end
			for i, attribute in ipairs(element.attributes) do
				local prefix, rest = string.match(attribute.name, '^([^:+]:)([^:]+)$')
				if prefix then
					attribute.name = rest
					attribute.context = contexts[prefix]
				else
					attribute.context = contexts['']
				end
			end
		end
		local prefix, rest = string.match(element.name, '^([^:+]:)([^:]+)$')
		if prefix then
			element.name = rest
			element.context = contexts[prefix]
		else
			element.context = contexts['']
		end
		if element.self_closing then
			element.self_closing = nil
			return ichunk
		end
		while true do
			local chunk = chunks[ichunk]
			ichunk = ichunk + 1
			if type(chunk) ~= 'string' then
				if chunk == nil then
					error('unterminated element ' .. element.name)
				end
				if chunk.type == 'close' then
					if chunk.name ~= element.name then
						error('tag mismatch (' .. element.name .. '/' .. chunk.name .. ')')
					end
					break
				end
				if chunk.type == 'open' then
					ichunk = do_element(chunk, contexts, chunks, ichunk)
				end
			end
			element[#element+1] = chunk
		end
		return ichunk
	end

	local chunks = c_remaining_content:match(source, pos)

	document.contexts = {}
	document.contexts['xml:'] = {namespace='http://www.w3.org/XML/1998/namespace'}
	setmetatable(document.contexts, {
		__index = function(self, prefix)
			if type(prefix) ~= 'string' then
				return nil
			end
			local context = {namespace='', prefix=prefix}
			self[prefix] = context
			return context
		end;
	})

	local success, result = pcall(do_element, document.element, document.contexts, chunks, 1)

	if success then
		ichunk = result
	else
		return nil, result
	end

	for i = ichunk, #chunks do
		local chunk = chunks[i]
		if type(chunk) == 'string' then
			if string.find(chunk, '%S') then
				return nil, 'unexpected content after document'
			end
		elseif chunk.type == 'processing_instruction' or chunk.type == 'comment' then
			document[#document+1] = chunk
		else
			return nil, 'unexpected content after document'
		end
	end

	return document
end

return lib
