
#include <stdio.h>
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
		radish_update_first(radish);
		// script may have terminated during the create window phase
		while (radish_script_running(radish)) {
			DWORD result = MsgWaitForMultipleObjects(
				radish->wait_object_count,
				radish->wait_objects,
				FALSE,
				radish_update_timeout(radish),
				QS_ALLINPUT);
			if (result == WAIT_OBJECT_0 + radish->wait_object_count) {
				BOOL first = TRUE;
				while (PeekMessage(&radish->msg, NULL, 0, 0, PM_REMOVE)) {
					UINT message = radish->msg.message;
					HWND hwnd = radish->msg.hwnd;
					WPARAM wparam = radish->msg.wParam;
					LPARAM lparam = radish->msg.lParam;
					if (first) {
						first = FALSE;
					}
					else {
						DWORD result2 = WaitForMultipleObjects(
							radish->wait_object_count,
							radish->wait_objects,
							FALSE,
							0);
						if (result2 >= WAIT_OBJECT_0 && result2 < (WAIT_OBJECT_0 + radish->wait_object_count)) {
							radish->msg.message = WMRADISH_WAIT_OBJECT_SIGNALLED;
							radish->msg.hwnd = NULL;
							radish->msg.lParam = (LPARAM)(result2 - WAIT_OBJECT_0);
							radish->msg.wParam = (WPARAM)radish->wait_objects[radish->msg.lParam];
							radish_script_step(radish);
						}
						else if (result2 >= WAIT_ABANDONED_0 && result2 < (WAIT_ABANDONED_0 + radish->wait_object_count)) {
							radish->msg.message = WMRADISH_MUTEX_ABANDONED;
							radish->msg.hwnd = NULL;
							radish->msg.lParam = (LPARAM)(result2 - WAIT_ABANDONED_0);
							radish->msg.wParam = (WPARAM)radish->wait_objects[radish->msg.lParam];
							radish_script_step(radish);
						}
						radish->msg.message = message;
						radish->msg.hwnd = hwnd;
						radish->msg.wParam = wparam;
						radish->msg.lParam = lparam;
					}
					if (radish->msg.hwnd == NULL) {
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
				radish_update_maybe(radish);
			}
			else if (result >= WAIT_OBJECT_0 && result < (WAIT_OBJECT_0 + radish->wait_object_count)) {
				radish->msg.message = WMRADISH_WAIT_OBJECT_SIGNALLED;
				radish->msg.hwnd = NULL;
				radish->msg.lParam = (LPARAM)(result - WAIT_OBJECT_0);
				radish->msg.wParam = (WPARAM)radish->wait_objects[radish->msg.lParam];
				radish_script_step(radish);
				radish_update_maybe(radish);
			}
			else if (result >= WAIT_ABANDONED_0 && result < (WAIT_ABANDONED_0 + radish->wait_object_count)) {
				radish->msg.message = WMRADISH_MUTEX_ABANDONED;
				radish->msg.hwnd = NULL;
				radish->msg.lParam = (LPARAM)(result - WAIT_ABANDONED_0);
				radish->msg.wParam = (WPARAM)radish->wait_objects[radish->msg.lParam];
				radish_script_step(radish);
				radish_update_maybe(radish);
			}
			else if (result == WAIT_TIMEOUT) {
				radish_update_certain(radish);
			}
			else if (result == WAIT_FAILED) {
				radish->error = L"MsgWaitForMultipleObjects Error";
				goto finalize;
			}
			else {
				radish->error = L"Unknown result from MsgWaitForMultipleObjects";
				goto finalize;
			}
		}
	}

finalize:

	if (radish->error != NULL) {
		MessageBoxW(NULL, radish->error, radish_get_title(), MB_OK | MB_ICONERROR);
		return EXIT_FAILURE;
	}
	return EXIT_SUCCESS;
}

int fseek64_wrap(FILE* f, __int64 off, int whence) {
	if(f == NULL) return -1;

#ifdef __MINGW32__
	return fseeko64(f, off, whence);
#elif defined (_WIN32)
	return _fseeki64(f, off, whence);
#else
	return fseek(f, off, whence);
#endif

}
