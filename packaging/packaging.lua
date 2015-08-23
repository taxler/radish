
package.path = 'lua/?.lua;lua/?/init.lua'

local ffi = require 'ffi'


local TITLE = 'Pumpkins for Everyone'


local in_path = 'packaging/radish-runner.exe'
local temp_path = 'packaging/temp_output.exe'
local out_path = string.format('%s.exe', TITLE)

function package_error(msg)
	io.stderr:write([[/!\ ]] .. (msg or 'unknown error')..'\r\n')
	os.exit(1)
end

function package_assert(is_true, ...)
	if is_true then
		return is_true, ...
	end
	package_error( (...) )
end

function do_packaging(in_path, out_path, context)
	context:init(in_path)
	context:add_app_icon('universe/icon.(resolution @ 256,256).png')
	context:publish(out_path)
end

local context
if ffi.os == 'Windows' then
	context = {}

	local winfiles = require 'exports.mswindows.filesystem'

	function context:init(path)
		winfiles.copy(path, temp_path)
		self.path = temp_path
	end
	context.path = temp_path


	context.icons = {}
	function context:add_app_icon(image_path)
		local f = assert(io.open(image_path, 'rb'))
		local size = assert(tonumber(image_path:match('%d+')), 'icon size not found')
		self.icons[#self.icons+1] = {size=size, id=size, group_id=size, data=f:read('*a')}
		f:close()
	end
	function context:copy_file(from_path, to_path)
		return winfiles.copy(from_path, to_path, false)
	end
	
	function context:publish(out_path)
		local resource_update = require 'exports.mswindows.handles.resource_update'
		local resources = resource_update.begin(temp_path, true)

		for i, icon in ipairs(self.icons) do
			resources:add_icon(icon.id, icon.data)
			resources:add_icon_group(icon.group_id, {icon})
		end
		resources:add_icon_group(1, self.icons)

		resources:commit()
		winfiles.copy(self.path, out_path)
	end
end

if context == nil then
	error('sorry!! ' .. ffi.os .. ' platform not yet supported')
end

do_packaging(in_path, out_path, context)

os.execute (string.format('start "" "%s"', out_path))
