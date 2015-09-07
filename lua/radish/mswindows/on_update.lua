
local on_other_events = require 'radish.mswindows.on_other_events'
local selflib = require 'radish.mswindows.exports'

local on_update = {}

local thread_ids = {}
local threads_by_id = {}

on_other_events[selflib.WMRADISH_UPDATE] = function(_, message, wparam, lparam)
	local ticks = wparam
	for thread, id in pairs(thread_ids) do
		local success, message = coroutine.resume(thread, ticks)
		if coroutine.status(thread) ~= 'suspended' then
			thread_ids[thread] = nil
			threads_by_id[id] = nil
		end
		if not success then
			error(message)
		end
	end
end

local function pause(ms)
	local count = 0
	repeat
		count = count + coroutine.yield()
	until count >= ms
	return count
end

local function update_coroproc(ms, callback)
	callback(pause)
end

function on_update.after(ms, callback)
	local coro = coroutine.create(update_coroproc)
	coroutine.resume(coro, ms, callback)
	local id = #threads_by_id + 1
	threads_by_id[id] = coro
	thread_ids[coro] = id
end

return on_update
