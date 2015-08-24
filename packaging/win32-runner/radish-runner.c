
#include <windows.h>
#include <tchar.h>

#include "radish-resources.h"

void* file_version_info;
WORD fv_id1, fv_id2;
wchar_t* title = L"Radish";

int WINAPI WinMain(HINSTANCE instance, HINSTANCE prev_instance, char* command_line, int show_command) {
	file_version_info = get_file_version_info();
	if (file_version_info != NULL && get_translation_id(file_version_info, &fv_id1, &fv_id2)) {
		wchar_t* new_title = get_title(file_version_info, fv_id1, fv_id2);
		if (new_title != NULL) {
			title = new_title;
		}
	}
	MessageBoxW(NULL, L"Hello World!", title, MB_OK | MB_ICONINFORMATION);
	return 0;
}
