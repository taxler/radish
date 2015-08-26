
#ifndef RADISH_SCRIPTING_DOT_H
#define RADISH_SCRIPTING_DOT_H

#include "radish-state.h"

void* radish_create_script_fiber(radish_state* radish);
BOOL radish_script_running(radish_state* radish);

#endif
