
local ffi = require 'ffi'
local crt = require 'exports.crt'
require 'exports.typedef.bool32'

ffi.cdef [[

	int WideCharToMultiByte(
		uint32_t codePage,
		uint32_t flags,
		const wchar_t* wide,
		int wide_count,
		char* out_multibyte,
		int multibyte_count,
		const char* defaultChar,
		bool32* out_usedDefaultChar);
  
	int MultiByteToWideChar(
		uint32_t codePage,
		uint32_t flags,
		const char* str,
		int sizeBytes,
		wchar_t* out_wstring,
		int wstring_size);

]]

local kernel32 = ffi.C

return {

	wide = function(utf8, return_size)
		local len = #utf8 + 1
		local buf_size = kernel32.MultiByteToWideChar(65001, 0, utf8, len, nil, 0)
		local buf = ffi.new('wchar_t[?]', buf_size)
		ffi.C.MultiByteToWideChar(65001, 0, utf8, len, buf, buf_size)
		if return_size then
			return buf, buf_size
		end
		return buf
	end;

	utf8 = function(ptr, len)
		ptr = ffi.cast('const wchar_t*', ptr)
		local buf_size = kernel32.WideCharToMultiByte(65001, 0, ptr, len or -1, nil, 0, nil, nil)
		if not len then
			buf_size = buf_size - 1
		end
		local buf = crt.malloc(buf_size)
		ffi.C.WideCharToMultiByte(65001, 0, ptr, len or -1, buf, buf_size, nil, nil)
		local str = ffi.string(buf, buf_size)
		crt.free(buf)
		return str
	end;

}
