
local strbyte, strchar = string.byte, string.char
local strsub = string.sub

local contiguous_byte_ranges = require 'parse.char.utf8.data.contiguous_byte_ranges'
local blob_tools = require 'parse.blob.tools'
local next_blob = blob_tools.next
local previous_blob = blob_tools.previous

local special_next = {}
local special_previous = {}

for i = 2, #contiguous_byte_ranges do
	local current = contiguous_byte_ranges[i]
	local previous = contiguous_byte_ranges[i - 1]
	special_next[previous.max] = current.min
	special_previous[current.min] = previous.max
end

local tools = {}

local function next_80_BF(v)
	local last_byte = strbyte(v, -1)
	local rest = strsub(v, 1, -2)
	if last_byte == 0xBF then
		return next_80_BF(rest) .. '\x80'
	end
	return rest .. strchar(last_byte + 1)
end

local function next_char(v)
	if v == '\x7F' then
		return '\u{80}'
	elseif v < '\x7F' then
		return next_blob(v)
	end
	local last_byte = strbyte(v, -1)
	if last_byte ~= 0xBF then
		return next_blob(v)
	end
	local special = special_next[v]
	if special then
		return special
	end
	return next_80_BF(strsub(v,1,-2)) .. '\x80'
end
tools.next = next_char

local function previous_80_BF(v)
	local last_byte = strbyte(v, -1)
	local rest = strsub(v, 1, -2)
	if last_byte == 0x80 then
		return previous_80_BF(rest) .. '\xBF'
	end
	return rest .. strchar(last_byte - 1)
end

local function previous_char(v)
	if v == '\u{80}' then
		return '\x7F'
	elseif v < '\u{80}' then
		return previous_blob(v)
	end
	local last_byte = strbyte(v, -1)
	if last_byte ~= 0x80 then
		return previous_blob(v)
	end
	local special = special_previous[v]
	if special then
		return special
	end
	return previous_80_BF(strsub(v,1,-2)) .. '\xBF'
end
tools.previous = previous_char

local function range_aux(final_char, ref_char)
	local char = next_char(ref_char)
	if char > final_char then
		return nil
	end
	return char
end

function tools.range(from_char, to_char)
	return range_aux, to_char, previous_char(from_char)
end

return tools
