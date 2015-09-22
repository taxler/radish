
local m = require 'lpeg'

local lib = {}

lib.byte_sequence_ranges = {
	-- U+000000 to U+00007F
	{'\x00\x7F'};
	-- U+000080 to U+0007FF
	{'\xC2\xDF', '\x80\xBF'};
	-- U+000800 to U+000FFF
	{'\xE0\xE0', '\xA0\xBF', '\x80\xBF'};
	-- U+001000 to U+00CFFF
	{'\xE1\xEC', '\x80\xBF', '\x80\xBF'};
	-- U+00D000 to U+00D7FF
	{'\xED\xED', '\x80\x9F', '\x80\xBF'};
	-- U+00E000 to U+00FFFF
	{'\xEE\xEF', '\x80\xBF', '\x80\xBF'};
	-- U+010000 to U+03FFFF
	{'\xF0\xF0', '\x90\xBF', '\x80\xBF', '\x80\xBF'};
	-- U+040000 to U+0FFFFF
	{'\xF1\xF3', '\x80\xBF', '\x80\xBF', '\x80\xBF'};
	-- U+100000 to U+10FFFF
	{'\xF4\xF4', '\x80\x8F', '\x80\xBF', '\x80\xBF'};
}

local m_char = m.P(false)

for i = #lib.byte_sequence_ranges, 1, -1 do
	local ranges = lib.byte_sequence_ranges[i]
	local m_sequence = m.P(true)
	for j, range in ipairs(ranges) do
		if string.sub(range,1,1) == string.sub(range,2,2) then
			m_sequence = m_sequence * string.sub(range,1,1)
		else
			m_sequence = m_sequence * m.R(range)
		end
	end
	m_char = m_sequence + m_char

	ranges.min = string.sub(ranges[1], 1, 1)
			.. string.sub(ranges[2] or '', 1, 1)
			.. string.sub(ranges[3] or '', 1, 1)
			.. string.sub(ranges[4] or '', 1, 1)
	ranges.max = string.sub(ranges[1], 2, 2)
			.. string.sub(ranges[2] or '', 2, 2)
			.. string.sub(ranges[3] or '', 2, 2)
			.. string.sub(ranges[4] or '', 2, 2)
end

local m_check = m_char^0 * m.P(-1)

function lib.P(v)
	if lpeg.type(v) == 'pattern' then
		-- no way of checking it's valid utf-8
		return v
	end
	if type(v) == 'number' then
		if v < 0 then
			return -lib.P(-v)
		elseif v < 1 then
			return m.P(0)
		end
		local m_chars = m_char
		for i = 2, v do
			m_chars = m_chars * m_char
		end
		return m_chars
	end
	if type(v) == 'string' then
		if not m_check:match(v) then
			error('invalid utf-8 sequence', 2)
		end
		return m.P(v)
	end
	if type(v) == 'table' then
		local t = {}
		for k,v in pairs(v) do
			if k == 1 and type(v) == 'string' then
				t[1] = v
			else
				t[k] = lib.P(v)
			end
		end
		return m.P(t)
	end
	if type(v) == 'boolean' or type(v) == 'function' then
		return m.P(v)
	end	
	error('unsupported value for pattern', 2)
end

local prefix_char = m.C(m_char) * m.Cp()

function lib.B(patt)
	return m.B(lib.P(patt))
end

function lib.C(patt)
	return m.C(lib.P(patt))
end

function lib.Cf(patt, func)
	return m.Cf(lib.P(patt), func)
end

function lib.Cg(patt, name)
	return m.Cg(lib.P(patt), name)
end

function lib.Cs(patt)
	return m.Cs(lib.P(patt))
end

function lib.Ct(patt)
	return m.Ct(lib.P(patt))
end

function lib.Cmt(patt, func)
	return m.Cmt(lib.P(patt), func)
end

local function add_ranges(ranges, from_char, to_char)
	-- we don't need to do anything if from_char and to_char
	-- only differ by their final byte
	if #from_char ~= #to_char
	or (#from_char > 1 and from_char:sub(1, -2) ~= to_char:sub(1, -2)) then
		local min_char, max_char
		-- if this loop does not break/return, from_char is invalid
		for i = 1, #lib.byte_sequence_ranges do
			min_char = lib.byte_sequence_ranges[i].min
			max_char = lib.byte_sequence_ranges[i].max
			if from_char <= max_char then
				if to_char <= max_char then
					break
				end
				-- if lib.byte_sequence_ranges[i+1] is nil, to_char is invalid
				local next_min_char = lib.byte_sequence_ranges[i+1].min
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

local two_chars = lib.C(1) * lib.C(1) * m.P(-1)

local function next_char(c)
	if c == '' then
		return '\0'
	end
	local final_b = string.byte(c, -1)
	local rest = string.sub(c, 1, -2)
	if final_b == 0xff then
		return next_char(rest) .. '\0'
	end
	return rest .. string.char(final_b + 1)
end

local function sort_ranges(ranges)
	-- sort by the first character
	table.sort(ranges, function(a,b)  return a[1] < b[1];  end)
	-- combine touching/overlapping ranges
	local i = 1
	local range = ranges[i]
	if range == nil then
		return
	end
	repeat
		i = i + 1
		local next_range = ranges[i]
		while next_range ~= nil
		and (range[2] >= next_range[1] or next_char(range[2]) == next_range[1]) do
			if range[2] < next_range[2] then
				range[2] = next_range[2]
			end
			table.remove(ranges, i)
			next_range = ranges[i]
		end
		range = next_range
	until range == nil
end

local function find_common_range_prefix(rangeA, rangeB)
	if #rangeA[1] ~= #rangeB[1] then
		return nil
	end
	for i = 1, #rangeA[1] do
		if string.byte(rangeA[1], i) ~= string.byte(rangeA[2], i)
		or string.byte(rangeB[1], i) ~= string.byte(rangeB[2], i)
		or string.byte(rangeA[1], i) ~= string.byte(rangeB[1], i) then
			if i == 1 then
				return nil
			end
			return string.sub(rangeA[1], 1, i-1)
		end
	end
end

local function make_range_pattern(from_char, to_char, start_pos)
	local matcher = m.P(true)
	for i = start_pos or 1, #from_char do
		local from_b = string.byte(from_char, i)
		local to_b = string.byte(to_char, i)
		if from_b == to_b then
			matcher = matcher * m.P(string.char(from_b))
		else
			matcher = matcher * m.R(string.char(from_b, to_b))
		end
	end
	return matcher
end

local function aux_range_pattern(sorted_ranges, i)
	local range = sorted_ranges[i]
	if range == nil then
		return nil
	end
	i = i + 1
	local next_range = sorted_ranges[i]
	if next_range == nil then
		return make_range_pattern(range[1], range[2]), nil
	end
	local prefix = find_common_range_prefix(range, next_range)
	if prefix == nil then
		return make_range_pattern(range[1], range[2]), i
	end
	alt_suffix = {[prefix]={range, next_range}}
	i = i + 1
	next_range = sorted_ranges[i]
	while next_range ~= nil do
		prefix = find_common_range_prefix(range, next_range)
		if prefix == nil then
			break
		end
		local prefixed = alt_suffix[prefix]
		if prefixed == nil then
			prefixed = {}
			alt_suffix[prefix] = prefixed
		end
		prefixed[#prefixed+1] = next_range
		i = i + 1
		next_range = sorted_ranges[i]
	end
	local prefixes = {}
	for prefix in pairs(alt_suffix) do
		prefixes[#prefixes+1] = prefix
	end
	table.sort(prefixes, function(a,b)  return #a < #b;  end)
	local function get_suffix_pattern(i)
		local prefix = prefixes[i]
		if prefix == nil then
			return nil
		end
		local prefixed = alt_suffix[prefix]
		local next_prefix = prefixes[i + 1]
		local matcher = m.P(false)
		local pos = #(next_prefix or prefix) + 1
		for i = #prefixed, 1, -1 do
			local range = prefixed[i]
			matcher = make_range_pattern(range[1], range[2], pos) + matcher
		end
		if next_prefix == nil then
			return matcher
		end
		local chunk = string.sub(prefix, #next_prefix + 1)
		return m.P(chunk) * (get_suffix_pattern(i + 1) + matcher)
	end
	if next_range == nil then
		i = nil
	end
	return m.P(prefixes[1]) * get_suffix_pattern(1), i
end

local function make_ranges_pattern(sorted_ranges)
	local alternatives = {}

	local i = 1
	repeat
		local pattern; pattern, i = aux_range_pattern(sorted_ranges, i)
		if pattern == nil then
			break
		end
		alternatives[#alternatives+1] = pattern
	until i == nil

	local matcher = m.P(false)
	for i = #alternatives, 1, -1 do
		matcher = alternatives[i] + matcher
	end
	return matcher
end

function lib.R(...)
	local ranges = {}
	for i = 1, select('#', ...) do
		local pair = select(i, ...)
		local from_char, to_char = two_chars:match(pair)
		if from_char == nil then
			error('bad argument #' .. i .. ': expecting sequence of 2 utf-8 characters', 2)
		end
		add_ranges(ranges, from_char, to_char)
	end

	sort_ranges(ranges)

	local onebyte = m.P(false)
	while ranges[1] and #ranges[1][1] == 1 do
		local range = table.remove(ranges, 1)
		onebyte = onebyte + m.R(range[1] .. range[2])
	end

	return onebyte + make_ranges_pattern(ranges)
end

function lib.S(set)
	local ranges = {}

	local char
	local i = 1
	while i <= #set do
		char, i = prefix_char:match(set, i)
		if char == nil then
			error('invalid utf-8 sequence', 2)
		end
		add_ranges(ranges, char, char)
	end

	sort_ranges(ranges)

	local onebyte = m.P(false)
	while ranges[1] and #ranges[1][1] == 1 do
		local range = table.remove(ranges, 1)
		onebyte = onebyte + m.R(range[1] .. range[2])
	end

	return onebyte + make_ranges_pattern(ranges)
end

local chardef_proto = {}
local chardef_meta = {__index = chardef_proto}

function chardef_proto:compile()
	local ranges = {}

	local set = self.S
	if set ~= nil then

		local char
		local i = 1
		while i <= #set do
			char, i = prefix_char:match(set, i)
			if char == nil then
				error('invalid utf-8 sequence', 2)
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
			error('bad argument #' .. i .. ': expecting sequence of 2 utf-8 characters', 2)
		end
		add_ranges(ranges, from_char, to_char)
	end

	sort_ranges(ranges)

	local onebyte = m.P(false)
	while ranges[1] and #ranges[1][1] == 1 do
		local range = table.remove(ranges, 1)
		onebyte = onebyte + m.R(range[1] .. range[2])
	end

	return onebyte + make_ranges_pattern(ranges)
end

setmetatable(lib, {
	__call = function(self, def)
		return setmetatable(def or {R='\u{0}\u{10ffff}'}, chardef_meta)
	end;
})

return lib
