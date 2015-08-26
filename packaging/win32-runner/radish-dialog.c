
#include "radish-state.h"
#include "radish-dialog.h"
#include "radish-resources.h"

void radish_do_dialog(radish_state* radish, radish_dialog* dialog) {
	int retcode;
	if (dialog == NULL || radish == NULL) {
		return;
	}
	switch(dialog->type) {
		case RADISH_DIALOG_ALERT:
			MessageBoxW(
				radish->host_window == NULL ? NULL : radish->host_window->hwnd,
				dialog->alert.text == NULL ? L"" : dialog->alert.text,
				dialog->alert.override_title == NULL ? radish_get_title() : dialog->alert.override_title,
				MB_OK | (dialog->alert.harsh ? MB_ICONERROR : MB_ICONINFORMATION));
			break;
		case RADISH_DIALOG_CONFIRM:
			retcode = MessageBoxW(
				radish->host_window == NULL ? NULL : radish->host_window->hwnd,
				dialog->confirm.text,
				dialog->confirm.override_title == NULL ? radish_get_title() : dialog->confirm.override_title,
				(dialog->confirm.can_cancel ? MB_YESNOCANCEL : MB_YESNO)
					| (dialog->alert.harsh ? MB_ICONWARNING : MB_ICONQUESTION));
			switch (retcode) {
				case IDYES:
					dialog->confirm.response = 'y';
					break;
				case IDNO:
					dialog->confirm.response = 'n';
					break;
				case IDCANCEL:
					dialog->confirm.response = 'x';
					break;
			}
			break;
	}
}

void radish_free_dialog(radish_state* radish, radish_dialog* dialog) {
	switch(dialog->type) {
		case RADISH_DIALOG_ALERT:
			free(dialog->alert.text);
			free(dialog->alert.override_title);
			break;
		case RADISH_DIALOG_CONFIRM:
			free(dialog->confirm.text);
			free(dialog->confirm.override_title);
			break;
	}
	free(dialog);
}

void radish_request_dialog(radish_state* radish, radish_dialog* dialog) {
	radish_dialog* dialog_copy = NULL;
	size_t text_size;
	if (radish == NULL || dialog == NULL) {
		return;
	}
	switch(dialog->type) {
		case RADISH_DIALOG_ALERT:
			dialog_copy = (radish_dialog*)malloc(sizeof(radish_dialog));
			dialog_copy->type = dialog->type;
			dialog_copy->id = dialog->id;
			if (dialog->alert.text == NULL) {
				dialog_copy->alert.text = NULL;
			}
			else {
				text_size = wcslen(dialog->alert.text);
				dialog_copy->alert.text = (wchar_t*)malloc(sizeof(wchar_t) * (text_size + 1));
				wcsncpy(dialog_copy->alert.text, dialog->alert.text, text_size);
				dialog_copy->alert.text[text_size] = 0;
			}
			if (dialog->alert.override_title == NULL) {
				dialog_copy->alert.override_title = NULL;
			}
			else {
				text_size = wcslen(dialog->alert.override_title);
				dialog_copy->alert.override_title = (wchar_t*)malloc(sizeof(wchar_t) * (text_size + 1));
				wcsncpy(dialog_copy->alert.override_title, dialog->alert.override_title, text_size);
				dialog_copy->alert.override_title[text_size] = 0;
			}
			dialog_copy->alert.harsh = dialog->alert.harsh;
			break;
		case RADISH_DIALOG_CONFIRM:
			dialog_copy = (radish_dialog*)malloc(sizeof(radish_dialog));
			dialog_copy->type = dialog->type;
			dialog_copy->id = dialog->id;
			if (dialog->confirm.text == NULL) {
				dialog_copy->confirm.text = NULL;
			}
			else {
				text_size = wcslen(dialog->confirm.text);
				dialog_copy->confirm.text = (wchar_t*)malloc(sizeof(wchar_t) * (text_size + 1));
				wcsncpy(dialog_copy->confirm.text, dialog->confirm.text, text_size);
				dialog_copy->confirm.text[text_size] = 0;
			}
			if (dialog->confirm.override_title == NULL) {
				dialog_copy->confirm.override_title = NULL;
			}
			else {
				text_size = wcslen(dialog->confirm.override_title);
				dialog_copy->confirm.override_title = (wchar_t*)malloc(sizeof(wchar_t) * (text_size + 1));
				wcsncpy(dialog_copy->confirm.override_title, dialog->confirm.override_title, text_size);
				dialog_copy->confirm.override_title[text_size] = 0;
			}
			dialog_copy->confirm.harsh = dialog->confirm.harsh;
			dialog_copy->confirm.can_cancel = dialog->confirm.can_cancel;
			break;
	}
	if (dialog_copy != NULL) {
		PostMessage(
			radish->host_window == NULL ? NULL : radish->host_window->hwnd,
			WMRADISH_DIALOG_REQUEST,
			0,
			(LPARAM)(void*)dialog_copy);
	}
}
