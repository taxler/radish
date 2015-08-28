
local ffi = require 'ffi'

local on_wait_object_signals = {}

local selflib = require 'radish.mswindows.exports'
local selfstate = selflib.radish_get_state()

function on_wait_object_signals:add(wait_object, handler)
	selfstate.wait_objects[selfstate.wait_object_count] = wait_object
	on_wait_object_signals[selfstate.wait_object_count] = handler
	selfstate.wait_object_count = selfstate.wait_object_count + 1
end

local on_other_events = require 'radish.mswindows.on_other_events'

on_other_events[selflib.WMRADISH_WAIT_OBJECT_SIGNALLED] = function(_, message, wparam, lparam)
	local handler = on_wait_object_signals[lparam]
	local result
	if handler ~= nil then
		result = handler(ffi.cast('void*', wparam))
	end
	if result == 'remove' then
		for i = lparam, wait_object_count - 2 do
			selfstate.wait_objects[i] = selfstate.wait_objects[i + 1]
		end
		selfstate.wait_object_count = selfstate.wait_object_count - 1
		if lparam == 0 then
			on_wait_object_signals[0] = on_wait_object_signals[1]
			if on_wait_object_signals[1] ~= nil then
				table.remove(on_wait_object_signals, 1)
			end
		else
			table.remove(on_wait_object_signals, lparam)
		end
	end
end

return on_wait_object_signals
