
local ffi = require 'ffi'
local crt = require 'exports.crt'
require 'exports.xiph.vorbis.file'

ffi.cdef [[

	int fseek64_wrap(FILE*, int64_t off, int whence);

]]

local fseek64_wrap
if pcall(function()  assert(ffi.C.fseek64_wrap ~= nil)  end) then
	fseek64_wrap = ffi.C.fseek64_wrap
else
	fseek64_wrap = ffi.cast('int(*)(FILE*, int64_t, int)', function(f, off, whence)
		if f == nil then
			return -1
		end
		return crt.fseek(f, ffi.cast('long', off), whence)
	end)
end

local ov_callbacks = ffi.typeof 'ov_callbacks'

return {
	fseek64_wrap = fseek64_wrap;
	DEFAULT = ov_callbacks {
		read_func = crt.fread;
		seek_func = fseek64_wrap;
		close_func = crt.fclose;
		tell_func = crt.ftell;
	};
	NOCLOSE = ov_callbacks {
		read_func = crt.fread;
		seek_func = fseek64_wrap;
		close_func = nil;
		tell_func = crt.ftell;
	};
	STREAMONLY = ov_callbacks {
		read_func = crt.fread;
		seek_func = nil;
		close_func = crt.fclose;
		tell_func = nil;
	};
	STREAMONLY_NOCLOSE = ov_callbacks {
		read_func = crt.fread;
		seek_func = nil;
		close_func = nil;
		tell_func = nil;
	};
}
