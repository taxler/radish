
local lib = {}
package.loaded[(...)] = lib

local ffi = require 'ffi'
local mswin = require 'exports.mswindows'
local winres = require 'exports.mswindows.resources'
local winstr = require 'exports.mswindows.strings'
local winlang = require 'exports.mswindows.languages'
local module = {}

lib.ctype = ffi.metatype('MODULE', {
	__index = {
		get_resource = winres.get_for_module;
	};
})

lib.current = mswin.GetModuleHandleW(nil)

return lib
