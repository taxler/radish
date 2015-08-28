

local ffi = require 'ffi'
local com = require 'exports.mswindows.com'
require 'exports.mswindows.search'
require 'exports.mswindows.guids'
require 'exports.mswindows.filesystem'
require 'exports.mswindows.media'

com.predef 'IAdviseSink'
com.predef 'IDispatch'
com.predef 'IStream'
com.predef 'IStorage'
com.predef 'IRecordInfo'
com.predef 'ITypeComp'

ffi.cdef [[

	enum {
		STREAM_SEEK_SET   = 0,
		STREAM_SEEK_CUR   = 1,
		STREAM_SEEK_END   = 2 
	};
	
	typedef struct STATSTG {
		wchar_t* pwcsName;
		uint32_t type;
		uint64_t cbSize;
		FILETIME mtime, ctime, atime;
		uint32_t grfMode, grfLocksSupported;
		GUID clsid;
		uint32_t grfStateBits, reserved;
	} STATSTG;
  
	typedef struct COAUTHIDENTITY {
		uint16_t* User;
		uint32_t UserLength;
		uint16_t* Domain;
		uint32_t DomainLength;
		uint16_t* Password;
		uint32_t PasswordLength;
		uint32_t Flags;
	} COAUTHIDENTITY;

	typedef struct COAUTHINFO {
		uint32_t dwAuthnSvc, dwAuthzSvc;
		wchar_t* pwszServerPrincName;
		uint32_t dwAuthnLevel, dwImpersonationLevel;
		COAUTHIDENTITY* pAuthIdentityData;
		uint32_t dwCapabilities;
	} COAUTHINFO;

	typedef struct COSERVERINFO {
		uint32_t dwReserved1;
		wchar_t* pwszName;
		COAUTHINFO* pAuthInfo;
		uint32_t dwReserved2;
	} COSERVERINFO;

	typedef struct BIND_OPTS {
		uint32_t cbStruct, grfFlags, grfMode, dwTickCountDeadline;
	} BIND_OPTS;

	typedef struct BIND_OPTS2 {
		uint32_t cbStruct, grfFlags, grfMode, dwTickCountDeadline, dwTrackFlags, dwClassContext;
		uint16_t locale;
		COSERVERINFO* pServerInfo;
	} BIND_OPTS2;

	typedef struct BIND_OPTS3 {
		uint32_t cbStruct, grfFlags, grfMode, dwTickCountDeadline, dwTrackFlags, dwClassContext;
		uint16_t locale;
		COSERVERINFO* pServerInfo;
		void* hwnd;
	} BIND_OPTS3;

	typedef enum BIND_FLAGS {
		BIND_MAYBOTHERUSER = 1,
		BIND_JUSTTESTEXISTENCE = 2
	} BIND_FLAGS;

	typedef enum GETPROPERTYSTOREFLAGS {
	    GPS_DEFAULT = 0x00,
	    GPS_HANDLERPROPERTIESONLY = 0x01,
	    GPS_READWRITE = 0x02,
	    GPS_TEMPORARY = 0x04,
	    GPS_FASTPROPERTIESONLY = 0x08,
	    GPS_OPENSLOWITEM = 0x10,
	    GPS_DELAYCREATION = 0x20,
	    GPS_BESTEFFORT = 0x40,
	    GPS_NO_OPLOCK = 0x80,
	    GPS_MASK_VALID = 0xff
	} GETPROPERTYSTOREFLAGS;

	typedef struct PROPERTYKEY {
		GUID fmtid;
		uint32_t pid;
	} PROPERTYKEY;

	typedef struct DECIMAL {
		uint16_t wReserved;
		union {
			struct {
				uint8_t scale;
				uint8_t sign;
			};
			uint16_t signscale;
		};
		uint32_t Hi32;
		union {
			struct {
				uint32_t Lo32;
				uint32_t Mid32;
			};
			uint64_t Lo64;
		};
	} DECIMAL;

	typedef struct SAFEARRAYBOUND {
		uint32_t cElements;
		int32_t lLbound;
	} SAFEARRAYBOUND;

	typedef union CURRENCY {
		struct {
			uint32_t Lo;
			int32_t Hi;
		};
		int64_t int64;
	} CURRENCY;

	typedef struct SAFEARRAY {
		uint16_t cDims, fFeatures;
		uint32_t cbElements, cLocks;
		void* pvData;
		SAFEARRAYBOUND rgsabound[1];
	} SAFEARRAY;

	typedef struct PROPVARIANT PROPVARIANT;

	typedef struct CLIPDATA {
		uint32_t cbSize;
		int32_t ulClipFmt;
		uint8_t* pClipData;
    } CLIPDATA;

	typedef struct BSTRBLOB {
		uint32_t cbSize;
		uint8_t* pData;
	} BSTRBLOB;

	typedef struct BLOB {
		uint32_t cbSize;
		uint8_t* pBlobData;
	} BLOB;

	typedef struct VERSIONEDSTREAM {
		GUID guidVersion;
		IStream* pStream;
	} VERSIONEDSTREAM;

	void CoTaskMemFree(void*);
	void* CoTaskMemAlloc(size_t);	

]]

local function TYPEDEF_CA(type, name)
	local def = string.gsub([[

	    typedef struct @name@ {
	    	uint32_t cElems;
	    	@type@* pElems;
	    } @name@;

	]],

	'@(.-)@',

	{type=type, name=name})
	ffi.cdef(def)
end

TYPEDEF_CA('char', 'CAC')
TYPEDEF_CA('unsigned char', 'CAUB')
TYPEDEF_CA('short', 'CAI')
TYPEDEF_CA('uint16_t', 'CAUI')
TYPEDEF_CA('long', 'CAL')
TYPEDEF_CA('uint32_t', 'CAUL')
TYPEDEF_CA('float', 'CAFLT')
TYPEDEF_CA('double', 'CADBL')
TYPEDEF_CA('CURRENCY', 'CACY')
TYPEDEF_CA('double', 'CADATE')
TYPEDEF_CA('wchar_t*', 'CABSTR')
TYPEDEF_CA('BSTRBLOB', 'CABSTRBLOB')
TYPEDEF_CA('uint16_t', 'CABOOL')
TYPEDEF_CA('uint32_t', 'CASCODE')
TYPEDEF_CA('PROPVARIANT', 'CAPROPVARIANT')
TYPEDEF_CA('int64_t', 'CAH')
TYPEDEF_CA('uint64_t', 'CAUH')
TYPEDEF_CA('char**', 'CALPSTR')
TYPEDEF_CA('wchar_t**', 'CALPWSTR')
TYPEDEF_CA('FILETIME', 'CAFILETIME')
TYPEDEF_CA('CLIPDATA', 'CACLIPDATA')
TYPEDEF_CA('GUID', 'CACLSID')

ffi.cdef [[

	typedef struct VARIANT VARIANT;

	typedef struct VARIANT {
		union {
			struct {
				uint16_t vt;
				uint16_t wReserved1, wReserved2, wReserved3;
				union {
					int64_t llVal;
					int32_t lVal;
					uint8_t bVal;
					int16_t iVal;
					float fltVal;
					double dblVal;
					int16_t boolVal; // 0xFFFF or 0x0000
					uint32_t scode;
					CURRENCY cyVal;
					double date;
					wchar_t* bstrVal;
					IUnknown* punkVal;
					IDispatch* pdispVal;
					SAFEARRAY* parray;
					uint8_t* pbVal;
					int16_t* piVal;
					int32_t* plVal;
					int64_t* pllVal;
					float* pfltVal;
					double* pdblVal;
					int16_t* pboolVal;
					uint32_t* pscode;
					CURRENCY* pcyVal;
					double* pdate;
					wchar_t** pbstrVal;
					IUnknown** ppunkVal;
					IDispatch** ppdispVal;
					SAFEARRAY** pparray;
					VARIANT* pvarVal;
					void* byref;
					char cVal;
					uint16_t uiVal;
					uint32_t ulVal;
					uint64_t ullVal;
					int32_t intVal;
					uint32_t uintVal;
					DECIMAL* pdecVal;
					char* pcVal;
					uint16_t* puiVal;
					uint32_t* pulVal;
					uint64_t* pullVal;
					int32_t* pintVal;
					uint32_t* puintVal;
					struct {
						void* pvRecord;
						IRecordInfo *pRecInfo;
					};
				};
			};
			DECIMAL decVal;
		};
	} VARIANT;

	typedef struct PROPVARIANT {
		uint16_t vt; // type code
		uint16_t wReserved1, wReserved2, wReserved3;
		union {
			char cVal;
			unsigned char bVal;
			int16_t iVal;
			uint16_t uiVal;
			int32_t lVal;
			uint32_t ulVal;
			int32_t intVal;
			uint32_t uintVal;
			int64_t hVal;
			uint64_t uhVal;
			float fltVal;
			double dblVal;
			int16_t boolVal; // NOTE: must be 0xFFFF (true) or 0x0000 (false)
			uint32_t scode;
			CURRENCY cyVal;
			double date;
			FILETIME filetime;
			GUID* puuid;
			CLIPDATA* pclipdata;
			wchar_t* bstrVal;
			BSTRBLOB bstrblobVal;
			BLOB blob;
			char* pszVal;
			wchar_t* pwszVal;
			IUnknown* punkVal;
			IDispatch* pdispVal;
			IStream* pStream;
			IStorage* pStorage;
			VERSIONEDSTREAM* pVersionedStream;
			SAFEARRAY* parray;
			CAC cac;
			CAUB caub;
			CAI cai;
			CAUI caui;
			CAL cal;
			CAUL caul;
			CAH cah;
			CAUH cauh;
			CAFLT caflt;
			CADBL cadbl;
			CABOOL cabool;
			CASCODE cascode;
			CACY cacy;
			CADATE cadate;
			CAFILETIME cafiletime;
			CACLSID cauuid;
			CACLIPDATA caclipdata;
			CABSTR cabstr;
			CABSTRBLOB cabstrblob;
			CALPSTR calpstr;
			CALPWSTR calpwstr;
			CAPROPVARIANT capropvar;
			char* pcVal;
			unsigned char* pbVal;
			int16_t* piVal;
			uint16_t* puiVal;
			int32_t* plVal;
			uint32_t* pulVal;
			int32_t* pintVal;
			uint32_t* puintVal;
			float* pfltVal;
			double* pdblVal;
			uint16_t* pboolVal;
			DECIMAL* pdecVal;
			uint32_t* pscode;
			CURRENCY* pcyVal;
			double* pdate;
			wchar_t** pbstrVal;
			IUnknown** ppunkVal;
			IDispatch** ppdispVal;
			SAFEARRAY** pparray;
			PROPVARIANT* pvarVal;
		};
	} PROPVARIANT;

	typedef struct DVTARGETDEVICE {
		uint32_t tdSize;
		uint16_t tdDriverNameOffset;
		uint16_t tdDeviceNameOffset;
		uint16_t tdPortNameOffset;
		uint16_t tdExtDevmodeOffset;
		uint8_t tdData[1];
	} DVTARGETDEVICE;

	typedef struct FORMATETC {
		uint16_t cfFormat;
		DVTARGETDEVICE* ptd;
		uint32_t dwAspect;
		int32_t lindex;
		uint32_t tymed;
	} FORMATETC;

	typedef struct STGMEDIUM {
		uint32_t tymed;
		union {
			void* hBitmap;
			void* hMetaFilePict;
			void* hEnhMetaFile;
			void* hGlobal;
			wchar_t* lpszFileName;
			IStream* pstm;
			IStorage* pstg;
		};
		IUnknown* pUnkForRelease;
	} STGMEDIUM;

	typedef struct STATDATA {
		FORMATETC formatetc;
		uint32_t grfAdvf;
		IAdviseSink* pAdvSink;
		uint32_t dwConnection;
	} STATDATA;

	typedef struct DISPPARAMS {
		VARIANT* rgvarg;
		int32_t* rgdispidNamedArgs;
		uint32_t cArgs, cNamedArgs;
	} DISPPARAMS;

	typedef enum INVOKEKIND {
		INVOKE_FUNC = 1,
		INVOKE_PROPERTYGET = 2,
		INVOKE_PROPERTYPUT = 4,
		INVOKE_PROPERTYPUTREF = 8
	} INVOKEKIND;

	typedef struct EXCEPINFO EXCEPINFO;

	typedef struct EXCEPINFO {
		uint16_t wCode, wReserved;
		wchar_t* bstrSource;
		wchar_t* bstrDescription;
		wchar_t* bstrHelpFile;
		uint32_t dwHelpContext;
		void* pvReserved;
		int32_t (__stdcall *pfnDeferredFillIn)(EXCEPINFO*);
		uint32_t scode;
	} EXCEPINFO;

	typedef enum TYPEKIND { 
		TKIND_ENUM       = 0,
		TKIND_RECORD     = ( TKIND_ENUM + 1 ),
		TKIND_MODULE     = ( TKIND_RECORD + 1 ),
		TKIND_INTERFACE  = ( TKIND_MODULE + 1 ),
		TKIND_DISPATCH   = ( TKIND_INTERFACE + 1 ),
		TKIND_COCLASS    = ( TKIND_DISPATCH + 1 ),
		TKIND_ALIAS      = ( TKIND_COCLASS + 1 ),
		TKIND_UNION      = ( TKIND_ALIAS + 1 ),
		TKIND_MAX        = ( TKIND_UNION + 1 )
	} TYPEKIND;

	typedef struct TYPEDESC TYPEDESC;
	typedef struct ARRAYDESC ARRAYDESC;

	typedef struct TYPEDESC {
		union {
			TYPEDESC* lptdesc;
			ARRAYDESC* lpadesc;
			uint32_t hreftype;
		};
		uint16_t vt; // VARTYPE
	} TYPEDESC;

	typedef struct ARRAYDESC {
		TYPEDESC* tdescElem;
		uint16_t cDims;
		SAFEARRAYBOUND rgbounds[1];
	} ARRAYDESC;

	typedef struct IDLDESC {
		uint32_t dwReserved;
		uint16_t wIDLFlags;
	} IDLDESC;

	typedef struct TYPEATTR {
		GUID guid;
		uint16_t lcid;
		uint32_t dwReserved;
		int32_t memidConstructor;
		int32_t memidDestructor;
		wchar_t* lpstrSchema;
		uint32_t cbSizeInstance;
		TYPEKIND typekind;
		uint16_t cFuncs, cVars, cImplTypes, cbSizeVft, cbAlignment, wTypeFlags;
		uint16_t wMajorVerNum, wMinorVerNum;
		TYPEDESC tdescAlias;
		IDLDESC idldescType;
	} TYPEATTR;

	typedef struct PARAMDESCEX {
		uint32_t cBytes;
		VARIANT varDefaultValue;
	} PARAMDESCEX;

	typedef struct PARAMDESC {
		PARAMDESCEX* pparamdescex;
		uint16_t wParamFlags;
	} PARAMDESC;

	typedef struct ELEMDESC {
		TYPEDESC tdesc;
		union {
			IDLDESC idldesc;
			PARAMDESC paramdesc;
		};
	} ELEMDESC;

	typedef enum DESCKIND {
		DESCKIND_NONE = 0,
		DESCKIND_FUNCDESC,
		DESCKIND_VARDESC,
		DESCKIND_TYPECOMP,
		DESCKIND_IMPLICITAPPOBJ,
		DESCKIND_MAX
	} DESCKIND;

	typedef enum FUNCKIND {
		FUNC_VIRTUAL,
		FUNC_PUREVIRTUAL,
		FUNC_NONVIRTUAL,
		FUNC_STATIC,
		FUNC_DISPATCH
	} FUNCKIND;

	typedef enum CALLCONV {
		CC_FASTCALL = 0,
		CC_CDECL = 1,
		CC_MSCPASCAL,
		CC_PASCAL = CC_MSCPASCAL,
		CC_MACPASCAL,
		CC_STDCALL,
		CC_FPFASTCALL,
		CC_SYSCALL,
		CC_MPWCDECL,
		CC_MPWPASCAL,
		CC_MAX
	} CALLCONV;

	typedef struct FUNCDESC {
		int32_t memid;
		uint32_t *lprgscode;
		ELEMDESC *lprgelemdescParam;
		FUNCKIND funckind;
		INVOKEKIND invkind;
		CALLCONV callconv;
		uint16_t cParams, cParamsOpt, oVft, cScodes;
		ELEMDESC elemdescFunc;
		uint16_t wFuncFlags;
	} FUNCDESC;

	typedef enum VARKIND {
		VAR_PERINSTANCE,
		VAR_STATIC,
		VAR_CONST,
		VAR_DISPATCH
	} VARKIND;

	typedef struct tagVARDESC {
		int32_t memid;
		wchar_t* lpstrSchema;
		union {
			uint32_t oInst;
			VARIANT* lpvarValue;
		};
		ELEMDESC elemdescVar;
		uint16_t wVarFlags;
		VARKIND varkind;
	} VARDESC;

	typedef union BINDPTR {
		FUNCDESC* lpfuncdesc;
		VARDESC* lpvardesc;
		ITypeComp* lptcomp;
	} BINDPTR;

	typedef enum SYSKIND {
		SYS_WIN16 = 0,
		SYS_WIN32,
		SYS_MAC,
		SYS_WIN64
	} SYSKIND;

	typedef enum LIBFLAGS {
		LIBFLAG_FRESTRICTED   = 0x01,
		LIBFLAG_FCONTROL      = 0x02,
		LIBFLAG_FHIDDEN       = 0x04,
		LIBFLAG_FHASDISKIMAGE = 0x08
	} LIBFLAGS;

	typedef struct TLIBATTR {
		GUID guid;
		uint16_t lcid;
		SYSKIND syskind;
		uint16_t wMajorVerNum, wMinorVerNum, wLibFlags;
	} TLIBATTR;

	typedef enum PROPDESC_TYPE_FLAGS {
        PDTF_DEFAULT                    = 0x00000000,
        PDTF_MULTIPLEVALUES             = 0x00000001,   // This property can have multiple values (as VT_VECTOR)
        PDTF_ISINNATE                   = 0x00000002,   // This property cannot be written to
        PDTF_ISGROUP                    = 0x00000004,   // This property is a group heading
        PDTF_CANGROUPBY                 = 0x00000008,   // The user can group by this property
        PDTF_CANSTACKBY                 = 0x00000010,   // The user can stack by this property
        PDTF_ISTREEPROPERTY             = 0x00000020,   // This property contains a hierarchy
        PDTF_INCLUDEINFULLTEXTQUERY     = 0x00000040,   // Deprecated
        PDTF_ISVIEWABLE                 = 0x00000080,   // This property is meant to be viewed by the user
        PDTF_ISQUERYABLE                = 0x00000100,   // Deprecated
        PDTF_CANBEPURGED                = 0x00000200,   // This property can be purged, even if it is innate (property handler should respect this)
        PDTF_SEARCHRAWVALUE             = 0x00000400,   // The raw (rather than formatted) value of this property should be used for searching
        PDTF_ISSYSTEMPROPERTY           = 0x80000000, // This property is owned by the system
        PDTF_MASK_ALL                   = 0x800007FF
    } PROPDESC_TYPE_FLAGS;

    typedef enum PROPDESC_VIEW_FLAGS {
        PDVF_DEFAULT                = 0x00000000,
        PDVF_CENTERALIGN            = 0x00000001,   // This property should be centered
        PDVF_RIGHTALIGN             = 0x00000002,   // This property should be right aligned
        PDVF_BEGINNEWGROUP          = 0x00000004,   // Show this property as the beginning of the next collection of properties in the view
        PDVF_FILLAREA               = 0x00000008,   // Fill the remainder of the view area with the content of this property
        PDVF_SORTDESCENDING         = 0x00000010,   // If this flag is set, the default sort for this property is highest-to-lowest. If this flag is not set, the default sort is lowest-to-highest
        PDVF_SHOWONLYIFPRESENT      = 0x00000020,   // Only show this property if it is present
        PDVF_SHOWBYDEFAULT          = 0x00000040,   // the property should be shown by default in a view (where applicable)
        PDVF_SHOWINPRIMARYLIST      = 0x00000080,   // the property should be shown by default in primary column selection UI
        PDVF_SHOWINSECONDARYLIST    = 0x00000100,   // the property should be shown by default in secondary column selection UI
        PDVF_HIDELABEL              = 0x00000200,   // Hide the label if the view is normally inclined to show the label
        // obsolete                 = 0x00000400,
        PDVF_HIDDEN                 = 0x00000800,   // Don't display this property as a column in the UI
        PDVF_CANWRAP                = 0x00001000,   // the property can be wrapped to the next row
        PDVF_MASK_ALL               = 0x00001BFF
    } PROPDESC_VIEW_FLAGS;

    typedef enum PROPDESC_DISPLAYTYPE {
        PDDT_STRING         = 0,
        PDDT_NUMBER         = 1,
        PDDT_BOOLEAN        = 2,
        PDDT_DATETIME       = 3,
        PDDT_ENUMERATED     = 4,    // Use GetEnumTypeList
    } PROPDESC_DISPLAYTYPE;

    typedef enum PROPDESC_GROUPING_RANGE {
        PDGR_DISCRETE       = 0,    // Display individual values
        PDGR_ALPHANUMERIC   = 1,    // Display static alphanumeric ranges for values
        PDGR_SIZE           = 2,    // Display static size ranges for values
        PDGR_DYNAMIC        = 3,    // Display dynamically created ranges for the values
        PDGR_DATE           = 4,    // Display month/year groups
        PDGR_PERCENT        = 5,    // Display percent buckets
        PDGR_ENUMERATED     = 6,    // Display buckets from GetEnumTypeList
    } PROPDESC_GROUPING_RANGE;

    typedef enum PROPDESC_FORMAT_FLAGS {
        PDFF_DEFAULT                = 0x00000000,
        PDFF_PREFIXNAME             = 0x00000001,   // Prefix the value with the property name
        PDFF_FILENAME               = 0x00000002,   // Treat as a file name
        PDFF_ALWAYSKB               = 0x00000004,   // Always format byte sizes as KB
        PDFF_RESERVED_RIGHTTOLEFT   = 0x00000008,   // Reserved for legacy use.
        PDFF_SHORTTIME              = 0x00000010,   // Show time as "5:17 pm"
        PDFF_LONGTIME               = 0x00000020,   // Show time as "5:17:14 pm"
        PDFF_HIDETIME               = 0x00000040,   // Hide the time-portion of the datetime
        PDFF_SHORTDATE              = 0x00000080,   // Show date as "3/21/04"
        PDFF_LONGDATE               = 0x00000100,   // Show date as "Monday, March 21, 2004"
        PDFF_HIDEDATE               = 0x00000200,   // Hide the date-portion of the datetime
        PDFF_RELATIVEDATE           = 0x00000400,   // Use friendly date descriptions like "Yesterday"
        PDFF_USEEDITINVITATION      = 0x00000800,   // Use edit invitation text if failed or empty
        PDFF_READONLY               = 0x00001000,   // Use readonly format, fill with default text if empty and !PDFF_FAILIFEMPTYPROP
        PDFF_NOAUTOREADINGORDER     = 0x00002000,   // Don't detect reading order automatically. Useful if you will be converting to Ansi and don't want Unicode reading order characters
    } PROPDESC_FORMAT_FLAGS;

    typedef enum PROPDESC_SORTDESCRIPTION {
        PDSD_GENERAL                 = 0,
        PDSD_A_Z                     = 1,
        PDSD_LOWEST_HIGHEST          = 2,
        PDSD_SMALLEST_BIGGEST        = 3,
        PDSD_OLDEST_NEWEST           = 4,
    } PROPDESC_SORTDESCRIPTION;

    typedef enum PROPDESC_RELATIVEDESCRIPTION_TYPE {
        PDRDT_GENERAL                = 0,
        PDRDT_DATE                   = 1,
        PDRDT_SIZE                   = 2,
        PDRDT_COUNT                  = 3,
        PDRDT_REVISION               = 4,
        PDRDT_LENGTH                 = 5,
        PDRDT_DURATION               = 6,
        PDRDT_SPEED                  = 7,
        PDRDT_RATE                   = 8,
        PDRDT_RATING                 = 9,
        PDRDT_PRIORITY               = 10,
    } PROPDESC_RELATIVEDESCRIPTION_TYPE;

    typedef enum PROPDESC_AGGREGATION_TYPE {
        PDAT_DEFAULT        = 0,    // Display "multiple-values"
        PDAT_FIRST          = 1,    // Display first property value in the selection.
        PDAT_SUM            = 2,    // Display the numerical sum of the values. This is never returned for VT_LPWSTR, VT_BOOL, and VT_FILETIME types.
        PDAT_AVERAGE        = 3,    // Display the numerical average of the values. This is never returned for VT_LPWSTR, VT_BOOL, and VT_FILETIME types.
        PDAT_DATERANGE      = 4,    // Display the date range of the values. This is only returned for VT_FILETIME types.
        PDAT_UNION          = 5,    // Display values as union of all values. The order is undefined.
        PDAT_MAX            = 6,    // Displays the maximum of all the values.
        PDAT_MIN            = 7,    // Displays the minimum of all the values.
    } PROPDESC_AGGREGATION_TYPE;

    typedef enum PROPDESC_CONDITION_TYPE {
        PDCOT_NONE          = 0,
        PDCOT_STRING        = 1,
        PDCOT_SIZE          = 2,
        PDCOT_DATETIME      = 3,
        PDCOT_BOOLEAN       = 4,
        PDCOT_NUMBER        = 5,
    } PROPDESC_CONDITION_TYPE;

  typedef enum PROPBAG2_TYPE {
    PROPBAG2_TYPE_UNDEFINED = 0,
    PROPBAG2_TYPE_DATA = 1,
    PROPBAG2_TYPE_URL = 2,
    PROPBAG2_TYPE_OBJECT = 3,
    PROPBAG2_TYPE_STREAM = 4,
    PROPBAG2_TYPE_STORAGE = 5,
    PROPBAG2_TYPE_MONIKER = 6
  } PROPBAG2_TYPE;

  typedef struct PROPBAG2 {
    uint32_t dwType;
    uint16_t vt;       // VARTYPE
    uint16_t cfType;   // CLIPFORMAT
    uint32_t dwHint;
    wchar_t* pstrName; // LPOLESTR
    GUID clsid;
  } PROPBAG2;

]]

com.def {
	com.def_entry_enum {
		ctype = 'IUnknown*';
		iid = '00000100-0000-0000-C000-000000000046';
	};
	{'IDispatch';
		methods = {
			{'GetTypeInfoCount', 'uint32_t* out_count'};
			{'GetTypeInfo', 'uint32_t index, uint16_t lcid, ITypeInfo** out_info'};
			{'GetIDsOfNames', [[
				GUID* iid,
				wchar_t** names,
				uint32_t len_names_and_dispids,
				uint16_t lcid,
				int32_t** out_dispids]]};
			{'Invoke', [[
				int32_t member_dispid,
				GUID* iid,
				uint16_t lcid,
				uint16_t flags,
				DISPPARAMS* inout_params,
				VARIANT* out_result,
				EXCEPINFO* out_excepinfo,
				uint32_t* out_bad_arg]]};
		};
		iid = '00020400-0000-0000-C000-000000000046';
	};
	com.def_entry_enum {
		'IEnumString';
		ctype = 'wchar_t*';
		iid = '00000101-0000-0000-C000-000000000046';
	};
	{'ISequentialStream';
		methods = {
			{'Read', 'void* out_buf, uint32_t len_buf, uint32_t* out_len_read'};
			{'Write', 'const void* buf, uint32_t len_buf, uint32_t* out_len_written'};
		};
		iid = '0c733a30-2a1c-11ce-ade5-00aa0044773d';
	};
	{'IStream', inherits='ISequentialStream';
		methods = {
			{'Seek', 'int64_t displacement, uint32_t origin, uint64_t* out_newposition'};
			{'SetSize', 'uint64_t size'};
			{'CopyTo', 'IStream* dest_stream, uint64_t offset, uint64_t* out_read, uint64_t* out_written'};
			{'Commit', 'uint32_t flags'};
			{'Revert'};
			{'LockRegion', 'uint64_t offset, uint64_t length, uint32_t locktype'};
			{'UnlockRegion', 'uint64_t offset, uint64_t length, uint32_t locktype'};
			{'Stat', 'STATSTG* out_stats, uint32_t flags'};
			{'Clone', 'IStream** out_stream'};
		};
		iid = '0000000c-0000-0000-c000-000000000046';
	};
  	com.def_entry_enum{ ctype='STATSTG', iid='0000000D-0000-0000-C000-000000000046' };
  	{'IStorage';
		methods = {
			{'CreateStream', 'const wchar_t*, uint32_t, uint32_t, uint32_t, IStream** out_stream'};
			{'OpenStream', 'const wchar_t*, void*, uint32_t, uint32_t, IStream** out_stream'};
			{'CreateStorage', 'const wchar_t*, uint32_t, uint32_t, uint32_t, IStorage** out_storage'};
			{'OpenStorage', 'const wchar_t*, IStorage*, uint32_t, wchar_t**, uint32_t, IStorage** out_storage'};
			{'CopyTo', 'const GUID*, wchar_t**, IStorage** out_storage'};
			{'MoveElementTo', 'const wchar_t*, IStorage*, const wchar_t*, uint32_t'};
			{'Commit', 'uint32_t'};
			{'Revert'};
			{'EnumElements', 'uint32_t, void*, uint32_t, IEnumSTATSTG** out_enum'};
			{'DestroyElement', 'const wchar_t*'};
			{'RenameElement', 'const wchar_t*, const wchar_t*'};
			{'SetElementTimes', 'const wchar_t*, const FILETIME*, const FILETIME*, const FILETIME*'};
			{'SetClass', 'GUID*'};
			{'SetStateBits', 'uint32_t, uint32_t'};
			{'Stat', 'STATSTG*, uint32_t'};
		};
		iid = '0000000B-0000-0000-C000-000000000046';
	};
	com.def_entry_enum{ ctype='STATDATA', iid='00000105-0000-0000-C000-000000000046' };
	{'IPersist';
		methods = {
			{'GetClassID', 'GUID*'};
		};
		iid = '0000010c-0000-0000-C000-000000000046';
	};
	{'IPersistStream', inherits='IPersist';
		methods = {
			{'IsDirty'};
			{'Load', 'IStream*'};
			{'Save', 'IStream*, bool32'};
			{'GetSizeMax', 'int64_t*'};
		};
		iid = '00000109-0000-0000-C000-000000000046';
	};
	{'IRunningObjectTable';
		methods = {
			{'Register', 'uint32_t, IUnknown*, IMoniker*, uint32_t*'};
			{'Revoke', 'uint32_t'};
			{'IsRunning', 'IMoniker*'};
			{'GetObject', 'IMoniker*, IUnknown** out_unk'};
			{'NoteChangeTime', 'uint32_t, FILETIME* out_time'};
			{'GetTimeOfLastChange', 'IMoniker*, FILETIME* out_time'};
			{'EnumRunning', 'IEnumMoniker**'};
		};
		iid = '00000010-0000-0000-C000-000000000046';
	};
	{'IBindCtx';
		methods = {
			{'RegisterObjectBound', 'IUnknown*'};
			{'RevokeObjectBound', 'IUnknown*'};
			{'ReleaseBoundObjects'};
			{'SetBindOptions', 'BIND_OPTS*'};
			{'GetBindOptions', 'BIND_OPTS*'};
			{'GetRunningObjectTable', 'IRunningObjectTable** out_rot'};
			{'RegisterObjectParam', 'char*, IUnknown*'};
			{'GetObjectParam', 'char*, IUnknown** out_unk'};
			{'EnumObjectParam', 'IEnumString** out_enum'};
			{'RevokeObjectParam', 'char*'};
		};
		iid = '0000000e-0000-0000-C000-000000000046';
	};
	{'IMoniker', inherits='IPersistStream';
		methods = {
			{'BindToObject', 'IBindCtx*, IMoniker*, GUID*, void**'};
			{'BindToStorage', 'IBindCtx*, IMoniker*, GUID*, void**'};
			{'Reduce', 'IBindCtx*, uint32_t, IMoniker**, IMoniker**'};
			{'ComposeWith', 'IMoniker*, bool32, IMoniker**'};
			{'Enum', 'bool32, IEnumMoniker**'};
			{'IsEqual', 'IMoniker*'};
			{'Hash', 'uint32_t*'};
			{'IsRunning', 'IBindCtx*, IMoniker*, IMoniker*'};
			{'GetTimeOfLastChange', 'IBindCtx*, IMoniker*, FILETIME*'};
			{'Inverse', 'IMoniker**'};
			{'CommonPrefixWith', 'IMoniker*, IMoniker**'};
			{'RelativePathTo', 'IMoniker*, IMoniker**'};
			{'GetDisplayName', 'IBindCtx*, IMoniker*, char**'};
			{'ParseDisplayName', 'IBindCtx*, IMoniker*, char*, uint32_t*, IMoniker**'};
			{'IsSystemMoniker', 'uint32_t*'};
		};
		iid = '0000000f-0000-0000-C000-000000000046';
	};
	com.def_entry_enum {
		'IEnumMoniker';
		ctype='IMoniker*';
		iid='00000102-0000-0000-C000-000000000046'
	};
	{'IAdviseSink';
		methods = {
			{ret='void', 'OnDataChange', 'FORMATETC*, STGMEDIUM*'};
			{ret='void', 'OnViewChange', 'uint32_t, int32_t'};
			{ret='void', 'OnRename', 'IMoniker*'};
			{ret='void', 'OnSave'};
			{ret='void', 'OnClose'};
		};
		iid = '00000150-0000-0000-C000-000000000046';
	};
	{'IPropertyStore';
		methods = {
			{'GetCount', 'uint32_t* out_count'};
			{'GetAt', 'uint32_t index, PROPERTYKEY* out_prop'};
			{'GetValue', 'PROPERTYKEY* prop, PROPVARIANT* out_value'};
			{'SetValue', 'PROPERTYKEY* prop, PROPVARIANT* value'};
			{'Commit'};
		};
		iid = '886d8eeb-8cf2-4446-8d02-cdba1dbdcf99';
	};
	com.def_entry_enum {
		ctype = 'FORMATETC';
		iid = '00000103-0000-0000-C000-000000000046';
	};
	{'IDataObject';
		methods = {
			{'GetData', 'FORMATETC*, STGMEDIUM*'};
			{'GetDataHere', 'FORMATETC*, STGMEDIUM*'};
			{'QueryGetData', 'FORMATETC*'};
			{'GetCanonicalFormatEtc', 'FORMATETC*, FORMATETC*'};
			{'SetData', 'FORMATETC*, STGMEDIUM*, bool32'};
			{'EnumFormatEtc', 'uint32_t, IEnumFORMATETC**'};
			{'DAdvise', 'FORMATETC*, uint32_t, IAdviseSink*, uint32_t*'};
			{'DUnadvise', 'uint32_t'};
			{'EnumDAdvise', 'IEnumSTATDATA**'};
		};
		iid = '0000010e-0000-0000-C000-000000000046';
	};
	{'IDropTarget';
		methods = {
			{'DragEnter', 'IDataObject*, uint32_t, POINT, uint32_t*'};
			{'DragOver', 'uint32_t, POINT, uint32_t*'};
			{'DragLeave'};
			{'Drop', 'IDataObject*, uint32_t, POINT, uint32_t*'};
		};
		iid = '00000122-0000-0000-C000-000000000046';
	};
	{'IRecordInfo';
		methods = {
			{'RecordInit', 'void* out_new'};
			{'RecordClear', 'void* existing'};
			{'RecordCopy', 'void* existing, void* out_new'};
			{'GetGuid', 'GUID* out_guid'};
			{'GetName', 'wchar_t** out_name'};
			{'GetSize', 'uint32_t* out_size'};
			{'GetTypeInfo', 'ITypeInfo** out_info'};
			{'GetField', 'void* data, const wchar_t* name, VARIANT* out_field'};
			{'GetFieldNoCopy', 'void* data, const wchar_t* name, VARIANT* out_field, void** out_data_c_array'};
			{'PutField', 'uint32_t flags, void* inout_data, const wchar_t* name, VARIANT*'};
			{'PutFieldNoCopy', 'uint32_t flags, void* inout_data, const wchar_t* name, VARIANT*'};
			{'GetFieldNames', 'uint32_t* inout_count, wchar_t** out_names'};
			{'IsMatchingType', 'IRecordInfo*', ret='bool32'};
			{'RecordCreate', ret='void*'};
			{'RecordCreateCopy', 'void* source, void** out_dest'};
			{'RecordDestroy', 'void*'};
		};
		iid = '0000002F-0000-0000-C000-000000000046';
	};
	{'ITypeInfo';
		methods = {
			{'GetTypeAttr', 'TYPEATTR** out_attr'};
			{'GetTypeComp', 'ITypeComp** out_comp'};
			{'GetFuncDesc', 'uint32_t index, FUNCDESC** out_desc'};
			{'GetVarDesc', 'uint32_t index, VARDESC** out_desc'};
			{'GetNames', 'int32_t memberid, wchar_t** out_names, uint32_t max_count, uint32_t* out_count'};
			{'GetRefTypeOfImplType', 'uint32_t index, uint32_t* out_reftype'};
			{'GetImplTypeFlags', 'uint32_t index, int32_t* out_flags'};
			{'GetIDsOfNames', 'wchar_t** names, uint32_t count_names, int32_t* out_memberids'};
			{'Invoke', [[
				void* instance,
				int32_t memberid,
				uint32_t flags,
				DISPPARAMS* inout_params,
				VARIANT* out_result,
				EXCEPINFO* out_excepinfo,
				uint32_t* out_bad_arg]]};
			{'GetDocumentation', [[
				int32_t memberid,
				wchar_t** out_name,
				wchar_t** out_docstring,
				uint32_t* out_helpcontext,
				wchar_t** out_helpfile]]};
			{'GetDllEntry', [[
				int32_t memberid,
				INVOKEKIND,
				wchar_t** out_dll_name,
				wchar_t** out_name,
				uint16_t* out_ordinal]]};
			{'GetRefTypeInfo', 'uint32_t hreftype, ITypeInfo** out_info'};
			{'AddressOfMember', 'int32_t memberid, INVOKEKIND, void** out_ptr'};
			{'CreateInstance', 'IUnknown* outer, GUID* iid, void** out_obj'};
			{'GetMops', 'int32_t membertype, wchar_t** out_mops'};
			{'GetContainingTypeLib', 'ITypeLib** out_lib, uint32_t* out_index'};
			{'ReleaseTypeAttr', 'TYPEATTR*'};
			{'ReleaseFuncDesc', 'FUNCDESC*'};
			{'ReleaseVarDesc', 'VARDESC*'};
		};
		iid = '00020401-0000-0000-C000-000000000046';
	};
	{'ITypeComp';
		methods = {
			{'Bind', [[
				wchar_t* name, uint32_t hash_val, uint16_t flags,
				ITypeInfo** out_type, DESCKIND* out_kind, BINDPTR* out_ptr]]};
			{'BindType', [[
				wchar_t* name, uint32_t hash_val,
				ITypeInfo** out_type, ITypeComp** out_comp]]};
		};
		iid = '00020403-0000-0000-C000-000000000046';
	};
	{'ITypeLib';
		methods = {
			{'GetTypeInfoCount', ret='uint32_t'};
			{'GetTypeInfo', 'uint32_t index, ITypeInfo** out_type'};
			{'GetTypeInfoType', 'GUID*, ITypeInfo** out_type'};
			{'GetLibAttr', 'TLIBATTR** out_attr'};
			{'GetTypeComp', 'ITypeComp** out_comp'};
			{'GetDocumentation', [[
				int32_t index,
				wchar_t** out_name,
				wchar_t** out_docstring,
				uint32_t* out_helpcontext,
				wchar_t** out_helpfile]]};
			{'IsName', 'wchar_t* buf_name, uint32_t hash_val, bool32* out_result'};
			{'FindName', [[
				wchar_t* buf_name, 
				uint32_t hash_val, 
				ITypeInfo** out_tinfo, 
				int32_t* out_memberid, 
				uint16_t* inout_found]]};
			{'ReleaseTLibAttr', 'TLIBATTR*'};
		};
		iid = '00020402-0000-0000-C000-000000000046';
	};
	{'IPropertyDescription';
		methods = {
			{'GetPropertyKey', 'PROPERTYKEY* out_key'};
			{'GetCanonicalName', 'wchar_t** out_name'};
			{'GetPropertyType', 'uint16_t* out_vartype'};
			{'GetDisplayName', 'wchar_t** out_name'};
			{'GetEditInvitation', 'wchar_t** out_invite'};
			{'GetTypeFlags', 'PROPDESC_TYPE_FLAGS mask, PROPDESC_TYPE_FLAGS* out_flags'};
			{'GetViewFlags', 'PROPDESC_VIEW_FLAGS* out_flags'};
			{'GetDefaultColumnWidth', 'uint32_t* out_chars'};
			{'GetDisplayType', 'PROPDESC_DISPLAYTYPE* out_type'};
			{'GetColumnState', 'uint32_t* out_flags'};
			{'GetGroupingRange', 'PROPDESC_GROUPING_RANGE* out_range'};
			{'GetRelativeDescriptionType', 'PROPDESC_RELATIVEDESCRIPTION_TYPE* out_type'};
			{'GetRelativeDescription', 'PROPVARIANT*, PROPVARIANT*, wchar_t** out_desc1, wchar_t** out_desc2'};
			{'GetSortDescription', 'PROPDESC_SORTDESCRIPTION* out_desc'};
			{'GetSortDescriptionLabel', 'bool32 descending, wchar_t** out_desc'};
			{'GetAggregationType', 'PROPDESC_AGGREGATION_TYPE* out_type'};
			{'GetConditionType', 'PROPDESC_CONDITION_TYPE* out_type, CONDITION_OPERATION* out_default'};
			{'GetEnumTypeList', 'GUID* iid, void** out_enum'}; -- returns IPropertyEnumTypeList
			{'CoerceToCanonicalValue', 'PROPVARIANT* inout_value'};
			{'FormatForDisplay', 'PROPVARIANT*, PROPDESC_FORMAT_FLAGS, wchar_t** out_display'};
			{'IsValueCanonical', 'PROPVARIANT*'};
		};
		iid = '6f79d558-3e96-4549-a1d1-7d75d2288814';
	};
	{'IPropertyDescriptionList';
		methods = {
			{'GetCount', 'uint32_t* out_count'};
			{'GetAt', 'uint32_t index, GUID* iidof_pd, void** out_pd'}; -- returns IPropertyDescription
		};
		iid = '1f9fc1d0-c39b-4b26-817f-011967d3440e';
	};
  {'IErrorLog';
    methods = {
      {'AddError', 'const wchar_t* property_name, EXCEPINFO*'};
    };
    iid = '3127ca40-446e-11ce-8135-00aa004bb851';
  };

  {'IPropertyBag2';
    methods = {
      {'Read', [[
        uint32_t properties,
        PROPBAG2*,
        IErrorLog*,
        VARIANT* out_value,
        int32_t* out_hresult]]};
      {'Write', [[
        uint32_t properties,
        PROPBAG2*,
        VARIANT* value]]};
      {'CountProperties', 'uint32_t* out_count'};
      {'GetPropertyInfo',
        'uint32_t index, uint32_t array_size, PROPBAG2* bag_array, uint32_t* out_count'};
      {'LoadObject', 'const wchar_t*, uint32_t hint, IUnknown*, IErrorLog*'};
    };
    iid = '22f55882-280b-11d0-a8a9-00a0c90c2004';
  };
}

return ffi.load 'ole32'
