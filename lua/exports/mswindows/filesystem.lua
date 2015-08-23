
local bit = require 'bit'
local ffi = require 'ffi'
require 'exports.typedef.bool32'
local winstr = require 'exports.mswindows.strings'
local handles = require 'exports.mswindows.handles'

ffi.cdef [[

	static const int MAX_PATH = 260;

	bool32 CopyFileW(const wchar_t* from_path, const wchar_t* to_path, bool32 fail_if_exists);

	typedef struct FILETIME {
		uint32_t dwLowDateTime, dwHighDateTime;
	} FILETIME;

	typedef struct WIN32_FIND_DATA_W {
		uint32_t dwFileAttributes;
		FILETIME ftCreationTime, ftLastAccessTime, ftLastWriteTime;
		uint32_t nFileSizeHigh, nFileSizeLow;
		uint32_t dwReserved0, dwReserved1;
		wchar_t  cFileName[MAX_PATH];
		wchar_t  cAlternateFileName[14];
	} WIN32_FIND_DATA_W;

	// unofficial struct for iterator
	typedef struct t_win32_file_search {
		WIN32_FIND_DATA_W data;
		void* handle;
	} t_win32_file_search;

	void* FindFirstFileW(const wchar_t* path, WIN32_FIND_DATA_W* out_data);
	bool32 FindNextFileW(void* handle, WIN32_FIND_DATA_W* out_data);
	bool32 FindClose(void* handle);

	enum {
		FILE_ATTRIBUTE_READONLY            = 0x00001,
		FILE_ATTRIBUTE_HIDDEN              = 0x00002,
		FILE_ATTRIBUTE_SYSTEM              = 0x00004,
		FILE_ATTRIBUTE_DIRECTORY           = 0x00010,
		FILE_ATTRIBUTE_ARCHIVE             = 0x00020,
		FILE_ATTRIBUTE_NORMAL              = 0x00080, // only when nothing else set
		FILE_ATTRIBUTE_TEMPORARY           = 0x00100,
		FILE_ATTRIBUTE_SPARSE_FILE         = 0x00200,
		FILE_ATTRIBUTE_REPARSE_POINT       = 0x00400,
		FILE_ATTRIBUTE_COMPRESSED          = 0x00800,
		FILE_ATTRIBUTE_OFFLINE             = 0x01000,
		FILE_ATTRIBUTE_NOT_CONTENT_INDEXED = 0x02000,
		FILE_ATTRIBUTE_ENCRYPTED           = 0x04000,
		FILE_ATTRIBUTE_INTEGRITY_STREAM    = 0x08000,
		FILE_ATTRIBUTE_NO_SCRUB_DATA       = 0x20000
	};

]]

local kernel32 = ffi.C

local t_win32_file_search = ffi.metatype('t_win32_file_search', {
	__new = function(t_win32_file_search, path)
		local search = ffi.new(t_win32_file_search)
		search.handle = kernel32.FindFirstFileW(winstr.wide(path), search.data)
		if handles.is_invalid( search.handle ) then
			search.data.cFileName[0] = 0
		end
		return search
	end;
	__index = {
		peek = function(self)
			if self.data.cFileName[0] == 0 then
				return
			end
			local filetype
			if 0 == bit.band(kernel32.FILE_ATTRIBUTE_DIRECTORY, self.data.dwFileAttributes) then
				filetype = 'file'
			else
				filetype = 'directory'
			end
			local path = winstr.utf8(self.data.cFileName)
			return filetype, path
		end;
		move_next = function(self)
			if handles.is_invalid( self.handle ) then
				return false
			end
			local result = kernel32.FindNextFileW( self.handle, self.data )
			if not result then
				self:destroy()
				return false
			end
			return true
		end;
		destroy = function(self)
			self.data.cFileName[0] = 0
			if not handles.is_invalid( self.handle ) then
				kernel32.FindClose(self.handle)
				self.handle = handles.get_invalid()
			end
		end;
	};
	__call = function(self)
		local filetype, path = self:peek()
		if filetype == nil then
			return
		end
		self:move_next()
		return filetype, path
	end;
	__gc = function(self)
		self:destroy()
	end;
})

return {
	MAX_PATH = kernel32.MAX_PATH;
	copy = function(from_path, to_path, fail_if_exists)
		return kernel32.CopyFileW(
			winstr.wide(from_path),
			winstr.wide(to_path),
			not not fail_if_exists)
	end;
	dir = function(path)
		if path:sub(-1):match('[\\/]') then
			path = path:sub(1, -2)
		end
		if not path:match('[%?%*]') then
			path = path .. '\\*'
		end
		return t_win32_file_search(path)
	end;
}
