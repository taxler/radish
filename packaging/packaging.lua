
package.path = 'lua/?.lua;lua/?/init.lua'

local ffi = require 'ffi'


local TITLE = 'Pumpkins for Everyone'


local in_path = 'packaging/win32-runner/radish-runner.exe'
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
	local winres = require 'exports.mswindows.resources'
	local winmodule = require 'exports.mswindows.handles.module'

	local fixed_file_info = winres.VS_FIXEDFILEINFO()
	local version_info_strings = {
		-- Comments
		CompanyName = 'The Creator';
		FileDescription = TITLE;
		FileVersion = '1.0.0.0';
		InternalName = TITLE;
		-- LegalCopyright
		-- LegalTrademarks
		OriginalFilename = out_path;
		-- PrivateBuild - VS_FF_PRIVATEBUILD
		ProductName = TITLE;
		ProductVersion = '1.0.0.0';
		-- SpecialBuild - VS_FF_SPECIALBUILD
	}
	function context:set_title(title)
		version_info_strings['FileDescription'] = TITLE
	end
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

		local version_info_string_blocks = {}

		for k,v in pairs(version_info_strings) do
			version_info_string_blocks[#version_info_string_blocks+1] = {
				name = k;
				text = v;
			}
		end

		local data = winres.encode_block {
			name = 'VS_VERSION_INFO';
			bytes = fixed_file_info:get_data();
			{
				name = 'StringFileInfo';
				text = '';
				{
					name = string.format('%04x%04x', 0x0409, 0x04b0);
					text = '';
					unpack(version_info_string_blocks);
				};
			};
			{
				name = 'VarFileInfo';
				text = '';
				{
					name = 'Translation';
					bytes = string.char(0x09, 0x04, 0xb0, 0x04);
				};
			};
		}

		resources:add(winres.RT_VERSION, winres.VS_VERSION_INFO, data)

		local function do_module_folder(path, prefix)
			for path_type, name in winfiles.dir(path) do
				if path_type == 'folder' then
					if name ~= '.' and name ~= '..' then
						do_module_folder(
							path .. '\\' .. name,
							prefix .. name .. '.')
					end
				else
					local script_name = name:match('^(.-)%.[lL][uU][aA]$')
					if script_name then
						local module_name
						if script_name:lower() == 'init' then
							module_name = prefix:match('^(.-)%.?$')
						else
							module_name = prefix .. script_name
						end
						local f = assert(io.open(path .. '\\' .. name, 'rb'))
						local data = f:read('*a')
						f:close()
						resources:add('LUA', module_name, data)
					end
				end
			end
		end

		do_module_folder('lua', '')

		resources:add('INIT', 'MAIN.LUA', [[

local boot = require 'radish.mswindows.boot'

boot.main_loop()

]])

		resources:add('INIT', 'TEST_THREAD.LUA', [[

local thread = require 'radish.mswindows.test_thread'

thread.main_loop()

]])

		local selflib_exports_buf = {[=[

local ffi = require 'ffi'
require 'exports.mswindows'

ffi.cdef [[

]=]}
		
		local parts = {}
		local part_priority = {}

		for type, header_name in winfiles.dir('packaging/win32-runner/radish-*.h') do
			local f = assert(io.open('packaging/win32-runner/' .. header_name, 'rb'))
			local data = f:read('*a')
			f:close()
			for part in data:gmatch('@+%s*BEGIN%s*:%s*EXPORTS%s*@+(.-)@+END%s*:%s*EXPORTS%s*@+') do
				local priority = 0
				part = part:gsub('@+%s*ORDER%s*:%s*(%-?%d+)%s*@+', function(pri)
					priority = tonumber(pri)
				end)
				parts[#parts + 1] = part
				part_priority[part] = priority
			end
		end

		table.sort(parts, function(a, b)
			return part_priority[a] < part_priority[b]
		end)

		for i = 1, #parts do
			selflib_exports_buf[#selflib_exports_buf+1] = parts[i]
		end
		
		selflib_exports_buf[#selflib_exports_buf+1] = [=[

]]

return ffi.C

]=]
		
		resources:add('LUA', 'RADISH.MSWINDOWS.EXPORTS', table.concat(selflib_exports_buf))

		resources:commit()
		winfiles.copy(self.path, out_path)
		winfiles.copy('packaging/lua51.dll', 'lua51.dll', true)
	end
end

if context == nil then
	error('sorry!! ' .. ffi.os .. ' platform not yet supported')
end

do_packaging(in_path, out_path, context)

os.execute (string.format('start "" "%s"', out_path))
