
local ffi = require 'ffi'

local on_wait_object_signals = {}

local selflib = require 'radish.mswindows.exports'
local selfstate = selflib.radish_get_state()

function on_wait_object_signals:add(wait_object, handler)
	selfstate.wait_objects[selfstate.wait_object_count] = wait_object
	on_wait_object_signals[selfstate.wait_object_count] = handler
	selfstate.wait_object_count = selfstate.wait_object_count + 1
end

function on_wait_object_signals:remove(wait_object, handler)
	if type(wait_object) == 'number' then
		local index = wait_object
		if index < 0 or index >= selfstate.wait_object_count or index ~= math.floor(index) then
			return false
		end
		for i = index, selfstate.wait_object_count - 2 do
			selfstate.wait_objects[i] = selfstate.wait_objects[i + 1]
		end
		selfstate.wait_object_count = selfstate.wait_object_count - 1
		if index == 0 then
			on_wait_object_signals[0] = on_wait_object_signals[1]
			if on_wait_object_signals[1] ~= nil then
				table.remove(on_wait_object_signals, 1)
			end
		else
			table.remove(on_wait_object_signals, index)
		end
		return true
	end
	if type(wait_object) == 'function' then
		local handler = wait_object
		for i = 0, #on_wait_object_signals do
			if handler == on_wait_object_signals[i] then
				return self:remove(i)
			end
		end
		return
	end
	for i = 0, #on_wait_object_signals do
		if handler == on_wait_object_signals[i] and wait_object == selfstate.wait_objects[i] then
			return self:remove(i)
		end
	end
end

local on_other_events = require 'radish.mswindows.on_other_events'

on_other_events[selflib.WMRADISH_WAIT_OBJECT_SIGNALLED] = function(_, message, wparam, lparam)
	local handler = on_wait_object_signals[lparam]
	local result
	if handler ~= nil then
		result = handler(ffi.cast('void*', wparam))
	end
	if result == 'remove' then
		on_wait_object_signals:remove(lparam)
	end
end

return on_wait_object_signals
