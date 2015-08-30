
local ffi = require 'ffi'
local mswin = require 'exports.mswindows'
local guids = require 'exports.guids'
local com = require 'exports.mswindows.com'
local automation = require 'exports.mswindows.automation'

ffi.cdef [[

	typedef enum FDE_SHAREVIOLATION_RESPONSE {
	    FDESVR_DEFAULT = 0,
	    FDESVR_ACCEPT = 1,
	    FDESVR_REFUSE = 2
	} FDE_SHAREVIOLATION_RESPONSE;

	typedef enum FDE_OVERWRITE_RESPONSE {
	    FDEOR_DEFAULT = 0,
	    FDEOR_ACCEPT = 1,
	    FDEOR_REFUSE = 2
	} FDE_OVERWRITE_RESPONSE;

	enum {
		FOS_OVERWRITEPROMPT          = 0x00000002, // (on by default in the save dialog)
		FOS_STRICTFILETYPES          = 0x00000004, // In the save dialog, only allow the user to choose a file that has
		                                                   // one of the file extensions provided in SetFileTypes.
		FOS_NOCHANGEDIR              = 0x00000008, // Don't change the current working directory
		FOS_PICKFOLDERS              = 0x00000020, // Invoke the open dialog in folder picking mode.
		FOS_FORCEFILESYSTEM          = 0x00000040, // Ensure that items returned are filesystem items.
		FOS_ALLNONSTORAGEITEMS       = 0x00000080, // Allow choosing items that have no storage.
		FOS_NOVALIDATE               = 0x00000100,
		FOS_ALLOWMULTISELECT         = 0x00000200,
		FOS_PATHMUSTEXIST            = 0x00000800, // (on by default)
		FOS_FILEMUSTEXIST            = 0x00001000, // (on by default in the open dialog and folder picker)
		FOS_CREATEPROMPT             = 0x00002000,
		FOS_SHAREAWARE               = 0x00004000,
		FOS_NOREADONLYRETURN         = 0x00008000, // (on by default in the save dialog)
		FOS_NOTESTFILECREATE         = 0x00010000, // Avoid testing the creation of the chosen file in the save dialog
		                                           // (specifying this flag will circumvent some useful error handling, such as access denied)
		FOS_HIDEMRUPLACES            = 0x00020000, // (not used in Win7)
		FOS_HIDEPINNEDPLACES         = 0x00040000, // Don't display the standard namespace locations in the navigation pane.
		                                           // (generally used along with AddPlace)
		FOS_NODEREFERENCELINKS       = 0x00100000, // Don't treat shortcuts as their target files.
		FOS_DONTADDTORECENT          = 0x02000000, // Don't add the chosen file to the recent documents list (SHAddToRecentDocs)
		FOS_FORCESHOWHIDDEN          = 0x10000000, // Show all files including system and hidden files.
		FOS_DEFAULTNOMINIMODE        = 0x20000000, // (not used in Win7)
		FOS_FORCEPREVIEWPANEON       = 0x40000000
	};

	typedef enum FDAP {
	    FDAP_BOTTOM              = 0,
	    FDAP_TOP                 = 1
	} FDAP;

	typedef struct COMDLG_FILTERSPEC {
		const wchar_t* pszName;
		const wchar_t* pszSpec;
	} COMDLG_FILTERSPEC;

	typedef enum SIGDN {                                                         // lower word (& with 0xFFFF)
        SIGDN_NORMALDISPLAY               = 0x00000000,       // SHGDN_NORMAL
        SIGDN_PARENTRELATIVEPARSING       = (int) 0x80018001, // SHGDN_INFOLDER | SHGDN_FORPARSING
        SIGDN_DESKTOPABSOLUTEPARSING      = (int) 0x80028000, // SHGDN_FORPARSING
        SIGDN_PARENTRELATIVEEDITING       = (int) 0x80031001, // SHGDN_INFOLDER | SHGDN_FOREDITING
        SIGDN_DESKTOPABSOLUTEEDITING      = (int) 0x8004c000, // SHGDN_FORPARSING | SHGDN_FORADDRESSBAR
        SIGDN_FILESYSPATH                 = (int) 0x80058000, // SHGDN_FORPARSING
        SIGDN_URL                         = (int) 0x80068000, // SHGDN_FORPARSING
        SIGDN_PARENTRELATIVEFORADDRESSBAR = (int) 0x8007c001, // SHGDN_INFOLDER | SHGDN_FORPARSING | SHGDN_FORADDRESSBAR
        SIGDN_PARENTRELATIVE              = (int) 0x80080001 // SHGDN_INFOLDER
    } SIGDN;

	typedef enum SIATTRIBFLAGS {
        SIATTRIBFLAGS_AND = 0x00000001,
        SIATTRIBFLAGS_OR = 0x00000002,
        SIATTRIBFLAGS_APPCOMPAT = 0x00000003,
        SIATTRIBFLAGS_MASK = 0x00000003,
        SIATTRIBFLAGS_ALLITEMS = 0x00004000
    } SIATTRIBFLAGS;

	typedef enum CDCONTROLSTATEF {
	    CDCS_INACTIVE       = 0x00000000,
	    CDCS_ENABLED        = 0x00000001,
	    CDCS_VISIBLE        = 0x00000002,
	    CDCS_ENABLEDVISIBLE = 0x00000003,
	} CDCONTROLSTATEF;

]]

com.def {
	{'IShellItem';
		methods = {
			{'BindToHandler', 'IBindCtx*, GUID* bhid, GUID* iid, void** out_value'};
			{'GetParent', 'IShellItem** out_parent'};
			{'GetDisplayName', 'SIGDN, wchar_t** out_name'};
			{'GetAttributes', 'uint32_t sfgao_mask, uint32_t* out_sfgao_attribs'};
			{'Compare', 'IShellItem*, uint32_t sichint, int* out_order'};
		};
		iid = '43826d1e-e718-42ee-bc55-a1e261c37bfe';
	};
	{'IShellItemArray';
		methods = {
			{'BindToHandler', 'IBindCtx*, GUID* bhid, GUID* iid, void** out_obj'};
			{'GetPropertyStore', 'GETPROPERTYSTOREFLAGS flags, GUID* iidof_store, void** out_store'};
			{'GetPropertyDescriptionList', 'PROPERTYKEY* keyType, GUID* iidof_list, void** out_list'};
			{'GetAttributes', 'SIATTRIBFLAGS attrib_flags, uint32_t sfgao_mask, uint32_t* out_sfgao_attribs'};
			{'GetCount', 'uint32_t* out_count'};
			{'GetItemAt', 'uint32_t index, IShellItem** out_item'};
			{'EnumItems', 'IEnumShellItems** out_enum'};
		};
		iid = 'b63ea76d-1f85-456f-a19c-48159efa858b';
	};
	automation.enumdef {
		'IEnumShellItems';
		ctype = 'IShellItem*';
		iid = '70629033-e363-4a28-a567-0db78006e6d7';
	};
	{'IShellItemFilter';
		methods = {
			{'IncludeItem', 'IShellItem*'};
			{'GetEnumFlagsForItem', 'IShellItem*, uint32_t* out_shcont_flags'};
		};
		iid = '2659B475-EEB8-48b7-8F07-B378810F48CF';
	};

	{'IModalWindow';
		methods = {
			{'Show', 'void* owner_hwnd'};
		};
		iid = 'b4db1657-70d7-485e-8e3e-6fcb5a5c1802';
	};
	{'IFileDialogEvents';
		methods = {
			{'OnFileOk', 'IFileDialog*'};
			{'OnFolderChanging', 'IFileDialog*, IShellItem*'};
			{'OnFolderChange', 'IFileDialog*'};
			{'OnSelectionChange', 'IFileDialog*'};
			{'OnShareViolation', 'IFileDialog*, IShellItem*, FDE_SHAREVIOLATION_RESPONSE* out_response'};
			{'OnTypeChange', 'IFileDialog*'};
			{'OnOverwrite', 'IFileDialog*, IShellItem*, FDE_OVERWRITE_RESPONSE* out_response'};
		};
		iid = '973510db-7d7f-452b-8975-74a85828d354';
	};
	{'IFileDialog', inherits='IModalWindow';
		methods = {
			{'SetFileTypes', 'uint32_t specs_count, COMDLG_FILTERSPEC* specs'};
			{'SetFileTypeIndex', 'uint32_t'};
			{'GetFileTypeIndex', 'uint32_t*'};
			{'Advise', 'IFileDialogEvents*, uint32_t* out_cookie'};
			{'Unadvise', 'uint32_t cookie'};
			{'SetOptions', 'uint32_t options'};
			{'GetOptions', 'uint32_t* out_options'};
			{'SetDefaultFolder', 'IShellItem*'};
			{'SetFolder', 'IShellItem*'};
			{'GetFolder', 'IShellItem** out_folder'};
			{'GetCurrentSelection', 'IShellItem** out_selection'};
			{'SetFileName', 'const wchar_t*'};
			{'GetFileName', 'wchar_t* out_name'};
			{'SetTitle', 'const wchar_t*'};
			{'SetOkButtonLabel', 'const wchar_t*'};
			{'SetFileNameLabel', 'const wchar_t*'};
			{'GetResult', 'IShellItem** out_result'};
			{'AddPlace', 'IShellItem*, FDAP'};
			{'SetDefaultExtension', 'const wchar_t*'};
			{'Close', 'int32_t hresult'};
			{'SetClientGuid', 'GUID*'};
			{'ClearClientData'};
			{'SetFilter', 'IShellItemFilter*'};
		};
		iid = '42f85136-db7e-439c-85f1-e4075d135fc8';
	};
	{'IFileOpenDialog', inherits='IFileDialog';
		methods = {
			{'GetResults', 'IShellItemArray** out_results'};
			{'GetSelectedItems', 'IShellItemArray** out_items'};
		};
		iid = 'd57c7288-d4ad-4768-be02-9d969532d960';
	};
	{'IFileSaveDialog', inherits='IFileDialog';
		methods = {
			{'SetSaveAsItem', 'IShellItem*'};
			{'SetProperties', 'IPropertyStore*'};
			{'SetCollectedProperties', 'IPropertyDescriptionList*, bool32 append_default'};
			{'GetProperties', 'IPropertyStore** out_properties'};
			{'ApplyProperties', 'IShellItem*, IPropertyStore*, void* hwnd, IFileOperationProgressSink*'}
		};
		iid = '84bccd23-5fde-4cdb-aea4-af64b83d78ab';
	};
	{'IFileDialogCustomize';
		methods = {
			{'EnableOpenDropDown', 'uint32_t id'};
			{'AddMenu', 'uint32_t id, const wchar_t* label'};
			{'AddPushButton', 'uint32_t id, const wchar_t* label'};
			{'AddComboBox', 'uint32_t id'};
			{'AddRadioButtonList', 'uint32_t id'};
			{'AddCheckButton', 'uint32_t id, const wchar_t* label, bool32 checked'};
			{'AddEditBox', 'uint32_t id, const wchar_t* text'};
			{'AddSeparator', 'uint32_t id'};
			{'AddText', 'uint32_t id, const wchar_t*'};
			{'SetControlLabel', 'uint32_t id, const wchar_t*'};
			{'GetControlState', 'uint32_t id, CDCONTROLSTATEF* out_state'};
			{'SetControlState', 'uint32_t id, CDCONTROLSTATEF'};
			{'GetEditBoxText', 'uint32_t id, wchar_t** out_text'};
			{'SetEditBoxText', 'uint32_t id, const wchar_t* text'};
			{'GetCheckButtonState', 'uint32_t id, bool32* out_checked'};
			{'SetCheckButtonState', 'uint32_t id, bool32 checked'};
			{'AddControlItem', 'uint32_t control_id, uint32_t item_id, const wchar_t* label'};
			{'RemoveControlItem', 'uint32_t control_id, uint32_t item_id'};
			{'RemoteAllControlItems', 'uint32_t id'};
			{'GetControlItemState', 'uint32_t control_id, uint32_t item_id, CDCONTROLSTATEF* out_state'};
			{'SetControlItemState', 'uint32_t control_id, uint32_t item_id, CDCONTROLSTATEF state'};
			{'GetSelectedControlItem', 'uint32_t control_id, uint32_t* out_item_id'};
			{'SetSelectedControlItem', 'uint32_t control_id, uint32_t item_id'};
			{'StartVisualGroup', 'uint32_t id, const wchar_t* label'};
			{'EndVisualGroup'};
			{'MakeProminent', 'uint32_t id'}; -- one control only
			{'SetControlItemText', 'uint32_t control_id, uint32_t item_id, const wchar_t*'};
		};
		iid = 'e6fdd21a-163f-4975-9c8c-a69f1ba37034';
	};
	{'IFileOperationProgressSink';
		methods = {
			{'StartOperations'};
			{'FinishOperations', 'int32_t hresult'};
			{'PreRenameItem', 'uint32_t flags, IShellItem*, const wchar_t* new_name'};
			{'PostRenameItem', [[
				uint32_t flags, IShellItem*, const wchar_t* new_name,
				int32_t rename_hresult, IShellItem* newly_created]]};
			{'PreMoveItem', 'uint32_t flags, IShellItem*, IShellItem* dest_folder, const wchar_t* new_name'};
			{'PostMoveItem', [[
				uint32_t flags, IShellItem*, IShellItem* dest_folder, const wchar_t* new_name,
				int32_t move_hresult, IShellItem* newly_created]]};
			{'PreCopyItem', 'uint32_t flags, IShellItem*, IShellItem* dest_folder, const wchar_t* new_name'};
			{'PostCopyItem', [[
				uint32_t flags, IShellItem*, IShellItem* dest_folder, const wchar_t* new_name,
				int32_t copy_hresult, IShellItem* newly_created]]};
			{'PreDeleteItem', 'uint32_t flags, IShellItem*'};
			{'PostDeleteItem', 'uint32_t flags, IShellItem*, int32_t delete_hresult, IShellItem* newly_created'};
			{'PreNewItem', 'uint32_t flags, IShellItem* dest_folder, const wchar_t* new_name'};
			{'PostNewItem', [[
				uint32_t flags, IShellItem* dest_folder, const wchar_t* new_name,
				const wchar_t* template_name, uint32_t file_attributes, int32_t file_attributes,
				int32_t new_hresult, IShellItem* new_item]]};
			{'UpdateProgress', 'uint32_t total_work, uint32_t so_far'};
			{'ResetTimer'};
			{'PauseTimer'};
			{'ResumeTimer'};
		};
		iid = '04b0f1a7-9490-44bc-96e1-4296a31252e2';
	};
	{"ITaskbarList";
		methods = {
			{'HrInit'};
			{'AddTab', 'void* hwnd'};
			{'DeleteTab', 'void* hwnd'};
			{'ActivateTab', 'void* hwnd'};
			{'SetActiveAlt', 'void* hwnd'};
		};
		iid = '56FDF344-FD6D-11d0-958A006097C9A090';
	};
	{"ITaskbarList2", inherits='ITaskbarList';
		methods = {
			{'MarkFullscreenWindow', 'void* hwnd, bool32'};
		};
		iid = '602D4995-B13A-429b-A66E1935E44F4317';
	};
	{"ITaskbarList3", inherits='ITaskbarList2';
		methods = {
			{'SetProgressValue', 'void* hwnd, uint64_t done, uint64_t total'};
			{'SetProgressState', 'void* hwnd, uint32_t tbpfFlags'};
			{'RegisterTab', 'void* hwndTab, void* hwndMDI'};
			{'UnregisterTab', 'void* hwndTab'};
			{'SetTabOrder', 'void* hwndTab, void* hwndInsertBefore'};
			{'SetTabActive', 'void* hwndTab, void* hwndMDI, uint32_t tbatFlags'};
			{'ThumbBarAddButtons', 'void* hwnd, uint32_t buttons, void* button'};
			{'ThumbBarUpdateButtons', 'void* hwnd, uint32_t buttons, void* button'};
			{'ThumbBarSetImageList', 'void* hwnd, void* himagelist'};
			{'SetOverlayIcon', 'void* hwnd, void* hicon, const wchar_t* description'};
			{'SetThumbnailTooltip', 'void* hwnd, const wchar_t* toolTip'};
			{'SetThumbnailClip', 'void* hwnd, RECT* clip'};
		};
		iid = 'EA1AFB91-9E28-4B86-90E99E9F8A5EEFAF';
	};
}

ffi.cdef [[

  enum {
    WM_DROPFILES = 0x0233
  };

  void DragAcceptFiles(void* hwnd, bool32);
  uint32_t DragQueryFileA(void* hdrop, uint32_t index, char* buffer, uint32_t bufferSize);
  uint32_t DragQueryFileW(void* hdrop, uint32_t index, wchar_t* buffer, uint32_t bufferSize);
  bool32 DragQueryPoint(void* hdrop, POINT*);
  void DragFinish(void* hdrop);
  void* ExtractIconW(void* hInstance, const wchar_t* path, uint32_t index);
  int32_t ShellExecuteW(
    void* hwnd,
    const wchar_t* operation,
    const wchar_t* file,
    const wchar_t* parameters,
    const wchar_t* directory,
    int32_t show);

	enum {
		NIM_ADD = 0,
		NIM_MODIFY = 1,
		NIM_DELETE = 2,
		NIM_SETFOCUS = 3,
		NIM_SETVERSION = 4,

		NIF_MESSAGE = 1,
		NIF_ICON = 2,
		NIF_TIP = 4,
		NIF_STATE = 8,
		NIF_INFO = 0x10,
		NIF_GUID = 0x20,
		NIF_REALTIME = 0x40,
		NIF_SHOWTIP = 0x80,

		NIIF_NONE = 0,
		NIIF_INFO = 1,
		NIIF_WARNING = 2,
		NIIF_ERROR = 3,
		NIIF_USER = 4,
		NIIF_ICON_MASK = 0xF,		
		NIIF_NOSOUND = 0x10,
		NIIF_LARGE_ICON = 0x20,
		NIIF_RESPECT_QUIET_TIME = 0x80,

		NOTIFYICON_VERSION_4 = 4,

		NIN_SELECT = WM_USER + 0,
		NINF_KEY = 0x1,
		NIN_KEYSELECT = NIN_SELECT | NINF_KEY,

		NIN_BALLOONSHOW = WM_USER + 2,
		NIN_BALLOONHIDE = WM_USER + 3,
		NIN_BALLOONTIMEOUT = WM_USER + 4,
		NIN_BALLOONUSERCLICK = WM_USER + 5,
		NIN_POPUPOPEN = WM_USER + 6,
		NIN_POPUPCLOSE = WM_USER + 7

  	};

	typedef struct NOTIFYICONDATAW {
		uint32_t cbSize;
		void* hWnd;
		uint32_t uID, uFlags, uCallbackMessage;
		void* hIcon;
		wchar_t szTip[128];
		uint32_t dwState, dwStateMask;
		wchar_t szInfo[256];
		union {
			uint32_t uTimeout;
			uint32_t uVersion;
		};
		wchar_t szInfoTitle[64];
		uint32_t dwInfoFlags;
		GUID guidItem;
		void* hBalloonIcon;
	} NOTIFYICONDATAW;

	bool32 Shell_NotifyIconW(uint32_t nim, NOTIFYICONDATAW*);

]]

return ffi.load 'shell32'
