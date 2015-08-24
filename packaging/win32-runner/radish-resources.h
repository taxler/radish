
#ifndef RADISH_RESOURCES_DOT_H
#define RADISH_RESOURCES_DOT_H

void* get_file_version_info();
BOOL get_translation_id(void* fvinfo, WORD* out_id1, WORD* out_id2);
wchar_t* get_title(void* fvinfo, WORD id1, WORD id2);

#endif
