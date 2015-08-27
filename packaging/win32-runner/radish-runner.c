
#include <tchar.h>
#include <windows.h>

#include "radish-resources.h"
#include "radish-state.h"
#include "radish-scripting.h"
#include "radish-dialog.h"

int WINAPI WinMain(HINSTANCE instance, HINSTANCE prev_instance, char* command_line, int show_command) {
	radish_state* radish;
	radish_window host_window;
	radish_init_for_states();
	radish = radish_create_state(L"main.lua");
	radish->main_fiber = ConvertThreadToFiber(NULL);
	radish->script_fiber = radish_create_script_fiber(radish);
	radish_init_host_window(radish, &host_window);

	if (radish_script_step(radish)) {
		radish_create_window(radish, &host_window);
		// script may have terminated during the create window phase
		while (radish_script_running(radish)) {
			// not a true boolean, may be -1
 			BOOL result = GetMessageW(&radish->msg, NULL, 0, 0);
 			if (result == -1) {
				radish->error = L"GetMessage error";
				break;
			}
			if (radish->msg.hwnd == NULL) {
				UINT message = radish->msg.message;
				WPARAM wparam = radish->msg.wParam;
				LPARAM lparam = radish->msg.lParam;
				radish_script_step(radish);
				// overridable default behaviours
				if (radish->msg.message != WMRADISH_HANDLED) {
					switch (message) {
						case WMRADISH_DIALOG_REQUEST:
							radish_do_dialog(radish, (radish_dialog*)lparam);
							if (wparam != 0) {
								PostThreadMessage((UINT)wparam, WMRADISH_DIALOG_RESPONSE, 0, lparam);
							}
							else {
								radish->msg.message = WMRADISH_DIALOG_RESPONSE;
								radish->msg.lParam = lparam;
								radish_script_step(radish);
								radish_free_dialog(radish, (radish_dialog*)lparam);
							}
							break;
					}
				}
				// non-overridable default behaviours
				switch (message) {
					case WMRADISH_THREAD_TERMINATED:
						// TODO: make sure all strings etc are freed too
						free((radish_state*)lparam);
						break;
					case WMRADISH_THREAD_SEND_DATA:
						radish_buffer_free((radish_buffer*)lparam);
						break;
				}
			}
			else {
                if (radish->accelerator_table != NULL && TranslateAccelerator(
                		radish->msg.hwnd, radish->accelerator_table, &radish->msg)) {
                    // don't TranslateMessage
                }
                else {
					TranslateMessage(&radish->msg);
					DispatchMessageW(&radish->msg);
				}
			}
		}
	}

	if (radish->error != NULL) {
		MessageBoxW(NULL, radish->error, radish_get_title(), MB_OK | MB_ICONERROR);
		return EXIT_FAILURE;
	}
	return EXIT_SUCCESS;
}
