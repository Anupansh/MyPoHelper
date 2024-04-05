// Copyright (c) 2014 Square, Inc. All rights reserved.

#pragma once

#include <stdint.h>
#include <stddef.h>
#include <stdbool.h>

struct cr_securesession_feature_t;
struct cr_cardreader_t;
struct cr_card_info_t;

// Possible result codes for cr_securesession_* functions.
typedef enum
{
    CR_SECURESESSION_FEATURE_RESULT_SUCCESS = 0,
    CR_SECURESESSION_FEATURE_RESULT_INVALID_PARAMETER,
    CR_SECURESESSION_FEATURE_RESULT_NOT_INITIALIZED,
    CR_SECURESESSION_FEATURE_RESULT_ALREADY_INITIALIZED,
    CR_SECURESESSION_FEATURE_RESULT_NOT_TERMINATED,
    CR_SECURESESSION_FEATURE_RESULT_ALREADY_TERMINATED,

    // "Session" has nothing to do with securesession.. this is a normal LCR
    // feature lifecycle term used in most other features
    CR_SECURESESSION_FEATURE_RESULT_SESSION_ERROR,

    CR_SECURESESSION_FEATURE_RESULT_CALL_UNEXPECTED,
    CR_SECURESESSION_FEATURE_RESULT_GENERIC_ERROR,
    CR_SECURESESSION_FEATURE_RESULT_NO_READER,

    // These two error codes are the funneled-up versions of the securesession
    // (used-to-be-submodule) code under the hood.  At this level, we only care
    // about whether or not the server explicitly denied a session request --
    // all other errors are funneled to the MODULE_GENERIC_ERROR
    CR_SECURESESSION_FEATURE_RESULT_SERVER_DENY_ERROR,
    CR_SECURESESSION_FEATURE_RESULT_MODULE_GENERIC_ERROR,
    CR_SECURESESSION_FEATURE_RESULT_MAX_READERS_CONNECTED,

    // These result codes were added to match `securesession_result_t`.
    CR_SECURESESSION_FEATURE_RESULT_ARG,
    CR_SECURESESSION_FEATURE_RESULT_SESSION_STATE,
    CR_SECURESESSION_FEATURE_RESULT_INPUT_SIZE,
    CR_SECURESESSION_FEATURE_RESULT_OUTPUT_SIZE,
    CR_SECURESESSION_FEATURE_RESULT_MSG_TYPE,
    CR_SECURESESSION_FEATURE_RESULT_SESSION_ID,
    CR_SECURESESSION_FEATURE_RESULT_CURVE,
    CR_SECURESESSION_FEATURE_RESULT_HKDF,
    CR_SECURESESSION_FEATURE_RESULT_DENIED,
    CR_SECURESESSION_FEATURE_RESULT_BAD_DIGIT,
    CR_SECURESESSION_FEATURE_RESULT_PIN_FULL,
    CR_SECURESESSION_FEATURE_RESULT_PIN_TOO_SHORT,
    CR_SECURESESSION_FEATURE_RESULT_INVALID_PIN_REQUEST,
    CR_SECURESESSION_FEATURE_RESULT_INVALID_KEY_UPDATE_MSG,
    CR_SECURESESSION_FEATURE_RESULT_AES,
    CR_SECURESESSION_FEATURE_RESULT_PROTOCOL_VERSION,
    CR_SECURESESSION_FEATURE_RESULT_APPROVAL_MISMATCH,
    CR_SECURESESSION_FEATURE_RESULT_APPROVAL_EXPIRED,
    CR_SECURESESSION_FEATURE_RESULT_NO_TXN_LEFT,
    CR_SECURESESSION_FEATURE_RESULT_API_CALL,
    CR_SECURESESSION_FEATURE_RESULT_MINESWEEPER_CALL,
    CR_SECURESESSION_FEATURE_RESULT_SHA256,
    CR_SECURESESSION_FEATURE_RESULT_BAD_HMAC,
    CR_SECURESESSION_FEATURE_RESULT_TDES,
    CR_SECURESESSION_FEATURE_RESULT_ENCODE_FAILURE,
    CR_SECURESESSION_FEATURE_RESULT_CONTEXT,
    CR_SECURESESSION_FEATURE_RESULT_OUT_OF_CONTEXTS,
    CR_SECURESESSION_FEATURE_RESULT_BAD_FIELD,
    CR_SECURESESSION_FEATURE_RESULT_WHITEBOX_KEY_DESERIALIZE,
    CR_SECURESESSION_FEATURE_RESULT_UNKNOWN
} cr_securesession_feature_result_t;

// A validate message. Should be sent to the /1.0/flipper/session/validate endpoint.
typedef enum
{
    CR_SECURESESSION_FEATURE_SERVER_MSG_VALIDATE,
} cr_securesession_feature_server_msg_type_t;

// A server error.
typedef enum
{
    // The default error
    CR_SECURESESSION_FEATURE_SERVER_ERROR_GENERIC_ERROR = 0,

    // LCR errors
    CR_SECURESESSION_FEATURE_SERVER_ERROR_PARSE_ERROR,

    // Server Errors
    CR_SECURESESSION_FEATURE_SERVER_ERROR_UNKNOWN_DENY_REASON,
    CR_SECURESESSION_FEATURE_SERVER_ERROR_NOT_DENIED,
    CR_SECURESESSION_FEATURE_SERVER_ERROR_SELLER_SUSPENDED,
    CR_SECURESESSION_FEATURE_SERVER_ERROR_SELLER_NOT_ELIGIBLE,
    CR_SECURESESSION_FEATURE_SERVER_ERROR_DEVICE_HARDWARE_NOT_SUPPORTED,
    CR_SECURESESSION_FEATURE_SERVER_ERROR_DEVICE_FIRMWARE_TOO_OLD,
    CR_SECURESESSION_FEATURE_SERVER_ERROR_DEVICE_FIRMWARE_NOT_SUPPORTED,
    CR_SECURESESSION_FEATURE_SERVER_ERROR_DEVICE_FIRMWARE_MODIFIED,
    CR_SECURESESSION_FEATURE_SERVER_ERROR_DEVICE_FIRMWARE_DAMAGED,
    CR_SECURESESSION_FEATURE_SERVER_ERROR_DEVICE_IN_DEVELOPER_MODE,
    CR_SECURESESSION_FEATURE_SERVER_ERROR_APP_TOO_OLD,
    CR_SECURESESSION_FEATURE_SERVER_ERROR_APP_DAMAGED,
    CR_SECURESESSION_FEATURE_SERVER_ERROR_INVALID_REQUEST,
    CR_SECURESESSION_FEATURE_SERVER_ERROR_DEVICE_IN_ACCESSIBILITY_MODE,
    CR_SECURESESSION_FEATURE_SERVER_ERROR_SELLER_NOT_ACTIVATED,

    // No errors
    CR_SECURESESSION_FEATURE_SERVER_ERROR_NONE,
} cr_securesession_feature_server_error_t;

typedef enum
{
    CR_SECURESESSION_FEATURE_SERVER_UX_HINT_DO_NOT_USE = 0,
    CR_SECURESESSION_FEATURE_SERVER_UX_HINT_NO_SUGGESTED_ACTION,
    CR_SECURESESSION_FEATURE_SERVER_UX_HINT_SUGGEST_RETRY,
    CR_SECURESESSION_FEATURE_SERVER_UX_HINT_SUGGEST_ACTIVATION,
    CR_SECURESESSION_FEATURE_SERVER_UX_HINT_SUGGEST_CONTACT_SUPPORT,
    // This should always be the last element of the enum.
    CR_SECURESESSION_FEATURE_SERVER_UX_HINT_COUNT
} cr_securesession_feature_server_ux_hint_t;

// Possible event codes that the secure session feature can indicate.
typedef enum
{
    CR_SECURESESSION_FEATURE_EVENT_TYPE_SESSION_VALID,
    CR_SECURESESSION_FEATURE_EVENT_TYPE_SESSION_INVALID,
} cr_securesession_feature_event_type_t;

// Informational data about a secure session.
typedef struct cr_securesession_feature_session_data_t
{
    uint32_t session_id;
    uint32_t reader_transaction_count;
    uint32_t reader_utc_epoch_time;
} cr_securesession_feature_session_data_t;

typedef struct cr_securesession_feature_server_ux_hint_array_t
{
    uint32_t count;
    cr_securesession_feature_server_ux_hint_t *ux_hints;
} cr_securesession_feature_server_ux_hint_array_t;


// on_send_to_server is invoked when LCR needs to send secure session data to the server. The
// msg_type parameter indicates the type of message being sent which should be used to dispatch
// to the correct endpoint on the server. The data itself (len bytes of buf) is raw and might
// need to be (base64) encoded depending on the message type. This callback may be invoked at
// arbitrary times.
typedef void (*cr_securesession_feature_send_to_server_cb_t)(
                void *context,
                struct cr_securesession_feature_t *securesession,
                cr_securesession_feature_server_msg_type_t msg_type,
                void const *buf,
                size_t buf_len);

// on_session_event is invoked when a secure session occurs such as the session becoming valid
// or invalid. A valid secure session is required for chip card payment functionality.
typedef void (*cr_securesession_feature_session_event_cb_t)(
                void *context,
                struct cr_securesession_feature_t *securesession,
                cr_securesession_feature_session_data_t *session_data,
                cr_securesession_feature_event_type_t event_type);

// on_pin_requested is invoked when LCR requires a pin in order to complete a payment. This is
// part of the secure session api as the pin input needs to be implemented by obfuscated code
// (a.k.a minesweeper).
typedef void (*cr_securesession_feature_pin_requested_cb_t)(
                void *context,
                struct cr_securesession_feature_t *securesession,
                struct cr_card_info_t const *card_info,
                bool can_bypass_pin,
                bool final_pin_attempt);

typedef struct cr_securesession_feature_event_api_t
{
    cr_securesession_feature_send_to_server_cb_t on_send_to_server;
    cr_securesession_feature_session_event_cb_t on_session_event;
    cr_securesession_feature_pin_requested_cb_t on_pin_requested;
    void *context;
} cr_securesession_feature_event_api_t;

// Allocates the memory for a cr_securesession_feature_t.
struct cr_securesession_feature_t *cr_securesession_feature_alloc(void);

// Configure this secure session feature with the provided whitebox key, which will be copied and store internally.
// This must be done after alloc, but before init.
// NULL is a valid whitebox key, and in fact is the only valid value for POS builds of LCR (as opposed to PaySDK, which require a non-NULL key).
cr_securesession_feature_result_t cr_securesession_feature_set_whitebox_key(struct cr_securesession_feature_t *securesession, void *whitebox_key, size_t whitebox_key_len);

// Initializes a cr_securesession_feature_t with the specified callbacks and registers the feature
// with the specified cardreader.
cr_securesession_feature_result_t cr_securesession_feature_init(struct cr_securesession_feature_t *securesession,
                                                                struct cr_cardreader_t *cardreader,
                                                                struct cr_securesession_feature_event_api_t const *event_api);

// Terminates a cr_securesession_feature_t, deregistering the feature.
cr_securesession_feature_result_t cr_securesession_feature_term(struct cr_securesession_feature_t *securesession);

// Frees the memory for a cr_securesession_feature_t. The cr_securesession_feature_t must have been
// previously terminated.
cr_securesession_feature_result_t cr_securesession_feature_free(struct cr_securesession_feature_t *securesession);

/**
 Process the response sent by the server for a requested generated by
 cr_securesession_feature_event_api_t::on_send_to_server.

 @returns A cr_securesession_feature_result_t indicating success or failure.

 @param securesession
 @param buf The server response.
 @param buf_len The length of the server response.
 @param server_error_message_out If the return value is CR_SECURESESSION_FEATURE_RESULT_SERVER_DENY_ERROR, this will contain additional information about
 the server deny. Should be ignored otherwise.
 @param server_ux_hint_out If the return value is CR_SECURESESSION_FEATURE_RESULT_SERVER_DENY_ERROR, this will contain additional information about
 the user experience for the error screen that will be display. Should be ignored otherwise.
 @param localized_title_out If the return value is CR_SECURESESSION_FEATURE_RESULT_SERVER_DENY_ERROR, this will contain the title string to display.
 Should be ignored otherwise.
 @param localized_title_out_len The length of the localized_title_out buffer
 @param localized_description_out If the return value is CR_SECURESESSION_FEATURE_RESULT_SERVER_DENY_ERROR, this will contain the description string to
 display. Should be ignored otherwise.
 @param localized_descriptiong_out_len The length of the localized_description_out buffer
*/
cr_securesession_feature_result_t cr_securesession_feature_process_server_message(struct cr_securesession_feature_t *securesession,
                                                                                  void const *buf,
                                                                                  size_t buf_len,
                                                                                  cr_securesession_feature_server_error_t *server_error_message_out,
                                                                                  cr_securesession_feature_server_ux_hint_t *server_ux_hint_out,
                                                                                  char *localized_title_out,
                                                                                  size_t localized_title_out_len,
                                                                                  char *localized_description_out,
                                                                                  size_t localized_description_out_len);

// Notify LCR that the server request has failed so that it can update its state.
// If LCR is not waiting for a server response, this function does nothing.
cr_securesession_feature_result_t cr_securesession_feature_notify_server_error(struct cr_securesession_feature_t *securesession);

// Begins the process of establishing a securesession if a valid session does not already exist.
// If a session already exists or is in the process of being established, this function does nothing.
cr_securesession_feature_result_t cr_securesession_feature_establish_session(struct cr_securesession_feature_t *securesession);

// Request for pin entry to be bypassed.
//
// When should this function be invoked.
cr_securesession_feature_result_t cr_securesession_feature_pin_bypass(struct cr_securesession_feature_t *securesession);

// This function resets the PIN material that may live inside the cr_securesession_feature_t.
// This function will reset either the "old" ISO format 1 pinblock or the "new" ISO format 4,
// depending on which one of the two is being used.
void cr_securesession_host_pin_reset_dispatch(struct cr_securesession_feature_t *securesession);

// This function encrypts the PIN block and sends it to the reader.
// The suffix _dispatch in the signature indicates that this function will choose to send the pinblock in either
// the "old" ISO format 1 or the "new" ISO format 4, depending on what reader and host agree to use.
cr_securesession_feature_result_t cr_securesession_feature_finalize_and_submit_pinblock_dispatch(struct cr_securesession_feature_t *securesession);

// This function consumes one PIN digit.
// The suffix _dispatch in the signature indicates that this function will choose to use pinblock
// in either the "old" ISO format 1 or the "new" ISO format 4, depending on what reader and host agree to use.
cr_securesession_feature_result_t cr_securesession_host_pin_add_digit_dispatch(struct cr_securesession_feature_t *securesession, uint8_t digit);

// Process a pinblock generated in response to the
// cr_securesession_feature_event_api_t::on_pin_requested callback.
// The pinblock is in ISO format 1, this is to be deprecated.
cr_securesession_feature_result_t cr_securesession_feature_submit_pinv1block(struct cr_securesession_feature_t *securesession,
                                                                           void const *pinblock,
                                                                           size_t pinblock_len);

// Process a pinblock generated in response to the
// cr_securesession_feature_event_api_t::on_pin_requested callback.
// The pinblock is in ISO format 4.
cr_securesession_feature_result_t cr_securesession_feature_submit_pinv4block(struct cr_securesession_feature_t *securesession,
                                                                           void const *pinblock,
                                                                           size_t pinblock_len);

cr_securesession_feature_result_t cr_securesession_feature_submit_pinblock_dispatch(struct cr_securesession_feature_t *securesession,
                                                                           void const *pinblock,
                                                                           size_t len);

// Used to access the underlying securesession host context handle as a public API call.
cr_securesession_feature_result_t cr_securesession_feature_get_context_handle(struct cr_securesession_feature_t *securesession, void **context_handle_out);
