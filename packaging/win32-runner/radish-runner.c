
#include <windows.h>
#include <tchar.h>

int WINAPI WinMain(HINSTANCE instance, HINSTANCE prev_instance, char* command_line, int show_command) {
	MessageBox(NULL, _T("Hello World!"), _T("Radish"), MB_OK | MB_ICONINFORMATION);
	return 0;
}
