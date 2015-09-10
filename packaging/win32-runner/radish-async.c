
#include <windows.h>

#include "radish-state.h"
#include "radish-async.h"
#include "radish-scripting.h"
#include "radish-text.h"

DWORD CALLBACK file_op_progress_proc(
		LARGE_INTEGER TotalFileSize,
		LARGE_INTEGER TotalBytesTransferred,
		LARGE_INTEGER StreamSize,
		LARGE_INTEGER StreamBytesTransferred,
		DWORD dwStreamNumber,
		DWORD dwCallbackReason,
		HANDLE hSourceFile,
		HANDLE hDestinationFile,
		LPVOID lpData) {
	radish_progressing_file_op* fop = (radish_progressing_file_op*)lpData;

	radish_do_pending_events(fop->radish);

	fop->total_file_size = TotalFileSize.QuadPart;
	fop->total_bytes_transferred = TotalBytesTransferred.QuadPart;
	fop->stream_size = StreamSize.QuadPart;
	fop->stream_bytes_transferred = StreamBytesTransferred.QuadPart;
	fop->stream_number = dwStreamNumber;
	fop->callback_reason = dwCallbackReason;
	fop->file_handle_source = hSourceFile;
	fop->file_handle_destination = hDestinationFile;

	fop->radish->msg.message = WMRADISH_FILE_OP_PROGRESS;
	fop->radish->msg.lParam = (LPARAM)fop;
	SwitchToFiber(fop->radish->script_fiber); // should always switch back
	if (fop->radish->msg.message == WMRADISH_FILE_OP_CANCEL) {
		fop->cancel = TRUE;
		return PROGRESS_CANCEL;
	}
	return PROGRESS_CONTINUE;
	// PROGRESS_QUIET: continue but don't call this procedure any more
	// PROGRESS_STOP: stop but may be resumed

}

VOID CALLBACK fiberproc_progressing_file_op(LPVOID userdata) {
	radish_progressing_file_op* fop = (radish_progressing_file_op*)userdata;
	switch (fop->type) {
		case PROGRESSING_COPY:
			fop->result = CopyFileExW(fop->path1, fop->path2, file_op_progress_proc, fop, &fop->cancel, fop->flags);
			break;
		case PROGRESSING_MOVE:
			fop->result = MoveFileWithProgressW(fop->path1, fop->path2, file_op_progress_proc, fop, fop->flags);
			break;
	}
	fop->radish->msg.message = WMRADISH_FILE_OP_COMPLETE;
	fop->radish->msg.lParam = (LPARAM)fop;
	SwitchToFiber(fop->radish->script_fiber); // should free fop and never return
}

radish_progressing_file_op* radish_begin_progressing_file_op(
		radish_state* radish,
		radish_progressing_file_op_type type,
		const wchar_t* path1,
		const wchar_t* path2,
		DWORD flags) {

	radish_progressing_file_op* fop = (radish_progressing_file_op*)malloc(sizeof(radish_progressing_file_op));
	memset(fop, 0, sizeof(radish_progressing_file_op));
	fop->radish = radish;
	fop->type = type;
	fop->path1 = radish_clone_wstring(path1);
	fop->path2 = radish_clone_wstring(path2);
	fop->flags = flags;
	fop->fiber = CreateFiber(0, fiberproc_progressing_file_op, fop);

	return fop;
}

BOOL radish_continue_progressing_file_op(radish_progressing_file_op* fop) {
	if (fop->fiber == NULL) return FALSE;
	SwitchToFiber(fop->fiber);
	if (fop->radish->msg.message == WMRADISH_FILE_OP_COMPLETE) {
		DeleteFiber(fop->fiber);
		fop->fiber = NULL;
	}
	return TRUE;
}

void radish_free_progressing_file_op(radish_progressing_file_op* fop) {
	free(fop->path1);
	free(fop->path2);
	if (fop->fiber != NULL) {
		DeleteFiber(fop->fiber);
	}
	free(fop);
}
