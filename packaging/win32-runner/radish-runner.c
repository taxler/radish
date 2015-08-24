
#include <windows.h>
#include <tchar.h>

#include "radish-resources.h"
#include "radish-state.h"
#include "radish-scripting.h"

int WINAPI WinMain(HINSTANCE instance, HINSTANCE prev_instance, char* command_line, int show_command) {
	radish_state* radish;
	radish_init_for_states();
	radish = radish_create_state(L"main.lua");
	radish->main_fiber = ConvertThreadToFiber(NULL);
	radish->script_fiber = radish_create_script_fiber(radish);

	SwitchToFiber(radish->script_fiber);

	if (radish_handle_script_response(radish)) {

	}

	//MessageBoxW(NULL, L"Hello World!", radish_get_title(), MB_OK | MB_ICONINFORMATION);
	if (radish->msg.message == WMRADISH_TERMINATED && radish->msg.lParam != 0) {
		return EXIT_FAILURE;
	}
	return EXIT_SUCCESS;
}
