
local ffi = require 'ffi'
require 'exports.mswindows.media.foundation'

ffi.cdef [[

	int32_t MFCreateSourceReaderFromURL(
		const wchar_t* path,
		IMFAttributes*,
		IMFSourceReader** out_reader);

	int32_t MFCreateSourceReaderFromByteStream(
		IMFByteStream*,
		IMFAttributes*,
		IMFSourceReader** out_reader);
]]

return ffi.load 'Mfreadwrite'
