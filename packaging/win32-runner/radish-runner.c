
#include <tchar.h>
#include <windows.h>

#include "radish-resources.h"
#include "radish-state.h"
#include "radish-scripting.h"

int WINAPI WinMain(HINSTANCE instance, HINSTANCE prev_instance, char* command_line, int show_command) {
	radish_state* radish;
	radish_window host_window;
	radish_init_for_states();
	radish = radish_create_state(L"main.lua");
	radish->main_fiber = ConvertThreadToFiber(NULL);
	radish->script_fiber = radish_create_script_fiber(radish);
	radish_init_host_window(radish, &host_window);

	if (radish_script_step(radish)) {
		BOOL result;
		radish_create_window(radish, &host_window);
		while ((result = GetMessageW(&radish->msg, NULL, 0, 0)) != 0) {
			if (result == -1) {
				// GetMessage error
				break;
			}
			TranslateMessage(&radish->msg);
			DispatchMessageW(&radish->msg);
		}
		if (radish->script_fiber != NULL) {
			do {
				radish->msg.message = WMRADISH_TERMINATE;
			}
			while (radish_script_step(radish));
		}
	}

	if (radish->error != NULL) {
		MessageBoxW(NULL, radish->error, radish_get_title(), MB_OK | MB_ICONERROR);
		return EXIT_FAILURE;
	}
	return EXIT_SUCCESS;
}
