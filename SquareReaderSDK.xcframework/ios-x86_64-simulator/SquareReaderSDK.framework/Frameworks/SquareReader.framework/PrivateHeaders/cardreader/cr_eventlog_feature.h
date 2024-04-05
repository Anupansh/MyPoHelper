// Copyright (c) 2014 Square, Inc. All rights reserved.

#pragma once

#include <cardreader_shared/crs_eventlog_utils.h>
#include <cardreader_shared/crs_log.h>

#include <stdint.h>
#include <stddef.h>

// Possible result codes for cr_eventlog_* functions.
typedef enum
{
    CR_EVENTLOG_RESULT_SUCCESS = 0,
    CR_EVENTLOG_RESULT_INVALID_PARAMETER,
    CR_EVENTLOG_RESULT_NOT_INITIALIZED,
    CR_EVENTLOG_RESULT_ALREADY_INITIALIZED,
    CR_EVENTLOG_RESULT_NOT_TERMINATED,
    CR_EVENTLOG_RESULT_ALREADY_TERMINATED,
    CR_EVENTLOG_RESULT_SESSION_ERROR,
    CR_EVENTLOG_RESULT_CALL_UNEXPECTED,
} cr_eventlog_result_t;

struct cr_cardreader_t;
struct cr_eventlog_t;

typedef void (*cr_eventlog_feature_parsed_events_cb_t)(void *context,
                                                      crs_eventlog_utils_parsed_event_t const *events,
                                                      size_t num_events);

// Callback invoked when the reader provides eventlog data. The events encoded in the data can
// be decoded using the crs_eventlog_utils_is_valid_event and
// crs_eventlog_utils_get_strings_from_data functions in cardreader_shared/crs_eventlog_utils.h.
typedef void (*cr_eventlog_data_cb_t)(void *context, struct cr_eventlog_t *eventlog, uint8_t const *data, size_t data_len);

// Callback invoked when the reader provides a complete set of profile data (potentially profiles
// for multiple chips). See `spepy.firmware_profile` for decoding functionality.
typedef void (*cr_eventlog_profile_cb_t)(void *context, struct cr_eventlog_t *eventlog, uint8_t const *data, size_t data_len);

typedef struct cr_eventlog_event_api_t {
    // on_data_received is invoked when LCR receives eventlog data. This data is sent back
    // periodically by the reader and not in response to any specific public LCR function.
    cr_eventlog_data_cb_t on_data_received;
    cr_eventlog_profile_cb_t on_profile_received;
    // context holds a user specified pointer that will be passed as the first argument to the
    // above callback.
    void *context;
} cr_eventlog_event_api_t;

// Allocates the memory for a cr_power_t.
struct cr_eventlog_t *cr_eventlog_alloc(void);

// Initializes a cr_eventlog_t with the specified callbacks and registers the feature with the
// specified cardreader.
cr_eventlog_result_t cr_eventlog_init(struct cr_eventlog_t *eventlog, struct cr_cardreader_t *cardreader, cr_eventlog_event_api_t const *api);

// Terminates a cr_eventlog_t, deregistering the feature.
cr_eventlog_result_t cr_eventlog_term(struct cr_eventlog_t *eventlog);

// Frees the memory for a cr_eventlog_t. The cr_eventlog_t must have been previously terminated.
cr_eventlog_result_t cr_eventlog_free(struct cr_eventlog_t *eventlog);

// Retrieves the identifier for the eventlog subsystem that can be used for setting a subsystem
// specific log threshold.
crs_log_subsystem_t cr_eventlog_get_log_subsystem(void);

// Returns true if the connected SPE uses num_param eventlog encoding
bool cr_eventlog_uses_num_param_encoding(void *context, struct cr_eventlog_t *eventlog);

uint32_t cr_eventlog_feature_get_strings_from_data(void *context, struct cr_eventlog_t *eventlog, cr_eventlog_feature_parsed_events_cb_t eventlog_parsed_events_cb, uint8_t const *parse_buf, size_t buf_len);

crs_eventlog_utils_buffer_state_t cr_eventlog_feature_is_valid_event(struct cr_eventlog_t *eventlog, uint8_t const *data, int data_len);
