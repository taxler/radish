
local ffi = require 'ffi'
require 'exports.mswindows.guids'

ffi.cdef [[

	typedef struct WAVEFORMATEX {
		uint16_t wFormatTag;
		uint16_t nChannels;
		uint32_t nSamplesPerSec;
		uint32_t nAvgBytesPerSec;
		uint16_t nBlockAlign;
		uint16_t wBitsPerSample;
		uint16_t cbSize;
	} WAVEFORMATEX;

	#pragma pack(1)
	typedef struct WAVEFORMATEXTENSIBLE {
        uint16_t wFormatTag;
        uint16_t nChannels;
        uint32_t nSamplesPerSec;
        uint32_t nAvgBytesPerSec;
        uint16_t nBlockAlign;
        uint16_t wBitsPerSample;
        uint16_t cbSize;
        uint16_t wValidBitsPerSample;
        uint32_t dwChannelMask;
        GUID SubFormat;
	} WAVEFORMATEXTENSIBLE;
	#pragma pack(pop)

	enum {
		WAVE_FORMAT_PCM        = 0x0001,
		WAVE_FORMAT_EXTENSIBLE = 0xFFFE
	};

]]

return ffi.C
