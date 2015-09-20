
local undefined_char = require 'parse.substitution.undefined_char'
local alias_to_identifier = require 'parse.substitution.charset.identifier'
local identifier_to_name = require 'parse.substitution.charset.primary_name'

local m = require 'lpeg'

local lib = {}

local cache_strict = setmetatable({}, {__mode = 'v'})
local cache_lax = setmetatable({}, {__mode = 'v'})

function lib.get_converter(alias, strict)
	local identifier = alias_to_identifier[alias]
	if identifier == nil then
		return nil, 'unknown charset: ' .. tostring(alias)
	end
	local cache
	if strict then
		cache = cache_strict
	else
		cache = cache_lax
	end
	local converter = cache[identifier]
	if converter ~= nil then
		return converter
	end
	local success, subs = pcall(require, 'parse.substitution.charset.' .. identifier)
	if not success then
		return nil, 'charset not supported: ' ..  identifier_to_name[identifier]
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
	cache[identifier] = matcher
	return matcher
end

setmetatable(lib, {
	__call = function(self, alias)
		return self.get_converter(alias)
	end;
})

return lib
