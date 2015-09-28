
local m = require 'lpeg'
local contiguous_byte_ranges = require 'parse.char.utf8.data.contiguous_byte_ranges'
local m_char = require 'parse.char.utf8'
local two_chars = m.C(m_char) * m.C(m_char) * m.P(-1)
local prefix_char = m.C(m_char) * m.Cp()

local blob_tools = require 'parse.blob.tools'
local next_blob = blob_tools.next

local char_tools = require 'parse.char.utf8.tools'
local next_char = char_tools.next
local previous_char = char_tools.previous
local char_range = char_tools.range

local set_proto = {}
local set_meta = {__index = set_proto}

local function add_ranges(ranges, from_char, to_char)
	-- we don't need to do anything if from_char and to_char
	-- only differ by their final byte
	if #from_char ~= #to_char
	or (#from_char > 1 and from_char:sub(1, -2) ~= to_char:sub(1, -2)) then
		local min_char, max_char
		-- if this loop does not break/return, from_char is invalid
		for i, range_set in ipairs(contiguous_byte_ranges) do
			min_char = range_set.min
			max_char = range_set.max
			if from_char <= max_char then
				if to_char <= max_char then
					break
				end
				-- if lib.byte_sequence_ranges[i+1] is nil, to_char is invalid
				local next_min_char = contiguous_byte_ranges[i+1].min
				add_ranges(ranges, from_char, max_char)
				add_ranges(ranges, next_min_char, to_char)
				return
			end
		end
		-- this loop should always break/return
		for i = 1, #from_char-1 do
			local from_b = string.byte(from_char, i)
			local to_b = string.byte(to_char, i)
			if from_b ~= to_b then
				if string.sub(from_char, i+1) ~= string.sub(min_char, i+1) then
					add_ranges(ranges,
						from_char,
						string.sub(from_char, 1, i)
							.. string.sub(max_char, i + 1))
					add_ranges(ranges,
						string.sub(from_char, 1, i - 1)
							.. string.char(from_b + 1)
							.. string.sub(min_char, i + 1),
						to_char)
				elseif string.sub(to_char, i+1) ~= string.sub(max_char, i+1) then
					add_ranges(ranges,
						from_char,
						string.sub(from_char, 1, i - 1)
							.. string.char(to_b - 1)
							.. string.sub(max_char, i + 1))
					add_ranges(ranges,
						string.sub(from_char, 1, i - 1)
							.. string.char(from_b + 1)
							.. string.sub(min_char, i + 1),
						to_char)
				else
					break
				end
				return
			end
		end
	end
	ranges[#ranges+1] = {from_char, to_char}
end

local range_proto = {}
local range_meta = {__index = range_proto}

function range_proto:compile(min_pre_count)
	local p_initial = m.P(true)
	local count = #self
	if self[1] and self[1][1] then
		if min_pre_count and count >= min_pre_count then
			p_initial = m.P(false)
			for i = 1, count do
				p_initial = p_initial + self[i][1]
			end
			p_initial = #p_initial
		end
		if count >= 16 then
			local halfway_point = math.floor(count/2)
			local first_half = setmetatable({unpack(self,1,halfway_point)}, range_meta)
			local second_half = setmetatable({unpack(self,halfway_point+1)}, range_meta)
			local first_half_prefix_char = m.P(false)
			for i = 1, halfway_point do
				first_half_prefix_char = first_half_prefix_char + first_half[i][1]
			end
			return p_initial * (
				#first_half_prefix_char * first_half:compile()
				+ second_half:compile()
			)
		end
	end
	local matcher = m.P(false)
	for i = count, 1, -1 do
		matcher = self[i][2] + matcher
	end
	return p_initial * matcher
end

local function aux_range_pattern(output, sorted_ranges, pos, prefix)
	local range = sorted_ranges[pos]
	if range == nil then
		return pos
	end
	if prefix ~= '' then
		if range[1]:sub(1, #prefix) ~= prefix
		or range[2]:sub(1, #prefix) ~= prefix then
			return pos
		end
	end
	local next_prefix_len = #prefix + 1
	if next_prefix_len < #range[1]
	and string.byte(range[1], next_prefix_len) == string.byte(range[2], next_prefix_len) then
		local sub_output = setmetatable({}, range_meta)
		local next_prefix = string.sub(range[1], 1, next_prefix_len)
		local next_pos = aux_range_pattern(sub_output, sorted_ranges, pos, next_prefix)
		output[#output+1] = {m.P(next_prefix:sub(-1)), m.P(next_prefix:sub(-1)) * sub_output:compile(8)}
		return aux_range_pattern(output, sorted_ranges, next_pos, prefix)
	end
	local matcher = m.P(true)
	local match_prefix_char = false
	for i = next_prefix_len, #range[1] do
		local from_b = string.sub(range[1], i,i)
		local to_b = string.sub(range[2], i,i)
		local match_b
		if from_b == to_b then
			match_b = m.P(from_b)
		else
			match_b = m.R(from_b..to_b)
		end
		matcher = matcher * match_b
		if i == next_prefix_len and i < #range[1] then
			match_prefix_char = match_b
		end
	end
	output[#output+1] = {match_prefix_char, matcher}
	return aux_range_pattern(output, sorted_ranges, pos + 1, prefix)
end

function set_proto:compile()
	local ranges = {}

	local set = self.S
	if set ~= nil then

		local char
		local i = 1
		while i <= #set do
			char, i = prefix_char:match(set, i)
			if char == nil then
				error('bad S value: invalid utf-8 sequence', 2)
			end
			add_ranges(ranges, char, char)
		end

	end

	local r = self.R

	if type(r) == 'string' then
		r = {r}
	end

	for _, pair in ipairs(r or {}) do
		local from_char, to_char = two_chars:match(pair)
		if from_char == nil then
			error('bad R value: expecting sequence of 2 utf-8 characters', 2)
		end
		add_ranges(ranges, from_char, to_char)
	end

	-- sort by the first character
	table.sort(ranges, function(a,b)  return a[1] < b[1];  end)
	-- combine touching/overlapping ranges
	do
		local i = 1
		local range = ranges[i]
		if range ~= nil then
			repeat
				i = i + 1
				local next_range = ranges[i]
				while next_range ~= nil
				and (range[2] >= next_range[1] or next_blob(range[2]) == next_range[1]) do
					if range[2] < next_range[2] then
						range[2] = next_range[2]
					end
					table.remove(ranges, i)
					next_range = ranges[i]
				end
				range = next_range
			until range == nil
		end
	end

	local onebyte = m.P(false)
	while ranges[1] and #ranges[1][1] == 1 do
		local range = table.remove(ranges, 1)
		onebyte = onebyte + m.R(range[1] .. range[2])
	end

	local alternatives = setmetatable({}, range_meta)

	aux_range_pattern(alternatives, ranges, 1, '')

	local ranges_pattern = alternatives:compile(2)

	return onebyte + ranges_pattern
end

function set_meta.__add(a, b)
	local R
	if type(a.R) == 'string' then
		R = {a.R}
	else
		R = {unpack(a.R or {})}
	end
	if type(b.R) == 'string' then
		R[#R+1] = b.R
	else
		for i,v in ipairs(b.R or {}) do
			R[#R+1] = v
		end
	end
	local S = (a.S or '') .. (b.S or '')
	return setmetatable({R=R, S=S}, set_meta)
end

local function each_char(v)
	local pos = 1
	return function()
		if pos > #v then
			return nil
		end
		local char; char, pos = prefix_char:match(v, pos)
		if char == nil then
			error('invalid utf-8 sequence')
		end
		return char
	end
end

function set_meta.__sub(a, b)
	local S_set = {} do
		for c in each_char(a.S or '') do
			S_set[c] = true
		end
	end
	
	local R_list = {} do
		local R
		if type(a.R) == 'string' then
			R = {a.R}
		else
			R = a.R or {}
		end

		for i, pair in ipairs(R) do
			local from_char, to_char = two_chars:match(pair)
			if from_char == nil then
				error('invalid utf-8 sequence')
			end
			add_ranges(R_list, from_char, to_char)
		end
		table.sort(R_list, function(x, y)
			return x[1] < y[1]
		end)
	end

	local function remove_range(from_char, to_char)
		for c in char_range(from_char, to_char) do
			S_set[c] = nil
		end
		local i = 1
		while true do
			local pair = R_list[i]
			if pair == nil or to_char < pair[1] then
				break
			end
			if from_char > pair[2] then
				i = i + 1
				goto continue
			end
			if from_char <= pair[1] then
				if to_char >= pair[2] then
					table.remove(R_list, i)
					goto continue
				end
				pair[1] = next_char(to_char)
				i = i + 1
				goto continue
			end
			if to_char >= pair[2] then
				pair[2] = previous_char(from_char)
				i = i + 1
				goto continue
			end
			table.insert(R_list, i + 1, {next_char(to_char), pair[2]})
			pair[2] = previous_char(from_char)
			i = i + 2
			::continue::
		end
	end

	for c in each_char(b.S or '') do
		remove_range(c, c)
	end

	local remove_R = b.R
	if type(remove_R) == 'string' then
		remove_R = {remove_R}
	end
	for i, pair in ipairs(remove_R or {}) do
		local from_char, to_char = two_chars:match(pair)
		if from_char == nil then
			error('invalid utf-8 sequence')
		end
		remove_range(from_char, to_char)
	end

	local S_list = {}
	for c in pairs(S_set) do
		S_list[#S_list+1] = c
	end
	local S = table.concat(S_list)

	for i,pair in ipairs(R_list) do
		R_list[i] = pair[1] .. pair[2]
	end

	return setmetatable({R=R_list, S=S}, set_meta)
end

return function(def)
	return setmetatable(def or {R='\0\u{10ffff}'}, set_meta)
end
