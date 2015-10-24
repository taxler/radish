
local ffi = require 'ffi'

ffi.cdef [[

  #pragma pack( push )
  #pragma pack( 2 )
  typedef struct GRPICONDIRENTRY {
    uint8_t bWidth, bHeight, bColorCount, bReserved;
    uint16_t wPlanes, wBitCount;
    uint32_t dwBytesInRes;
    uint16_t nID;
  } GRPICONDIRENTRY;
  typedef struct GRPICONDIR {
    uint16_t idReserved, idType, idCount;
    GRPICONDIRENTRY idEntries[?];
  } GRPICONDIR;
  #pragma pack( pop )

]]

return ffi.C
