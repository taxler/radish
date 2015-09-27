
local blob_tools = {}

local function next_blob(v)
	if v == '' then
		return '\0'
	end
	local final_b = string.byte(v, -1)
	local rest = string.sub(v, 1, -2)
	if final_b == 0xff then
		return next_blob(rest) .. '\0'
	end
	return rest .. string.char(final_b + 1)
end
blob_tools.next = next_blob

local function previous_blob(v)
	if v == '\0' then
		return ''
	elseif v == '' then
		error('cannot get previous blob for zero-length blob', 2)
	end
	local final_b = string.byte(v, -1)
	local rest = string.sub(v, 1, -2)
	if final_b == 0x00 then
		return previous_blob(rest) .. '\xff'
	end
	return rest .. string.char(final_b - 1)
end
blob_tools.previous = previous_blob

function blob_tools.range_iterator(from_blob, to_blob, step)
	if step == 1 then
		return function()
			local result = from_blob
			if result > to_blob then
				return
			end
			from_blob = next_blob(from_blob)
			return result
		end
	end
end

return blob_tools
