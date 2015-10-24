
local lib = {}

local ffi = require 'ffi'
local mswin = require 'exports.mswindows'
local winres = require 'exports.mswindows.resources'
local winstr = require 'exports.mswindows.strings'
local winlang = require 'exports.mswindows.languages'
local module = {}

local kernel32 = ffi.C

lib.ctype = ffi.metatype('MODULE', {
	__index = {
		get_resource = assert(winres.get_for_module);
		free = kernel32.FreeLibrary;
	};
})

lib.current = mswin.GetModuleHandleW(nil)

function lib.get(path)
	local module = mswin.GetModuleHandleW(winstr.wide(path))
	if module == nil then
		return nil
	end
	return module
end

function lib.open(path)
	local module = mswin.LoadLibraryW(winstr.wide(path))
	if module == nil then
		return nil
	end
	return module
end

return lib
