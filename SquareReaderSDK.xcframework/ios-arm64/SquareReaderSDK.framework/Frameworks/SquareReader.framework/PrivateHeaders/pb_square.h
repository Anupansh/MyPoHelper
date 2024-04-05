/*
 * Square helpers and extensions for dealing with nanopb.
 */

#pragma once

#include "pb.h"
#include <square.h>
#include <string.h>

// When compiling unit tests on non-BSD systems, define strlcpy
#if !__APPLE__ && (TARGET_LINUX || UNIT_TESTS)
size_t strlcpy(char *dst, const char *src, size_t size);
#endif

// helper to set optional values and has_<field>
#define PB_SET(PB, FIELD, VALUE) \
    do { \
        (PB)->FIELD = (VALUE); \
        (PB)->has_##FIELD = true; \
    } while (0)

#define PB_SET_BYTES(PB, FIELD, DATA, SIZE) \
      do { \
          SQ_ASSERT(SIZE <= sizeof((PB)->FIELD.bytes)); \
          const void *_pb_set_data = (DATA); \
          if (_pb_set_data != NULL) { \
              memmove((PB)->FIELD.bytes, _pb_set_data, (SIZE)); \
          } \
          (PB)->FIELD.size = (pb_size_t)(SIZE); \
          (PB)->has_##FIELD = true; \
      } while (0)

// Note: silent truncation of src string is possible
#define PB_SET_STRING(PB, FIELD, DATA, SIZE) \
    do { \
        SQ_ASSERT((SIZE) <= sizeof((PB)->FIELD)); \
        SQ_ASSERT((DATA) != NULL); \
        (void)strlcpy((PB)->FIELD, (DATA), (SIZE)); \
        (PB)->has_##FIELD = true; \
    } while (0)

typedef struct pb_raw_bytes_t
{
    uint8_t *bytes;
    size_t len;
    bool was_called;
} pb_raw_bytes_t;

/*
 Helper function to setup the encode callback of a pb_callback_t field.
 Should not be called directly, pb_encode() will call this function when encoding the corresponding field.

 stream: the output stream which contains the buffer which will store the proto.
 field: the field being encoded. We do not use this parameter in our implementation.
 arg: the data that will be encoded in a pb_raw_bytes_t struct.
 */
bool sq_pb_encode_callback(pb_ostream_t *stream, const pb_field_t *field, void * const *arg);

/*
 Helper function to setup the decode callback of a pb_callback_t field.
 Should not be called directly, pb_decode() will call this function when decoding the corresponding field.

 stream: the output stream which contains the buffer which will store the proto.
 field: the field being decoded. We do not use this parameter in our implementation.
 arg: the buffer that will be store the field in a pb_raw_bytes_t struct.
      The size of the buffer should be set before calling pb_decode().
      The size of the written buffer is available after calling pb_decode().
 */
bool sq_pb_decode_callback(pb_istream_t *stream, const pb_field_t *field, void **arg);
