// Copyright 2017 Square, Inc.

#pragma once

#include <pb_encode.h>
#include <pb_decode.h>

#include <stdbool.h>
#include <stddef.h>
#include <stdint.h>

bool cardreader_rpc_pb_write(pb_ostream_t *stream, uint8_t const *buf, size_t count);
bool cardreader_rpc_pb_read(pb_istream_t *stream, uint8_t *buf, size_t count);
