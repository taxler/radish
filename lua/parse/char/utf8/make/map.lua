local strsub = string.sub
local m = require 'lpeg'
local contiguous_byte_ranges = require 'parse.char.utf8.data.contiguous_byte_ranges'
local make_set = require 'parse.char.utf8.make.set'
local m_char = require 'parse.char.utf8'
local char_tools = require 'parse.char.utf8.tools'
local next_char = char_tools.next

local c_char_rest = m.C(m_char) * m.C( m.P(1)^0 )

local map_proto = {}
local map_meta = {__index = map_proto}

local leaf_proto = {}
local leaf_meta = {__index = leaf_proto}

local branch_proto = {}
local branch_meta = {__index = branch_proto}

local three_chars = m.C(m_char) * m.C(m_char) * m.C(m_char) * m.P(-1)

local function make_map(def)
	local map = setmetatable({}, map_meta)
	for i, entry in ipairs(def) do
		if type(entry) == 'string' then
			local first_char, rest = c_char_rest:match(entry)
			if first_char == nil then
				error('invalid utf-8 sequence')
			end
			map:add(first_char, rest)
		elseif type(entry) == 'table' then
			local step = entry.step
			if step ~= nil then
				-- table of ranges
				for i, entry in ipairs(entry) do
					local from_char, to_char, last_to_char = three_chars:match(entry)
					if from_char == nil then
						error('invalid utf-8 sequence')
					end
					if to_char > last_to_char then
						goto done
					end
					map:add(from_char, to_char)
					repeat
						for i = 1, step do
							to_char = next_char(to_char)
							if to_char > last_to_char then
								goto done
							end
							from_char = next_char(from_char)
						end
						map:add(from_char, to_char)
					until to_char == last_to_char
					::done::
				end
			else
				local check_suffix = entry.check_suffix
				if check_suffix ~= nil then
					for i, entry in ipairs(entry) do
						local first_char, rest = c_char_rest:match(entry)
						if first_char == nil then
							error('invalid utf-8 sequence')
						end
						map:add(first_char, check_suffix * m.Cc(rest))
					end
				end
			end
		end
	end
	return map
end

function map_proto:add(char, then_pattern)
	local leaf
	if #char == 1 then
		leaf = self['']
		if leaf == nil then
			leaf = setmetatable({}, leaf_meta)
			self[''] = leaf
		end
		leaf[char] = then_pattern
		return
	end
	local context = self
	for i = 1, #char-1 do
		local c = strsub(char, i, i)
		local new_context = context[c]
		if new_context == nil then
			if i == #char-1 then
				new_context = setmetatable({}, leaf_meta)
			else
				new_context = setmetatable({}, branch_meta)
			end
			context[c] = new_context
		end
		context = new_context
	end
	context[strsub(char, -1)] = then_pattern
end

local function add_prefixed(dest, src, prefix)
	for k,v in pairs(src) do
		local m = getmetatable(v)
		if m == branch_meta then
			add_prefixed(dest, v, prefix..k)
		elseif m == leaf_meta then
			for k2,v in pairs(v) do
				dest[#dest+1] = prefix .. k .. k2
			end
		end
	end
end

function map_proto:make_set_from_keys()
	local S_list = {}
	add_prefixed(S_list, self, '')
	return make_set { S=table.concat(S_list) }
end

local function get_patt(source, keys)
	local m_patt = m.P(false)
	for i = #keys, 1, -1 do
		local key = keys[i]
		local value = source[key]
		local meta = getmetatable(value)
		if meta == leaf_meta or meta == branch_meta then
			local sub_keys = {}
			for k in pairs(value) do
				sub_keys[#sub_keys+1] = k
			end
			table.sort(sub_keys)
			value = get_patt(value, sub_keys)
		elseif type(value) == 'string' then
			value = m.Cc(value)
		end
		m_patt = key * value + m_patt
	end
	return m_patt
end

function map_proto:compile()
	local keys = {}
	for k,v in pairs(self) do
		keys[#keys+1] = k
	end
	table.sort(keys)
	local m_one_char
	if keys[1] == '' then
		table.remove(keys, 1)
		local p_1 = m.P(false)
		local p_2 = m.P(false)
		local cap_set = {}
		for k,v in pairs(self['']) do
			if type(v) == 'string' then
				p_1 = p_1 + k
				cap_set[k] = v
			else
				p_2 = p_2 + (k * v)
			end
		end
		m_one_char = p_1 / cap_set + p_2
	end
	if keys[1] == nil then
		return m_one_char
	end
	local m_multibyte = get_patt(self, keys)
	return m_one_char + m_multibyte
end

local m_char_no_more = m_char * m.P(-1)

local function reverse_aux(context, reversed_map, prefix)
	for k,v in pairs(context) do
		local meta = getmetatable(v)
		if meta == branch_meta or meta == leaf_meta then
			reverse_aux(v, reversed_map, prefix .. k)
		elseif type(v) == 'string' then
			if not m_char_no_more:match(v) then
				error 'char mapping must be one-to-one to be reversible'
			end
			reversed_map:add(v, prefix .. k)
		else
			error 'char mapping must not include custom patterns to be reversible'
		end
	end
end

function map_proto:reverse()
	local reversed_map = setmetatable({}, map_meta)
	reverse_aux(self, reversed_map, '')
	return reversed_map
end

local function clone(v)
	local copy = setmetatable({}, getmetatable(v))
	for k,v in pairs(v) do
		local m = getmetatable(v)
		if m == branch_meta or m == leaf_meta then
			copy[k] = clone(v)
		else
			copy[k] = v
		end
	end
	return copy
end

local function apply(self, other)
	for k,v in pairs(other) do
		local m = getmetatable(v)
		if m == branch_meta or m == leaf_meta then
			local my_v = rawget(self, k)
			if my_v == nil then
				self[k] = clone(v)
			else
				apply(my_v, v)
			end
		else
			self[k] = v
		end
	end
end

function map_meta:__add(other)
	if getmetatable(other) == nil then
		other = make_map(other)
	end
	local copy = clone(self)
	apply(copy, other)
	return copy
end


-- get byte position of first possible match
-- gets false positives but not false negatives
-- pass true to ignore characters in ASCII-7 range
function map_proto:make_quick_scanner(higher_planes_only)
	local p = m.P(false)
	for k,v in pairs(self) do
		if k == '' then
			if not higher_planes_only then
				for k in pairs(v) do
					p = p + k
				end
			end
		else
			p = p + k
		end
	end
	return (1 - p)^0 * m.Cp() * m.P(1)
end

return make_map
