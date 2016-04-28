
#include <stdio.h>

#ifdef _WIN32
#include <windows.h>
int WINAPI WinMain(HINSTANCE instance, HINSTANCE prev_instance, char* command_line, int show_command) {
#else
int main(int argc, char*[] argv) {
#endif

	return 0;

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

#define radish_state void
#define radish_buffer void
#define radish_dialog void
#define bool32 int
#define radish_progressing_file_op void
radish_state* radish_get_state() { return NULL; }
void radish_wait_message(radish_state* state) { }
void radish_request_dialog(radish_state* state, radish_dialog* dialog) { }
unsigned __int32 radish_create_thread(const wchar_t* init_script_name) { return 0; }
bool32 radish_send_thread(unsigned __int32 id, const unsigned __int8* data, size_t data_size) { return 0; }
radish_buffer* radish_buffer_alloc(size_t len) { return NULL; }
void radish_buffer_free(radish_buffer* buffer) { }
radish_buffer* radish_buffer_for_wstring(const wchar_t* wstr) { return NULL; }
radish_buffer* radish_buffer_for_bytes(const void* data, size_t len) { return NULL; }
const wchar_t* radish_buffer_to_wstring(const radish_buffer* buffer, size_t* out_len) { return NULL; }
const void* radish_buffer_to_bytes(const radish_buffer* buffer, size_t* out_len) { return NULL; }
typedef enum {
	PROGRESSING_COPY,
	PROGRESSING_MOVE
} radish_progressing_file_op_type;
radish_progressing_file_op* radish_begin_progressing_file_op(
	radish_state* radish,
	radish_progressing_file_op_type type,
	const wchar_t* path1,
	const wchar_t* path2,
	unsigned __int32 flags) { return NULL; }
bool32 radish_continue_progressing_file_op(radish_progressing_file_op* op) { return 0; }
void radish_free_progressing_file_op(radish_progressing_file_op* op) { }
#undef radish_state
#undef radish_buffer
#undef bool32
