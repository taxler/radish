
local ffi = require 'ffi'
local winres = require 'exports.mswindows.resources'
local winstr = require 'exports.mswindows.strings'
local winlang = require 'exports.mswindows.languages'
require 'exports.mswindows.handles'
require 'exports.mswindows.media.icons'

local resource_update = {}

function resource_update.make_int_resource(int_resource)
	return ffi.cast('const wchar_t*', int_resource)
end

resource_update.RT_ICON = resource_update.make_int_resource(3)
resource_update.RT_GROUP_ICON = resource_update.make_int_resource(14)

resource_update.ctype = ffi.metatype('RESOURCE_UPDATE_W', {
	__index = {
		add = function(self, resource_type, name, data, data_length, language)
			language = winlang[language]
			if type(resource_type) == 'string' then
				resource_type = winstr.wide(resource_type)
			elseif type(resource_type) == 'number' then
				resource_type = resource_update.make_int_resource(resource_type)
			end
			if type(name) == 'string' then
				name = winstr.wide(name)
			elseif type(name) == 'number' then
				name = resource_update.make_int_resource(name)
			end
			if data_length == nil then
				if type(data) == 'string' then
					data_length = #data
				else
					error('data length must be given', 2)
				end
			end
			return winres.UpdateResourceW(
				self,
				resource_type,
				name,
				language,
				ffi.cast('void*', data),
				data_length)
		end;
		add_icon = function(self, id, data)
			return self:add(
				resource_update.RT_ICON,
				resource_update.make_int_resource(id),
				data)
		end;
		add_icon_group = function(self, id, icons)
			local icongroup = ffi.new('GRPICONDIR', #icons, {
				idType = 1;
				idCount = #icons;
			})
			for i, icon in ipairs(icons) do
				icongroup.idEntries[i-1] = {
					bWidth = icon.size;
					bHeight = icon.size;
					dwBytesInRes = #icon.data;
					wBitCount = 32;
					wPlanes = 1;
					nID = icon.id;
				}
			end
			return self:add(
				resource_update.RT_GROUP_ICON,
				resource_update.make_int_resource(id),
				icongroup,
				ffi.sizeof(icongroup))
		end;
		remove = function(self, resource_type, name, language)
			return self:add(resource_type, name, nil, 0, language)
		end;
		commit = function(self)
			return winres.EndUpdateResourceW(self, false)
		end;
		discard = function(self)
			return winres.EndUpdateResourceW(self, true)
		end;
	};
})

function resource_update.begin(path, delete_existing)
	local handle = winres.BeginUpdateResourceW(winstr.wide(path), not not delete_existing)
	if handle == nil then
		return nil
	end
	return handle
end

return resource_update
