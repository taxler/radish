
local ffi = require 'ffi'

local checks = {}

local function get_error_message(v)
	-- TODO: windows error formatting
	return string.format('error code 0x%08X', v)
end

function checks.success(v)
	if v == 0 then
		return true
	else
		return false, get_error_message(v)
	end
end

function checks.out(type, callback)
	local output = ffi.new(ffi.typeof('$[1]', ffi.typeof(type)))
	local result = callback(output)
	if output[0] ~= 0 then
		return output[0]
	elseif result == 0 then
		return nil
	else
		return nil, get_error_message(result)
	end
end

function checks.out_struct(type, callback)
	local output = ffi.new(type)
	local result = callback(output)
	if result == 0 then
		return output
	else
		return nil, get_error_message(result)
	end
end

return checks
