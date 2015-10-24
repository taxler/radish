
local ffi = require 'ffi'
local on_thread_events = require 'radish.mswindows.on_thread_events'
local comms = require 'radish.mswindows.task.comms'
local winstr = require 'exports.mswindows.strings'

local task_client = {}

function task_client.spawn_worker()
	local worker = on_thread_events.spawn_thread('worker_thread.lua')
	function worker:send_command(...)
		self:send_message(comms.serialize(...))
	end
	function worker:on_response(...)
	end
	function worker:on_message(message)
		self:on_response(comms.deserialize(message))
	end
	return worker
end

return task_client
