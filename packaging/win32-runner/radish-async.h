
#ifndef RADISH_ASYNC_DOT_H
#define RADISH_ASYNC_DOT_H

#include "radish-state.h"

#define bool32 BOOL

//@@BEGIN:EXPORTS@@ @@ORDER:100@@

typedef enum {
	PROGRESSING_COPY,
	PROGRESSING_MOVE
} radish_progressing_file_op_type;

typedef struct radish_progressing_file_op {
	radish_state* radish;
	radish_progressing_file_op_type type;
	wchar_t* path1;
	wchar_t* path2;
	unsigned __int32 flags;
	bool32 cancel;
	bool32 result;
	void* fiber;
	__int64 total_file_size;
	__int64 total_bytes_transferred;
	__int64 stream_size;
	__int64 stream_bytes_transferred;
	unsigned __int32 stream_number;
	unsigned __int32 callback_reason;
	void* file_handle_source;
	void* file_handle_destination;
} radish_progressing_file_op;

radish_progressing_file_op* radish_begin_progressing_file_op(
	radish_state* radish,
	radish_progressing_file_op_type type,
	const wchar_t* path1,
	const wchar_t* path2,
	unsigned __int32 flags);

bool32 radish_continue_progressing_file_op(radish_progressing_file_op*);

void radish_free_progressing_file_op(radish_progressing_file_op*);

//@@END:EXPORTS@@

#undef bool32

#endif
