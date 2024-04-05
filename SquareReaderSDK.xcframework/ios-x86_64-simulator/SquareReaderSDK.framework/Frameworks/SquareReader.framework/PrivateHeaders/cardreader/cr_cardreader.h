// Copyright (c) 2014 Square, Inc. All rights reserved.

// LCR (LibCardReader) is a C library which implements the logic for interacting with an R6
// reader. Internally, LCR is a state machine and is agnostic as to how communication with the R6
// occurs.
//
// LCR functions do not grab locks, make blocking system calls or otherwise block the calling
// thread with the exception of invoking callbacks which also should not block.
//
// LCR is organized around a set of features with each feature defining functions to manipulate the
// reader or request data from the reader and a set of callbacks that are invoked when requested
// data arrives or a requested operation completes. LCR features provide an object oriented C
// interface. The callback structs (e.g. cr_*_api_t) are essentially a class with virtual
// functions.
//
// THREAD SAFETY: LCR is not thread safe and all calls to LCR functions must be externally
// synchronized. If a mutex is used for external synchronization LCR callbacks will be invoked with
// that mutex held. If a serialized dispatch queue is used for synchronization LCR callbacks will
// be invoked on that dispatch queue.
//
// REENTRANCY: LCR is not reentrant. It is an error to invoke an LCR function from an LCR
// callback. Doing so will sometimes result in an assert and could potentally cause a crash
// or other bad behavior.

#pragma once

#include <cardreader_shared/crs_log.h>
#include <cardreader_shared/crs_timer.h>
#include <cardreader/cr_comms_types.h>
#include <cardreader/cr_comms_driver_api.h>
#include <cardreader/cr_comms_backend_api.h>
#include <cardreader/cr_payment_defines.h>
#include <cardreader_shared/crs_securesession_utils.h>
#include <cardreader_shared/crs_spe_device.h>
#include <cardreader_shared/crs_capability.h>
#include <cardreader_shared/crs_feature_flags.h>

#include <stddef.h>
#include <stdint.h>
#include <stdbool.h>

struct cr_cardreader_t;

// Possible result codes for cr_cardreader_* functions.
typedef enum
{
    CR_CARDREADER_RESULT_SUCCESS = 0,
    CR_CARDREADER_RESULT_INVALID_PARAMETER,
    CR_CARDREADER_RESULT_OUT_OF_MEMORY,
    CR_CARDREADER_RESULT_NOT_INITIALIZED,
    CR_CARDREADER_RESULT_NOT_TERMINATED,
    CR_CARDREADER_RESULT_ALREADY_INITIALIZED,
    CR_CARDREADER_RESULT_ENDPOINT_NOT_REGISTERED,
    CR_CARDREADER_RESULT_ENDPOINT_ALREADY_REGISTERED,
    CR_CARDREADER_RESULT_FEATURE_NOT_ENABLED,
    CR_CARDREADER_RESULT_FEATURE_ALREADY_ENABLED,
    CR_CARDREADER_RESULT_SEND_MSG_ENDPOINT_BACKPRESSURE,
    CR_CARDREADER_RESULT_SEND_MSG_NOT_CONNECTED,
    CR_CARDREADER_RESULT_COMMS_ERROR,
    CR_CARDREADER_RESULT_DECODE_FAILED,
    CR_CARDREADER_RESULT_PROTOCOL_INCOMPATIBLE
} cr_cardreader_result_t;

typedef enum
{
    CR_CARDREADER_COMMS_VERSION_RESULT_OK,
    CR_CARDREADER_COMMS_VERSION_RESULT_CARDREADER_UPDATE_REQUIRED,
    CR_CARDREADER_COMMS_VERSION_RESULT_FIRMWARE_UPDATE_REQUIRED,
} cr_cardreader_comms_version_result_t;

typedef enum {
    CR_CARDREADER_COMMS_SUBSYSTEM_AUDIO,
    CR_CARDREADER_COMMS_SUBSYSTEM_UART
} cr_cardreader_comms_subsystem_t;

typedef struct cr_cardreader_raw_audio_data_t {
    uint8_t num_channels;
    int16_t const * samples;
    size_t num_samples;
    bool loop;
} cr_cardreader_raw_audio_data_t;

typedef struct cr_cardreader_raw_uart_data_t {
    uint8_t const * data;
    size_t data_len;
} cr_cardreader_raw_uart_data_t;

typedef union {
    cr_cardreader_raw_audio_data_t audio;
    cr_cardreader_raw_uart_data_t uart;
} cr_cardreader_raw_reader_data_t;

// Different comms rates which the IN/OUT directions can operate at.
typedef enum {
    CR_CARDREADER_COMMS_RATE_UNKNOWN,
    CR_CARDREADER_COMMS_RATE_AUDIO_LFSR_AND_HAMMING_5_BYTE_BLOCKS_MONO,
    CR_CARDREADER_COMMS_RATE_AUDIO_MANCHESTER_AND_HAMMING_5_BYTE_BLOCKS_MONO,
    CR_CARDREADER_COMMS_RATE_AUDIO_LFSR_AND_HAMMING_5_BYTE_BLOCKS_STEREO,
    CR_CARDREADER_COMMS_RATE_AUDIO_MANCHESTER_AND_HAMMING_5_BYTE_BLOCKS_STEREO,
    CR_CARDREADER_COMMS_RATE_AUDIO_1500_BAUD,
    CR_CARDREADER_COMMS_RATE_AUDIO_6000_BAUD,
} cr_cardreader_comms_rate_t;

// Callback invoked when an error occurs. The endpoint_id corresponds to the EP_* defines specified
// in cardreader_shared/crs_app_msg_hdr.h.
typedef void (*cr_cardreader_error_cb_t)(void *context,
                                         struct cr_cardreader_t *cardreader,
                                         int endpoint_id,
                                         char const *msg);

// on_reader_ready is invoked when the initial communication setup is done and the reader is
// ready for operation. It is an error to perform an reader operation before on_reader_ready is
// invoked.
typedef void (*cr_cardreader_reader_ready_cb_t)(void *impl,
                                                struct cr_cardreader_t *cardreader,
                                                cr_cardreader_reader_type_t reader_type);

// on_reader_error is invoked when an unexpected message is received from the reader. For
// example, receiving the firmware manifest when the manifest was not requested.
typedef void (*cr_cardreader_reader_error_cb_t)(void *impl,
                                                struct cr_cardreader_t *cardreader);

// on_comms_version_acquired is invoked when LCR and reader have discovered transport, app,
// and endpoint version. At this point an update may be required for LCR or firmware before
// any more meaningful communication can occur. If this is the case, the only feature that
// will function is the firmware update feature. A result of CR_CARDREADER_COMMS_VERSION_RESULT_OK
// indicates that all features should behave normally and "full" comms is now established.
typedef void (*cr_cardreader_comms_version_acquired_cb_t)(void *impl,
                                                          struct cr_cardreader_t *cardreader,
                                                          cr_cardreader_comms_version_result_t comms_result,
                                                          uint32_t transport_version,
                                                          uint32_t app_version,
                                                          uint32_t endpoint_version);

typedef struct cr_cardreader_feature_api_t
{
    cr_cardreader_reader_ready_cb_t on_reader_ready;
    cr_cardreader_reader_error_cb_t on_reader_error;
    cr_cardreader_comms_version_acquired_cb_t on_comms_version_acquired;
    // impl holds a user specified pointer that will be passed as the first argument to the above
    // callbacks.
    void *impl;
} cr_cardreader_feature_api_t;

typedef struct cr_cardreader_cfg_t
{
    // Comms driver API struct, constructed using cr_comms_driver_XXX_build_api()
    cr_comms_driver_api_t comms_driver_api;
    // Timer api callbacks.
    crs_timer_api_t timer_api;
    // report_error is invoked in the same circumstances as
    // cr_cardreader_feature_api_t::on_reader_error, but provides more detail about which feature
    // experienced the error and an error message.
    cr_cardreader_error_cb_t report_error;
    // context holds a user specified pointer that will be passed as the first argument to
    // report_error.
    void *context;
    // An optional host feature.
    bool host_feature_valid;
    cr_cardreader_feature_api_t host_feature;
} cr_cardreader_cfg_t;

// Allocates the memory for a cr_cardreader_t.
struct cr_cardreader_t* cr_cardreader_alloc(void);

// Initializes a cr_cardreader_t with the specified configuration. Note that initialization of the
// cardreader may invoke timer callbacks so it is imperative that this function is synchronized.
cr_cardreader_result_t cr_cardreader_init(struct cr_cardreader_t *cardreader, cr_cardreader_cfg_t const *cfg);

// Terminates a cr_cardreader_t, stopping associated timers.
cr_cardreader_result_t cr_cardreader_term(struct cr_cardreader_t *cardreader);

// Frees the memory for a cr_cardreader_t. The cr_cardreader_t must have been previously
// terminated.
cr_cardreader_result_t cr_cardreader_free(struct cr_cardreader_t *cardreader);

// Retrieves the identifier for the cardreader subsystem that can be used for setting a subsystem
// specific log threshold.
crs_log_subsystem_t cr_cardreader_get_log_subsystem(void);

// Sets the crypto api to use for encrypting messages sent to the reader
void cr_cardreader_set_crypto_api(struct cr_cardreader_t *cardreader, crs_securesession_comms_api_t const *crypto_api);

// Notify LCR that a reader has been plugged in.
cr_cardreader_result_t cr_cardreader_notify_reader_plugged(struct cr_cardreader_t * cardreader);

// Notify LCR that a reader has been unplugged
cr_cardreader_result_t cr_cardreader_notify_reader_unplugged(struct cr_cardreader_t * cardreader);

// Attempts to decode an R4 packet.
cr_cardreader_result_t cr_cardreader_decode_r4_packet(struct cr_cardreader_t * cardreader,
                                                      cr_comms_link_type_t link,
                                                      int16_t * samples,
                                                      size_t num_samples,
                                                      cr_comms_packet_t * packet,
                                                      cr_comms_sqlink_demod_stats_t * stats,
                                                      cr_comms_decode_result_t * decode_result);

// Determine whether a feature has been enabled or not. Currently only used for testing.
//
// This should be removed from the public API.
cr_cardreader_result_t cr_cardreader_is_feature_enabled(struct cr_cardreader_t *cardreader,
                                                        cr_cardreader_feature_api_t const *feature,
                                                        bool *out_is_enabled);

bool cr_cardreader_capability_supported(struct cr_cardreader_t *cardreader, crs_capability_t capability);

// Returns a pointer to the current capability list and the list len.
// The list may not be ready when this function gets called or the reader
// may not support capabilities.
void cr_cardreader_get_capabilities_list(struct cr_cardreader_t *cardreader,
                                         crs_capability_t **capability_list,
                                         size_t *capability_list_len);

// Will return a string for cr_cardreader_comms_rate_t to be used for logging purposes on register
char const *cr_cardreader_get_string_for_comms_rate(cr_cardreader_comms_rate_t comms_rate);

void cr_cardreader_get_protocol_versions(uint32_t *transport_version,
                                         uint32_t *app_version,
                                         uint32_t *ep_version);

// Returns true if cardreader has received a capabilities list from the reader or
// capabilities are unsupported.
bool cr_cardreader_capabilities_complete(struct cr_cardreader_t *cardreader);

// Set value/setting for one libcardreader feature flag
cr_cardreader_result_t cr_cardreader_set_lcr_feature_flag(struct cr_cardreader_t *cardreader, const char *feature_name, uint8_t value);

// Get the current value for a libcardreader feature flag
uint8_t cr_cardreader_feature_flag_get_value(struct cr_cardreader_t *cardreader, crs_lcr_feature_flags_t flag);
