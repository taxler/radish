
#ifndef RADISH_DIALOG_DOT_H
#define RADISH_DIALOG_DOT_H

#include <windows.h>

#define bool32 BOOL

//@@BEGIN:EXPORTS@@ @@ORDER:100@@

typedef enum {
	RADISH_DIALOG_ALERT,
	RADISH_DIALOG_CONFIRM
} radish_dialog_type;

typedef struct radish_dialog {
	radish_dialog_type type;
	int id;
	union {
		struct {
			wchar_t* text;
			wchar_t* override_title;
			bool32 harsh;
		} alert;
		struct {
			wchar_t* text;
			wchar_t* override_title;
			bool32 harsh;
			bool32 can_cancel;
			char response; // 'y'/'n'/'x' for yes/no/cancel
		} confirm;
	};
} radish_dialog;

void radish_request_dialog(radish_state*, radish_dialog*);

//@@END:EXPORTS@@

void radish_do_dialog(radish_state*, radish_dialog*);
void radish_free_dialog(radish_state*, radish_dialog*);

#undef bool32

#endif
