
#ifndef RADISH_SCRIPTING_DOT_H
#define RADISH_SCRIPTING_DOT_H

#include "radish-state.h"

void* radish_create_script_fiber(radish_state* radish);
BOOL radish_script_running(radish_state* radish);
void radish_update_first(radish_state* radish);
void radish_update_maybe(radish_state* radish);
void radish_update_certain(radish_state* radish);
DWORD radish_update_timeout(radish_state* radish);
BOOL radish_do_waiting_objects(radish_state* radish);

#endif
