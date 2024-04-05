// Copyright (c) 2019 Square, Inc. All rights reserved.

/* pb_encode_ritual.h: Functions to encode protocol buffers as struct-based
 * ritual messages. Depends on pb_encode_ritual.c. The main function is
 * pb_encode_as_ritual. You also need an output stream, and the field
 * descriptions created by nanopb_generator.py.
 */

#ifndef PB_ENCODE_RITUAL_H_INCLUDED
#define PB_ENCODE_RITUAL_H_INCLUDED

#include "pb.h"
#include "pb_encode.h"

#ifdef __cplusplus
extern "C" {
#endif

/* Structure for defining custom output streams. You will need to provide
 * a callback function to write the bytes to your storage, which can be
 * for example a file or a network socket.
 *
 * The callback must conform to these rules:
 *
 * 1) Return false on IO errors. This will cause encoding to abort.
 * 2) You can use state to store your own data (e.g. buffer pointer).
 * 3) pb_write will update bytes_written after your callback runs.
 * 4) Substreams will modify max_size and bytes_written. Don't use them
 *    to calculate any pointers.
 */
typedef struct pb_ostream_ritual_s pb_ostream_ritual_t;
struct pb_ostream_ritual_s
{
#ifdef PB_BUFFER_ONLY
    /* Callback pointer is not used in buffer-only configuration.
     * Having an int pointer here allows binary compatibility but
     * gives an error if someone tries to assign callback function.
     * Also, NULL pointer marks a 'sizing stream' that does not
     * write anything.
     */
    int *callback;
#else
    bool (*callback)(pb_ostream_ritual_t *stream, const uint8_t *buf, size_t count);
#endif
    void *state;          /* Free field for use by callback implementation. */
    size_t max_size;      /* Limit number of output bytes written (or use SIZE_MAX). */
    size_t bytes_written; /* Number of bytes written so far. */
    size_t next_offset;   /* For Ritual encoding: number of bytes to next item */

#ifndef PB_NO_ERRMSG
    const char *errmsg;
#endif
};


/***************************
 * Main encoding functions *
 ***************************/

/* Encode a single protocol buffers message from C structure into a stream.
 * Returns true on success, false on any failure.
 * The actual struct pointed to by src_struct must match the description in fields.
 * All required fields in the struct are assumed to have been filled in.
 *
 * Example usage:
 *    MyMessage msg = {};
 *    uint8_t buffer[64];
 *    pb_ostream_ritual_t stream;
 *
 *    msg.field1 = 42;
 *    stream = pb_ostream_ritual_from_buffer(buffer, sizeof(buffer));
 *    pb_encode(&stream, MyMessage_fields, &msg);
 */
bool pb_encode_as_ritual(pb_ostream_ritual_t *stream, const pb_field_t fields[], const void *src_struct);

/* Encode the message to get the size of the encoded data, but do not store
 * the data. */
bool pb_get_encoded_ritual_size(size_t *size, const pb_field_t fields[], const void *src_struct);

/**************************************
 * Functions for manipulating streams *
 **************************************/

/* Create an output stream for writing into a memory buffer.
 * The number of bytes written can be found in stream.bytes_written after
 * encoding the message.
 *
 * Alternatively, you can use a custom stream that writes directly to e.g.
 * a file or a network socket.
 */
pb_ostream_ritual_t pb_ostream_ritual_from_buffer(uint8_t *buf, size_t bufsize);

/* Pseudo-stream for measuring the size of a message without actually storing
 * the encoded data.
 *
 * Example usage:
 *    MyMessage msg = {};
 *    pb_ostream_ritual_t stream = PB_OSTREAM_SIZING;
 *    pb_encode(&stream, MyMessage_fields, &msg);
 *    printf("Message size is %d\n", stream.bytes_written);
 */
#ifndef PB_NO_ERRMSG
#define PB_OSTREAM_RITUAL_SIZING {0,0,0,0,0,0}
#else
#define PB_OSTREAM_RITUAL_SIZING {0,0,0,0,0}
#endif

/* Function to write into a pb_ostream_ritual_t stream. You can use this if you need
 * to append or prepend some custom headers to the message.
 */
bool pb_write_ritual(pb_ostream_ritual_t *stream, const uint8_t *buf, size_t count);


#ifdef __cplusplus
} /* extern "C" */
#endif

#endif
