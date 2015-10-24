
local guids = require 'exports.mswindows.guids'

return {
	MFMediaType_Audio = guids.guid "73647561-0000-0010-8000-00aa00389b71";
	MFMediaType_Video = guids.guid "73646976-0000-0010-8000-00aa00389b71";
	MFMediaType_Protected = guids.guid "7b4b6fe6-9d04-4494-be14-7e0bd076c8e4";
	MFMediaType_SAMI = guids.guid "e69669a0-3dcd-40cb-9e2e-3708387c0616";
	MFMediaType_Script = guids.guid "72178c22-e45b-11d5-bc2a-00b0d0f3f4ab";
	MFMediaType_Image = guids.guid "72178c23-e45b-11d5-bc2a-00b0d0f3f4ab";
	MFMediaType_HTML = guids.guid "72178c24-e45b-11d5-bc2a-00b0d0f3f4ab";
	MFMediaType_Binary = guids.guid "72178c25-e45b-11d5-bc2a-00b0d0f3f4ab";
	MFMediaType_FileTransfer = guids.guid "72178c26-e45b-11d5-bc2a-00b0d0f3f4ab";
}
