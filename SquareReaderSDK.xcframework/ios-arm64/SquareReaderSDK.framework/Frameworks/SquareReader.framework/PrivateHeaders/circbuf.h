// Copyright 2017 Square, Inc.

#pragma once

#include <stdbool.h>
#include <stdint.h>
#include <stdlib.h>

typedef struct circbuf_stats_t {
    int overflows;
    size_t max_length;
    int pushes;
    int pops;
} circbuf_stats_t;

typedef struct circbuf_info_t {
    size_t size;
    uint32_t head;
    uint32_t tail;
    size_t capacity;
    uint8_t *data;
    bool replace_when_full;
    circbuf_stats_t stats;
} circbuf_info_t;

void circbuf_init(circbuf_info_t *circbuf, size_t capacity, uint8_t *data, bool replace_when_full);

// How much data is in the buffer?
size_t circbuf_get_length(circbuf_info_t *circbuf);

// How much data can we still put in the buffer ?
size_t circbuf_get_available(circbuf_info_t *circbuf);

// Returns true if the circular buffer has overflowed.
bool circbuf_push(circbuf_info_t *circbuf, uint8_t value);

uint8_t circbuf_pop(circbuf_info_t *circbuf);

// Returns number of bytes that were available
uint32_t circbuf_peek(circbuf_info_t *circbuf, uint8_t *dest, size_t num_bytes);

// Returns the number of bytes inserted.
size_t circbuf_insert(circbuf_info_t *circbuf, void const *src, size_t num_bytes);

// Removes num_bytes of data from the head of the buffer.
// Removes length bytes if num_bytes is greater than length.
// Returns the number of bytes removed.
size_t circbuf_remove(circbuf_info_t *circbuf, size_t num_bytes);

// Removes all data from the buffer.
void circbuf_clear(circbuf_info_t *circbuf);

// Returns a pointer to head, followed by num_bytes of contiguous data, rotating
// the buffer if necessary to ensure the data is linear within the buffer.
uint8_t *circbuf_data(circbuf_info_t *circbuf, size_t num_bytes);
