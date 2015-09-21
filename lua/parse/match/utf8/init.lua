
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

function lib.S(set)
	local char
	local i = 1
	local matcher = m.P(false)
	-- TODO: put in a list, sort them, make use of common prefixes
	while pos < #set do
		char, i = prefix_char:match(set, i)
		if char == nil then
			error('invalid utf-8 sequence', 2)
		end
		matcher = matcher + char
	end
	return matcher
end

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

-- TODO: make more use of common prefix where possible
local function make_range(from_char, to_char)
	if from_char == to_char then
		return m.P(from_char)
	end
	if from_char <= '\u{7f}' then
		-- one-byte sequence
		if to_char >= '\u{80}' then
			return m.R(from_char .. '\u{7f}') + make_range('\u{80}', to_char)
		end
		return m.R(from_char .. to_char)
	end
	if from_char <= '\u{7ff}' then
		-- two-byte sequence
		if to_char >= '\u{800}' then
			return make_range(from_char, '\u{7ff}') + make_range('\u{800}', to_char)
		end
		local from_hi = string.sub(from_char, 1,1)
		local to_hi =   string.sub(to_char,   1,1)
		local from_lo = string.sub(from_char, 2,2)
		local to_lo =   string.sub(to_char,   2,2)
		if from_hi == to_hi then
			return m.P(from_hi) * m.R(from_lo .. to_lo)
		end
		if from_lo ~= '\x80' then
			local after_from_hi = string.char(string.byte(from_hi) + 1)
			return (m.P(from_hi) * m.R(from_lo .. '\xBF'))
				+ make_range(after_from_hi .. '\x80', to_char)
		end
		if to_lo ~= '\xBF' then
			local before_to_hi = string.char(string.byte(to_hi) - 1)
			return make_range(from_char, before_to_hi .. '\xBF')
				+ (m.P(to_hi) * m.R('\x80' .. to_lo))
		end
		return m.R(from_hi .. to_hi) * m.R('\x80\xBF')
	end
	if from_char <= '\u{fff}' then
		-- three byte sequence that starts with \xE0
		if to_char >= '\u{1000}' then
			return make_range(from_char, '\u{fff}') + make_range('\u{1000}', to_char)
		end
		local from_mid = string.sub(from_char, 2,2)
		local to_mid   = string.sub(to_char,   2,2)
		local from_lo  = string.sub(from_char, 3,3)
		local to_lo    = string.sub(to_char,   3,3)
		if from_mid == to_mid then
			return m.P('\xE0' .. from_mid) * m.R(from_lo .. to_lo)
		end
		if from_lo ~= '\x80' then
			local after_from_mid = string.char(string.byte(from_mid) + 1)
			return (m.P('\xE0' * from_mid) * m.R(from_lo .. '\xBF'))
				+ make_range('\xE0' .. after_from_mid .. '\x80', to_char)
		end
		if to_lo ~= '\xBF' then
			local before_to_mid = string.char(string.byte(to_mid) - 1)
			return make_range(from_char, '\xE0' .. before_to_mid .. '\xBF')
				+ (m.P('\xE0'..to_mid) * m.R('\x80' .. to_lo))
		end
		return m.P '\xE0' * m.R(from_mid .. to_mid) * m.R('\x80\xBF')
	end
	if from_char <= '\u{cfff}' then
		-- three byte sequence that starts with \xE1-\xEC
		if to_char >= '\u{d000}' then
			return make_range(from_char, '\u{cfff}') + make_range('\u{d000}', to_char)
		end
		local from_hi  = string.sub(from_char, 1,1)
		local to_hi    = string.sub(to_char,   1,1)
		local from_mid = string.sub(from_char, 2,2)
		local to_mid   = string.sub(to_char,   2,2)
		local from_lo  = string.sub(from_char, 3,3)
		local to_lo    = string.sub(to_char,   3,3)
		if from_hi ~= to_hi then
			if from_mid ~= '\x80' or from_lo ~= '\x80' then
				local after_from_hi = string.char(string.byte(from_hi) + 1)
				return make_range(from_char, from_hi .. '\xBF\xBF')
					+ make_range(after_from_hi .. '\x80\x80', to_char)
			end
			if to_mid ~= '\xBF' or to_lo ~= '\xBF' then
				local before_to_hi = string.char(string.byte(to_hi) - 1)
				return make_range(from_char, before_to_hi .. '\xBF\xBF')
					+ make_range(to_hi .. '\x80\x80', to_char)
			end
			return m.R(from_hi .. to_hi) * m.R('\x80\xBF') * m.R('\x80\xBF')
		end
		if from_mid == to_mid then
			return m.P(from_hi .. from_mid) * m.R(from_lo .. to_lo)
		end
		if from_lo ~= '\x80' then
			local after_from_mid = string.char(string.byte(from_mid) + 1)
			return (m.P(from_hi .. from_mid) * m.R(from_lo .. '\xBF'))
				+ make_range(from_hi .. after_from_mid .. '\x80', to_char)
		end
		if to_lo ~= '\xBF' then
			local before_to_mid = string.char(string.byte(to_mid) - 1)
			return make_range(from_char, from_hi .. before_to_mid .. '\xBF')
				+ (from_hi * m.P(to_mid) * m.R('\x80' .. to_lo))
		end
		return from_hi * m.R(from_mid .. to_mid) * m.R '\x80\xBF'
	end
	if from_char <= '\u{d7ff}' then
		-- three byte sequence that starts with \xED
		if to_char >= '\u{10000}' then
			return make_range(from_char, '\u{d7ff}') + make_range('\u{10000}', to_char)
		end
		local from_mid = string.sub(from_char, 2,2)
		local to_mid   = string.sub(to_char,   2,2)
		local from_lo  = string.sub(from_char, 3,3)
		local to_lo    = string.sub(to_char,   3,3)
		if from_mid == to_mid then
			return m.P('\xED' .. from_mid) * m.R(from_lo .. to_lo)
		end
		if from_lo ~= '\x80' then
			local after_from_mid = string.char(string.byte(from_mid) + 1)
			return (m.P('\xED' * from_mid) * m.R(from_lo .. '\xBF'))
				+ make_range('\xED' .. after_from_mid .. '\x80', to_char)
		end
		if to_lo ~= '\xBF' then
			local before_to_mid = string.char(string.byte(to_mid) - 1)
			return make_range(from_char, '\xED' .. before_to_mid .. '\xBF')
				+ (m.P('\xED'..to_mid) * m.R('\x80' .. to_lo))
		end
		return m.P '\xED' * m.R(from_mid .. to_mid) * m.R('\x80\xBF')
	end
	if from_char <= '\u{ffff}' then
		-- three byte sequence that starts with \xEE-\xEF
		if to_char >= '\u{10000}' then
			return make_range(from_char, '\u{ffff}') + make_range('\u{10000}', to_char)
		end
		local from_hi  = string.sub(from_char, 1,1)
		local to_hi    = string.sub(to_char,   1,1)
		local from_mid = string.sub(from_char, 2,2)
		local to_mid   = string.sub(to_char,   2,2)
		local from_lo  = string.sub(from_char, 3,3)
		local to_lo    = string.sub(to_char,   3,3)
		if from_hi ~= to_hi then
			if from_mid ~= '\x80' or from_lo ~= '\x80' then
				local after_from_hi = string.char(string.byte(from_hi) + 1)
				return make_range(from_char, from_hi .. '\xBF\xBF')
					+ make_range(after_from_hi .. '\x80\x80', to_char)
			end
			if to_mid ~= '\xBF' or to_lo ~= '\xBF' then
				local before_to_hi = string.char(string.byte(to_hi) - 1)
				return make_range(from_char, before_to_hi .. '\xBF\xBF')
					+ make_range(to_hi .. '\x80\x80', to_char)
			end
			return m.R(from_hi .. to_hi) * m.R('\x80\xBF') * m.R('\x80\xBF')
		end
		if from_mid == to_mid then
			return m.P(from_hi .. from_mid) * m.R(from_lo .. to_lo)
		end
		if from_lo ~= '\x80' then
			local after_from_mid = string.char(string.byte(from_mid) + 1)
			return (m.P(from_hi .. from_mid) * m.R(from_lo .. '\xBF'))
				+ make_range(from_hi .. after_from_mid .. '\x80', to_char)
		end
		if to_lo ~= '\xBF' then
			local before_to_mid = string.char(string.byte(to_mid) - 1)
			return make_range(from_char, from_hi .. before_to_mid .. '\xBF')
				+ (from_hi * m.P(to_mid) * m.R('\x80' .. to_lo))
		end
		return from_hi * m.R(from_mid .. to_mid) * m.R '\x80\xBF'
	end	
	if from_char <= '\u{3ffff}' then
		-- four byte sequence that starts with \xF0
		if to_char >= '\u{40000}' then
			return make_range(from_char, '\u{3ffff}') + make_range('\u{40000}', to_char)
		end
		local from_2  = string.sub(from_char, 2,2)
		local to_2    = string.sub(to_char,   2,2)
		local from_3  = string.sub(from_char, 3,3)
		local to_3    = string.sub(to_char,   3,3)
		local from_4  = string.sub(from_char, 4,4)
		local to_4    = string.sub(to_char,   4,4)
		if from_2 ~= to_2 then
			if from_3 ~= '\x80' or from_4 ~= '\x80' then
				local after_from_2 = string.char(string.byte(from_2) + 1)
				return make_range(from_char, '\xF0' .. from_2 .. '\xBF\xBF')
					+ make_range('\xF0' .. after_from_2 .. '\x80\x80', to_char)
			elseif to_3 ~= '\xBF' or to_4 ~= '\xBF' then
				local before_to_2 = string.char(string.byte(to_2) - 1)
				return make_range(from_char, '\xF0' .. before_to_2 .. '\xBF\xBF')
					+ make_range('\xF0' .. to_2 .. '\x80\x80', to_char)
			end
			return '\xF0' * m.R(from_2 .. to_2) * m.R('\x80\xBF') * m.R('\x80\xBF')
		end
		if from_3 == to_3 then
			return m.P('\xF0' .. from_2 .. from_3) * m.R(from_4 .. to_4)
		end
		if from_4 ~= '\x80' then
			local after_from_3 = string.char(string.byte(from_3) + 1)
			return (m.P('\xF0' .. from_2 .. from_3) * m.R(from_4 .. '\xBF'))
				+ make_range('\xF0' .. from_2 .. after_from_3 .. '\x80', to_char)
		end
		if to_4 ~= '\xBF' then
			local before_to_3 = string.char(string.byte(to_3) - 1)
			return make_range(from_char, '\xF0' .. from_2 .. before_to_3 .. '\xBF')
				+ (m.P('\xF0' .. from_2 .. to_3) * m.R('\x80' .. to_4))
		end
		return ('\xF0' .. from_2) * m.R(from_3 .. to_3) * m.R '\x80\xBF'
	end
	if from_char <= '\u{fffff}' then
		-- four byte sequence that starts with \xF1-\xF3
		if to_char >= '\u{100000}' then
			return make_range(from_char, '\u{fffff}') + make_range('\u{100000}', to_char)
		end
		local from_1  = string.sub(from_char, 1,1)
		local to_1    = string.sub(to_char,   1,1)
		local from_2  = string.sub(from_char, 2,2)
		local to_2    = string.sub(to_char,   2,2)
		local from_3  = string.sub(from_char, 3,3)
		local to_3    = string.sub(to_char,   3,3)
		local from_4  = string.sub(from_char, 4,4)
		local to_4    = string.sub(to_char,   4,4)
		if from_1 ~= to_1 then
			if from_2 ~= '\x80' or from_3 ~= '\x80' or from_4 ~= '\x80' then
				local after_from_1 = string.char(string.byte(from_1) + 1)
				return make_range(from_char, from_1 .. '\xBF\xBF\xBF')
					+ make_range(after_from_1 .. '\x80\x80\x80', to_char)
			elseif to_2 ~= '\xBF' or to_3 ~= '\xBF' or to_4 ~= '\xBF' then
				local before_to_1 = string.char(string.byte(to_1) - 1)
				return make_range(from_char, before_to_1 .. '\xBF\xBF\xBF')
					+ make_range(to_1 .. '\x80\x80\x80', to_char)
			end
			return m.R(from_1 .. to_1) * m.R('\x80\xBF') * m.R('\x80\xBF') * m.R('\x80\xBF')
		end
		if from_2 ~= to_2 then
			if from_3 ~= '\x80' or from_4 ~= '\x80' then
				local after_from_2 = string.char(string.byte(from_2) + 1)
				return make_range(from_char, from_1 .. from_2 .. '\xBF\xBF')
					+ make_range(from_1 .. after_from_2 .. '\x80\x80', to_char)
			elseif to_3 ~= '\xBF' or to_4 ~= '\xBF' then
				local before_to_2 = string.char(string.byte(to_2) - 1)
				return make_range(from_char, from_1 .. before_to_2 .. '\xBF\xBF')
					+ make_range(from_1 .. to_2 .. '\x80\x80', to_char)
			end
			return m.P(from_1) * m.R(from_2 .. to_2) * m.R('\x80\xBF') * m.R('\x80\xBF')
		end
		if from_3 == to_3 then
			return m.P(from_1 .. from_2 .. from_3) * m.R(from_4 .. to_4)
		end
		if from_4 ~= '\x80' then
			local after_from_3 = string.char(string.byte(from_3) + 1)
			return (m.P(from_1 .. from_2 .. from_3) * m.R(from_4 .. '\xBF'))
				+ make_range(from_1 .. from_2 .. after_from_3 .. '\x80', to_char)
		end
		if to_4 ~= '\xBF' then
			local before_to_3 = string.char(string.byte(to_3) - 1)
			return make_range(from_char, from_1 .. from_2 .. before_to_3 .. '\xBF')
				+ (m.P(from_1 .. from_2 .. to_3) * m.R('\x80' .. to_4))
		end
		return (from_1 .. from_2) * m.R(from_3 .. to_3) * m.R '\x80\xBF'
	end	
	do
		-- four byte sequence that starts with \xF4
		local from_2  = string.sub(from_char, 2,2)
		local to_2    = string.sub(to_char,   2,2)
		local from_3  = string.sub(from_char, 3,3)
		local to_3    = string.sub(to_char,   3,3)
		local from_4  = string.sub(from_char, 4,4)
		local to_4    = string.sub(to_char,   4,4)
		if from_2 ~= to_2 then
			if from_3 ~= '\x80' or from_4 ~= '\x80' then
				local after_from_2 = string.char(string.byte(from_2) + 1)
				return make_range(from_char, '\xF4' .. from_2 .. '\xBF\xBF')
					+ make_range('\xF4' .. after_from_2 .. '\x80\x80', to_char)
			elseif to_3 ~= '\xBF' or to_4 ~= '\xBF' then
				local before_to_2 = string.char(string.byte(to_2) - 1)
				return make_range(from_char, '\xF4' .. before_to_2 .. '\xBF\xBF')
					+ make_range('\xF4' .. to_2 .. '\x80\x80', to_char)
			end
			return '\xF4' * m.R(from_2 .. to_2) * m.R('\x80\xBF') * m.R('\x80\xBF')
		end
		if from_3 == to_3 then
			return m.P('\xF4' .. from_2 .. from_3) * m.R(from_4 .. to_4)
		end
		if from_4 ~= '\x80' then
			local after_from_3 = string.char(string.byte(from_3) + 1)
			return (m.P('\xF4' .. from_2 .. from_3) * m.R(from_4 .. '\xBF'))
				+ make_range('\xF4' .. from_2 .. after_from_3 .. '\x80', to_char)
		end
		if to_4 ~= '\xBF' then
			local before_to_3 = string.char(string.byte(to_3) - 1)
			return make_range(from_char, '\xF0' .. from_2 .. before_to_3 .. '\xBF')
				+ (m.P('\xF4' .. from_2 .. to_3) * m.R('\x80' .. to_4))
		end
		return ('\xF4' .. from_2) * m.R(from_3 .. to_3) * m.R '\x80\xBF'
	end	
end

local two_chars = lib.C(1) * lib.C(1) * m.P(-1)

function lib.R(...)
	local matcher = m.P(false)
	for i = select('#', ...), 1, -1 do
		local pair = select(i, ...)
		local from_char, to_char = two_chars:match(pair)
		if from_char == nil then
			error('bad argument #' .. i .. ': expecting sequence of 2 utf-8 characters', 2)
		end
		matcher = make_range(from_char, to_char) + matcher
	end
	return matcher
end

return lib
