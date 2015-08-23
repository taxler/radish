
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

function do_packaging(resources)
	local icons = {}
	do
		local f = assert(io.open('universe/icon.(resolution @ 256,256).png', 'rb'))
		icons[#icons+1] = {size=256, id=256, data=f:read('*a')}
		f:close()
	end
	for i, icon in ipairs(icons) do
		resources:add_icon(icon.id, icon.data)
	end
	resources:add_icon_group(1, icons)
end

if ffi.os == 'Windows' then
	local mswin = require 'exports.mswindows'
	local winfiles = require 'exports.mswindows.filesystem'
	assert(winfiles.copy(in_path, temp_path, false), 'unable to copy file')
	local resource_update = require 'exports.mswindows.handles.resource_update'
	local resources = resource_update.begin(temp_path, true)
	do_packaging(resources)
	resources:commit()
	assert(winfiles.copy(temp_path, out_path, false), 'unable to copy file')
else
	error('sorry!! ' .. ffi.os .. ' platform not yet supported')
end

os.execute (string.format('start "" "%s"', out_path))
