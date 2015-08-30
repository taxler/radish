
local guids = require 'exports.mswindows.guids'

return {
	MF_TRANSFORM_ASYNC = guids.guid 'f81a699a-649a-497d-8c73-29f8fed6ad7a';
	MF_TRANSFORM_ASYNC_UNLOCK = guids.guid 'e5666d6b-3422-4eb6-a421-da7db1f8e207';
	MF_TRANSFORM_FLAGS_Attribute = guids.guid '9359bb7e-6275-46c4-a025-1c01e45f1a86';
	MF_TRANSFORM_CATEGORY_Attribute = guids.guid 'ceabba49-506d-4757-a6ff-66c184987e4e';
	MF_READWRITE_ENABLE_HARDWARE_TRANSFORMS = guids.guid 'a634a91c-822b-41b9-a494-4de4643612b0';
	MFT_TRANSFORM_CLSID_Attribute = guids.guid '6821c42b-65a4-4e82-99bc-9a88205ecd0c';
	MFT_INPUT_TYPES_Attributes = guids.guid '4276c9b1-759d-4bf3-9cd0-0d723d138f96';
	MFT_OUTPUT_TYPES_Attributes = guids.guid '8eae8cf3-a44f-4306-ba5c-bf5dda242818';
	MFT_ENUM_HARDWARE_URL_Attribute = guids.guid '2fb866ac-b078-4942-ab6c-003d05cda674';
	MFT_FRIENDLY_NAME_Attribute = guids.guid '314ffbae-5b41-4c95-9c19-4e7d586face3';
	MFT_CONNECTED_STREAM_ATTRIBUTE = guids.guid '71eeb820-a59f-4de2-bcec-38db1dd611a4';
	MFT_CONNECTED_TO_HW_STREAM = guids.guid '34e6e728-06d6-4491-a553-4795650db912';
	MFT_PREFERRED_OUTPUTTYPE_Attribute = guids.guid '7e700499-396a-49ee-b1b4-f628021e8c9d';
	MFT_PROCESS_LOCAL_Attribute = guids.guid '543186e4-4649-4e65-b588-4aa352aff379';
	MFT_PREFERRED_ENCODER_PROFILE = guids.guid '53004909-1ef5-46d7-a18e-5a75f8b5905f';
	MFT_HW_TIMESTAMP_WITH_QPC_Attribute = guids.guid '8d030fb8-cc43-4258-a22e-9210bef89be4';
	MFT_FIELDOFUSE_UNLOCK_Attribute = guids.guid '8ec2e9fd-9148-410d-831e-702439461a8e';
	MFT_CODEC_MERIT_Attribute = guids.guid '88a7cb15-7b07-4a34-9128-e64c6703c4d3';
	MFT_ENUM_TRANSCODE_ONLY_ATTRIBUTE = guids.guid '111ea8cd-b62a-4bdb-89f6-67ffcdc2458b';
	MF_PD_PMPHOST_CONTEXT = guids.guid '6c990d31-bb8e-477a-8598-0d5d96fcd88a';
	MF_PD_APP_CONTEXT = guids.guid '6c990d32-bb8e-477a-8598-0d5d96fcd88a';
	MF_PD_DURATION = guids.guid '6c990d33-bb8e-477a-8598-0d5d96fcd88a';
	MF_PD_TOTAL_FILE_SIZE = guids.guid '6c990d34-bb8e-477a-8598-0d5d96fcd88a';
	MF_PD_AUDIO_ENCODING_BITRATE = guids.guid '6c990d35-bb8e-477a-8598-0d5d96fcd88a';
	MF_PD_VIDEO_ENCODING_BITRATE = guids.guid '6c990d36-bb8e-477a-8598-0d5d96fcd88a';
	MF_PD_MIME_TYPE = guids.guid '6c990d37-bb8e-477a-8598-0d5d96fcd88a';
	MF_PD_LAST_MODIFIED_TIME = guids.guid '6c990d38-bb8e-477a-8598-0d5d96fcd88a';
	MF_PD_PLAYBACK_ELEMENT_ID = guids.guid '6c990d39-bb8e-477a-8598-0d5d96fcd88a';
	MF_PD_PREFERRED_LANGUAGE = guids.guid '6c990d3a-bb8e-477a-8598-0d5d96fcd88a';
	MF_PD_PLAYBACK_BOUNDARY_TIME = guids.guid '6c990d3b-bb8e-477a-8598-0d5d96fcd88a';
	MF_PD_AUDIO_ISVARIABLEBITRATE = guids.guid '33026ee0-e387-4582-ae0a-34a2ad3baa18';
	MF_MT_MAJOR_TYPE = guids.guid '48eba18e-f8c9-4687-bf11-0a74c9f96a8f'; -- GUID
	MF_MT_SUBTYPE = guids.guid 'f7e34c9a-42e8-4714-b74b-cb29d72c35e5'; -- GUID
	MF_MT_AUDIO_BLOCK_ALIGNMENT = guids.guid '322de230-9eeb-43bd-ab7a-ff412251541d';
	MF_MT_AUDIO_AVG_BYTES_PER_SECOND = guids.guid '1aab75c8-cfef-451c-ab95-ac034b8e1731';
	MF_MT_AUDIO_NUM_CHANNELS = guids.guid '37e48bf5-645e-4c5b-89de-ada9e29b696a'; -- uint32_t
	MF_MT_AUDIO_SAMPLES_PER_SECOND = guids.guid '5faeeae7-0290-4c31-9e8a-c534f68d9dba'; -- uint32_t
	MF_MT_AUDIO_BITS_PER_SAMPLE = guids.guid 'f2deb57f-40fa-4764-aa33-ed4f2d1ff669'; -- uint32_t
	MF_MT_USER_DATA = guids.guid 'b6bc765f-4c3b-40a4-bd51-2535b66fe09d';
	MF_MT_ALL_SAMPLES_INDEPENDENT = guids.guid 'c9173739-5e56-461c-b713-46fb995cb95f';
	MF_MT_FIXED_SIZE_SAMPLES = guids.guid 'b8ebefaf-b718-4e04-b0a9-116775e3321b';
	MF_MT_AM_FORMAT_TYPE = guids.guid '73d1072d-1870-4174-a063-29ff4ff6c11e';
	MF_MT_AUDIO_PREFER_WAVEFORMATEX = guids.guid 'a901aaba-e037-458a-bdf6-545be2074042';
	MF_MT_COMPRESSED = guids.guid '3afd0cee-18f2-4ba5-a110-8bea502e1f92';
	MF_MT_AVG_BITRATE = guids.guid '20332624-fb0d-4d9e-bd0d-cbf6786c102e';
	MF_MT_AAC_PAYLOAD_TYPE = guids.guid 'bfbabe79-7434-4d1c-94f0-72a3b9e17188';
	MF_MT_AAC_AUDIO_PROFILE_LEVEL_INDICATION = guids.guid '7632f0e6-9538-4d61-acda-ea29c8c14456';
}
