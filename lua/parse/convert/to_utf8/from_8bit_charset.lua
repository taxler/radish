
local undefined_char = require 'parse.substitution.undefined_char'

local m = require 'lpeg'

local lib = {}

local cache_strict = {}
local cache_lax = {}

function lib.get_converter(charset_name, strict)
	local cache
	if strict then
		cache = cache_strict
	else
		cache = cache_lax
	end
	local converter = cache[charset_name]
	if converter ~= nil then
		return converter
	end
	local success, subs = assert(pcall(require, 'parse.substitution.charset.' .. charset_name))
	if not success then
		return nil, 'unable to find charset mapping'
	end
	local same = {}
	local replace = {}
	local undefined = {}
	for map_from, map_to in pairs(subs) do
		if map_from == map_to then
			same[#same+1] = map_from
		elseif map_to == undefined_char then
			undefined[#undefined+1] = map_from
		else
			replace[#replace+1] = map_from
		end
	end
	same = m.S(table.concat(same))^1
	replace = m.S(table.concat(replace))
	undefined = m.S(table.concat(undefined))
	local matcher = same + (replace / subs)
	if not strict then
		matcher = matcher + (undefined / undefined_char)
	end
	matcher = m.Cs(matcher^0)
	cache[charset_name] = matcher
	return matcher
end

setmetatable(lib, {
	__call = function(self, charset_name)
		return self.get_converter(charset_name)
	end;
})

return lib
