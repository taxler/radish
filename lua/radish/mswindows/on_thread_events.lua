
local ffi = require 'ffi'
local winstr = require 'exports.mswindows.strings'
local selflib = require 'radish.mswindows.exports'
local on_other_events = require 'radish.mswindows.on_other_events'

local on_thread_events = {}

local thread_events_proto = {}
local thread_events_meta = {__index = thread_events_proto}

function thread_events_proto:on_terminated(dead_radish)
	-- to be overridden!
end

function thread_events_proto:on_message(message)
	-- to be overridden!
end

local waiting_messages = setmetatable({}, {__mode = 'k'})

function thread_events_proto:send_message(message)
	selflib.radish_send_thread(self.id, message, #message)
end

function thread_events_proto:on_ready()
	-- to be overridden!
end

local function unready_send(self, message)
	local waiting = waiting_messages[self]
	if waiting == nil then
		waiting = {}
		waiting_messages[self] = waiting
	end
	waiting[#waiting + 1] = message
end

function on_thread_events.spawn_thread(launch_script_name)
	local thread_id = selflib.radish_create_thread(winstr.wide(launch_script_name))
	local events = setmetatable({id=thread_id, send_message=unready_send}, thread_events_meta)
	on_thread_events[thread_id] = events
	return events
end

on_other_events[selflib.WMRADISH_THREAD_TERMINATED] = function(hwnd, message, wparam, lparam)
	local events = on_thread_events[wparam]
	if events == nil then
		return
	end
	on_thread_events[wparam] = nil
	local dead_radish = ffi.cast('radish_state*', lparam)
	local error_message = (dead_radish.error ~= nil) and winstr.utf8(dead_radish.error) or nil
	events:on_terminated(error_message, dead_radish)
end

on_other_events[selflib.WMRADISH_THREAD_READY] = function(hwnd, message, wparam, lparam)
	local events = on_thread_events[wparam]
	if events == nil then
		return
	end
	events:on_ready()
	-- take away the temporary send_message that queues to waiting_messages
	events.send_message = nil
	local waiting = waiting_messages[events]
	if waiting ~= nil then
		waiting_messages[events] = nil
		for i = 1, #waiting do
			local message = waiting[i]
			selflib.radish_send_thread(wparam, message, #message)
		end
	end
end

on_other_events[selflib.WMRADISH_THREAD_SEND_DATA] = function(hwnd, message, wparam, lparam)
	local events = on_thread_events[wparam]
	if events == nil then
		return
	end
	local buf = ffi.cast('radish_buffer*', lparam)
	local data = ffi.string(buf.data, buf.length)
	events:on_message(data)
end

return on_thread_events
