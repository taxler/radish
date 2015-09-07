
local bit = require 'bit'
local ffi = require 'ffi'
local mswin = require 'exports.mswindows'
local winstr = require 'exports.mswindows.strings'
local winfiles = require 'exports.mswindows.filesystem'
local winhandles = require 'exports.mswindows.handles'
local on_wait_object_signal = require 'radish.mswindows.on_wait_object_signal'

local filewatching = {}

-- TODO: cancel sweep-scanner on notify and until a fixed time period (100ms?)
--   has elapsed since last change notification, do a full sweep and
--   restart the sweep-scanner
local function add_change_notifier(path, recursively)
	local universe_folder_change_notifier = mswin.FindFirstChangeNotificationW(
		winstr.wide(path),
		recursively,
		bit.bor(
			mswin.FILE_NOTIFY_CHANGE_FILE_NAME,
			mswin.FILE_NOTIFY_CHANGE_DIR_NAME,
			mswin.FILE_NOTIFY_CHANGE_SIZE,
			mswin.FILE_NOTIFY_CHANGE_LAST_WRITE))
	if universe_folder_change_notifier == nil
	or winhandles.is_invalid(universe_folder_change_notifier) then
		return false
	end
	on_wait_object_signal:add(universe_folder_change_notifier, function(handle)
		print 'a change was made!'
		if mswin.FindNextChangeNotification(handle) == false then
			print 'creating new notifier'
			add_change_notifier(path, recursively)
			return 'remove'
		end
	end)
	return true
end

function filewatching.watch(path, recursively)
	return add_change_notifier(path, recursively)
end

return filewatching
