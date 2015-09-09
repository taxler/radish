
local bit = require 'bit'
local ffi = require 'ffi'
require 'exports.typedef.bool32'
require 'exports.mswindows'
local winstr = require 'exports.mswindows.strings'
local handles = require 'exports.mswindows.handles'

ffi.cdef [[

	static const int MAX_PATH = 260;

	bool32 CopyFileW(const wchar_t* from_path, const wchar_t* to_path, bool32 fail_if_exists);
	enum {
		MOVEFILE_REPLACE_EXISTING = 1, // can't be used to replace a directory/with a directory
		MOVEFILE_COPY_ALLOWED = 2, // on trying to move to a different volume, simulate with copy & delete
		MOVEFILE_DELAY_UNTIL_REBOOT = 4, // must be admin or the LocalSystem account
		MOVEFILE_WRITE_THROUGH = 8, // do not return until file actually written
		MOVEFILE_FAIL_IF_NOT_TRACKABLE = 0x20
	};
	bool32 MoveFileExW(const wchar_t* from_path, const wchar_t* to_path, uint32_t flags);

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
		FILE_NOTIFY_CHANGE_FILE_NAME = 0x00000001,
		FILE_NOTIFY_CHANGE_DIR_NAME = 0x00000002,
		FILE_NOTIFY_CHANGE_ATTRIBUTES = 0x00000004,
		FILE_NOTIFY_CHANGE_SIZE = 0x00000008,
		FILE_NOTIFY_CHANGE_LAST_WRITE = 0x00000010,
		FILE_NOTIFY_CHANGE_SECURITY = 0x00000100
	};

	typedef struct OVERLAPPED {
		uintptr_t Internal, InternalHigh;
		union {
			struct {
				uint32_t Offset, OffsetHigh;
			};
			void* Pointer;
		};
		void* hEvent;
	} OVERLAPPED;

	typedef void(*FileIOCompletionRoutine)(uint32_t error_code, uint32_t bytes_transferred, OVERLAPPED* ref_overlapped);
	
	void* FindFirstChangeNotificationW(const wchar_t* path, bool32 watch_subtree, uint32_t notify_filter);
	bool32 FindNextChangeNotification(void* handle);
	bool32 FindCloseChangeNotification(void* handle);
	bool32 ReadDirectoryChangesW(
		void* handle,
		void* out_buf, uint32_t buf_len,
		bool32 watch_subtree,
		uint32_t notify_filter,
		uint32_t* out_buf_bytes_written,
		OVERLAPPED* ref_overlapped,
		FileIOCompletionRoutine);

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

	bool32 CreateDirectoryW(const wchar_t* path, SECURITY_ATTRIBUTES*);

	bool32 FileTimeToSystemTime(const FILETIME*, SYSTEMTIME* out_systime);

]]

local kernel32 = ffi.C

local temp_systime = ffi.new 'SYSTEMTIME'
local function get_filetime_string(filetime)
	if filetime.dwLowDateTime == 0 and filetime.dwHighDateTime == 0 then
		return nil
	end
	if false == kernel32.FileTimeToSystemTime(filetime, temp_systime) then
		return nil
	end
	if temp_systime.wMilliseconds == 0 then
		return string.format('%4d-%02d-%02dT%02d:%02d:%02dZ',
			temp_systime.wYear, temp_systime.wMonth, temp_systime.wDay,
			temp_systime.wHour, temp_systime.wMinute, temp_systime.wSecond)
	else
		return string.format('%4d-%02d-%02dT%02d:%02d:%02d.%03dZ',
			temp_systime.wYear, temp_systime.wMonth, temp_systime.wDay,
			temp_systime.wHour, temp_systime.wMinute, temp_systime.wSecond,
			temp_systime.wMilliseconds)
	end
end

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
				filetype = 'folder'
			end
			local path = winstr.utf8(self.data.cFileName)
			return filetype, path
		end;
		get_name = function(self)
			if self.data.cFileName[0] == 0 then
				return nil
			end
			return winstr.utf8(self.data.cFileName)
		end;
		get_size = function(self)
			if self.data.cFileName[0] == 0 then
				return nil
			end
			local low = self.data.nFileSizeLow
			local high = self.data.nFileSizeHigh
			if high == 0 then
				return low
			elseif high < 2^(53-32) + 1 then
				return low + (high * 0x100000000)
			elseif high < 2^31 + 1 then
				return bit.bor(low + 0LL, bit.lshift(high + 0LL, 32))
			else
				return bit.bor(low + 0ULL, bit.lshift(high + 0ULL, 32))
			end
		end;
		get_when_last_modified = function(self)
			if self.data.cFileName[0] == 0 then
				return nil
			end
			return get_filetime_string(self.data.ftLastWriteTime)
		end;
		get_when_created = function(self)
			if self.data.cFileName[0] == 0 then
				return nil
			end
			return get_filetime_string(self.data.ftCreationTime)
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

local function type_at_path(path)
	local search_data = ffi.new 'WIN32_FIND_DATA_W'
	local search_handle = kernel32.FindFirstFileW(winstr.wide(path), search_data)
	if handles.is_invalid( search_handle ) then
		return nil
	end
	local result
	if 0 == bit.band(kernel32.FILE_ATTRIBUTE_DIRECTORY, search_data.dwFileAttributes) then
		result = 'file'
	else
		result = 'folder'
	end
	kernel32.FindClose(search_handle)
	return result
end

local function ensure_folder(path)
	-- strip final slash
	path = string.match(path, '^(.-)[\\/]?$')
	local path_type = type_at_path(path)
	if path_type == 'folder' then
		return true
	elseif path_type ~= nil then
		return false
	end
	local parent_path, final_part = string.match(path, '^(.+)[\\/]([^\\/]+)$')
	if parent_path == nil then
		final_part = path
	elseif not ensure_folder(parent_path) then
		return false
	end
	if string.match(final_part, '[\\/:*?<>|]') then
		return false
	end
	local result = kernel32.CreateDirectoryW(winstr.wide(path), nil)
	return result
end

return {
	MAX_PATH = kernel32.MAX_PATH;
	copy = function(from_path, to_path, fail_if_exists)
		return kernel32.CopyFileW(
			winstr.wide(from_path),
			winstr.wide(to_path),
			not not fail_if_exists)
	end;
	move = function(from_path, to_path, fail_if_exists)
		return kernel32.MoveFileExW(
			winstr.wide(from_path),
			winstr.wide(to_path),
			(fail_if_exists and 0 or kernel32.MOVEFILE_REPLACE_EXISTING)
			+ kernel32.MOVEFILE_COPY_ALLOWED
			+ kernel32.MOVEFILE_WRITE_THROUGH)
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
	type_at_path = type_at_path;
	ensure_folder = ensure_folder;
	same_contents = function(path1, path2)
		local f1 = io.open(path1, 'rb')
		if f1 == nil then
			return false
		end
		local f2 = io.open(path2, 'rb')
		if f2 == nil then
			f1:close()
			return false
		end
		local BUF_SIZE = 1024 * 16
		while true do
			local chunk1 = f1:read(BUF_SIZE)
			local chunk2 = f2:read(BUF_SIZE)
			if chunk1 ~= chunk2 then
				f1:close()
				f2:close()
				return false
			end
			if chunk1 == nil or (#chunk1 < BUF_SIZE) then
				f1:close()
				f2:close()
				return true
			end
		end
	end;
}
