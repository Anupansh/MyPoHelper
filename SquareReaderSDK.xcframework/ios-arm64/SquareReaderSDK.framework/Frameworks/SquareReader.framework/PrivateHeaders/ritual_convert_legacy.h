// Copyright 2017 Square, Inc.

#pragma once

#include <stddef.h>
#include <stdint.h>

// If message is the legacy version of RIT_system_system_info, updates c and/or c_length to use the new message struct.
// 4183 is the last production firmware release to use the legacy struct.
void ritual_convert_legacy_system_info_msg(void *c, size_t *c_length, size_t max_length, int endpoint_id, uint32_t msg_type);
