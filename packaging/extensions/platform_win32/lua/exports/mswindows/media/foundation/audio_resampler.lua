
local com = require 'exports.mswindows.com'
local guids = require 'exports.mswindows.guids'

com.def {
	{'IWMResamplerProps';
		iid = 'E7E9984F-F09F-4da4-903F-6E2E0EFE56B5';
		methods = {
			{'SetHalfFilterLength', 'int32_t length'};
			{'SetUserChannelMtx', 'float* channel_conversion_matrix'
				-- like MFPKEY_WMRESAMP_CHANNELMTX but floating point & transposed
			};
		};
	};	
}

return {
	class_id = guids.guid 'f447b69e-1884-4a7e-8055-346f74d6edb3';
}
