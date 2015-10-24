
local ffi = require 'ffi'

ffi.cdef [[

	void* AvSetMmThreadCharacteristicsW(const wchar_t* task_name, uint32_t* ref_index);

]]

return ffi.load 'avrt'
