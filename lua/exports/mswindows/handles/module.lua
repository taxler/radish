
local ffi = require 'ffi'
local mswin = require 'exports.mswindows'
local winres = require 'exports.mswindows.resources'
local winstr = require 'exports.mswindows.strings'
local winlang = require 'exports.mswindows.languages'
local module = {}

function module.make_int_resource(int_resource)
	return ffi.cast('const wchar_t*', int_resource)
end

module.ctype = ffi.metatype('MODULE', {
	__index = {
		get_resource = function(resource_type, name, language)
			if type(resource_type) == 'number' then
				resource_type = module.make_int_resource(resource_type)
			elseif type(resource_type) == 'string' then
				resource_type = winstr.wide(resource_type)
			end
			if type(name) == 'number' then
				name = module.make_int_resource(name)
			elseif type(name) == 'string' then
				name = winstr.wide(name)
			end
			local res
			if language then
				res = winres.FindResourceW(self, name, resource_type)
			else
				res = winres.FindResourceW(self, name, resource_type, winlang[language])
			end
			if res == nil then
				return nil, 'resource not found'
			end
			local loaded = winres.LoadResource(self, res)
			if loaded == nil then
				return nil, 'unable to load resource'
			end
			local locked = winres.LockResource(loaded)
			if locked == nil then
				return nil, 'unable to lock resource'
			end
			return ffi.string(locked, winres.SizeofResource(self, res))
		end;
	};
})

module.current = mswin.GetModuleHandleW(nil)

return module
