// Copyright (c) 2014 Square, Inc. All rights reserved.

#pragma once

#include <cardreader/cr_payment_defines.h>

#include <cardreader_shared/crs_log.h>
#include <cardreader_shared/crs_codetalker_msgs.h>
#include <cardreader_shared/crs_magswipe_msgs.h>
#include <cardreader_shared/crs_emv_notification.h>
#include <cardreader_shared/crs_payment_defs.h>
#include <cardreader_shared/crs_tmn_msgs.h>

#include <stdbool.h>
#include <stddef.h>
#include <stdint.h>

// ================================================================================================
//
// Overall Usage and Flow
// ======================
//  For functions that return a cr_payment_result_t, it is advised to always ensure that the
//   result is equal to `CR_PAYMENT_RESULT_SUCCESS`.
//
//  Allocation and initialization
//  First step will always be to allocate and initialize:
//   1. Allocate payment object `payment = cr_payment_alloc()`
//   2. Initialize the object `result = cr_payment_init(payment, cardreader, ...)`
//  After this, we must wait for reader ready before any events will arrive.
//  Any number of transactions may be performed before termination and free of the payment object.
//
//  Magswipe Behavior
//  =================
//  Securesession establishment is required for EMV payments, however, magswipe packets may still
//  be processed if the card does not have an ICC. In this case the `on_payment_complete`
//  callback will be called with result `CR_PAYMENT_PAYMENT_RESULT_MAGSWIPE`.
//
//  If a bad swipe is received or if the card swiped has an ICC the `on_card_action_required`
//  will be called with action `CR_PAYMENT_CARD_ACTION_SWIPE_AGAIN` or
//  `CR_PAYMENT_CARD_ACTION_INSERT` respectively.
//
//  A call to `cr_payment_start_payment` is not required for pure magswipe payments. However,
//  such a call would not result in any error. Pure magswipe payments are unique in that they
//  can result in an `on_payment_complete` without a matching `cr_payment_start_payment`.
//
//  One exception, is when `cr_payment_enable_swipe_passthrough` is called. This enables passthrough
//  of all swipes via the `on_swipe_passthrough` callback, irrespective of current payment state and
//  ICC presence.
//
//  E-Money TMN Payment
//  =================
//  Securesession must be established for E-Money TMN payments.
//  `cr_payment_tmn_start_transaction` can be called at any time after initialization.
//
//  General payment flow is as follows:
//   1. `cr_payment_tmn_start_transaction` is called to start a transaction instead of (not in
//     addition to) `cr_payment_start_payment`. For a payment this is called with `transaction_type`
//     of TMN_REQUEST_TRANSACTION, along with `transaction_id`, `brand_id`, and `amount`.
//
//   2. During TMN payments data will be passed between Reader and TMN server using. Reader will call
//     `on_tmn_data` with data to be sent to TMN Connection, and TMN connection data should be sent
//     to reader using `cr_payment_tmn_send_bytes_to_reader`.
//
//   3. TMN transaction completion will be indicated by `on_tmn_transaction_complete` which will be
//     called with an result error code and message.
//
//  EMV Payment
//  ===========
//  Securesession must be established for EMV payments.
//  `cr_payment_start_payment` can be called at any time after initialization.
//  The `on_card_presence_changed` callback is intended to inform when a card is present
//  indicating that the terminal is ready for the payment to start.
//  If payment is ready but card state is unkown the `cr_payment_request_card_presence` may be used.
//
//  General payment flow is as follows:
//   1. `cr_payment_start_payment` is called with amount, account, and time information.
//     This can be prompted by `on_card_presence_changed` or user interaction with register.
//     (See Technical Fallback section for additional behavior)
//
//   2. [Optional] If multiple applications are mutually supported by the terminal and the card, the
//     `on_application_selection_required` callback will be called with the available applications.
//
//     The list must be presented to the user and the subsequent selection must be sent to
//     the reader via `cr_payment_select_application`.
//
//     The `application_definition_filename` is used as the unique identifier when selecting an
//     application. The application label is used for display purposes only.
//
//   3. [Optional] If account type selection is required by the brand, the reader will also send up
//     the list of account types. The `on_account_type_selection_required` callback will be called
//     with the available account types and language preferences.
//
//     Similar to application selection, the list must be presented to the user and the subsequent
//     selection must be sent to the reader via `cr_emv_flow_select_account_type`.
//
//   4. [Optional] For most transactions an online authorization will be required.
//     However, exceptions are offline decline and transaction error (offline approval is not
//     supported at this time). In these cases this step will be skipped.
//
//     For online authorizations the `on_emv_authorization_request` or `on_contactless_emv_authorization_request`
//     (depending on type of payment) callback will be called with data to be sent to the payment server
//     for authorization. The server response must then be sent to the reader via `cr_payment_process_authorization_response`,
//     even in the case where the server indicates a decline.
//
//   5. `on_payment_complete` callback will always be called at the end of a transaction,
//     for both error and success cases.
//
//  Technical Fallback
//  ==================
//  Sometimes a card may be present but the terminal is unable to establish intial communications.
//  We refer to this generally as "card power failure".
//
//  If a card fails to power the `on_card_action_required` callback will be called with action
//  `CR_PAYMENT_CARD_ACTION_INSERT_AGAIN` and the user must re-insert card to continue.
//
//  If three card power failures occur we must fall back to magswipe. In this case, after three
//  failures, the `on_card_action_required` callback will be called with action
//  `CR_PAYMENT_CARD_ACTION_SWIPE_TECHNICAL`. At this point we will revert to the
//  "Magswipe behavior" above with the caveat being the `on_payment_complete` result now equal to
//  `CR_PAYMENT_PAYMENT_RESULT_MAGSWIPE_TECHNICAL_FALLBACK`.
//
//  Terminate and free
//  ==================
//  To deallocate the payment object the proper sequence is:
//   1. Terminate the object `cr_payment_term`.
//   2. Free memory allocated for the payment object `cr_payment_free`.
//  A new payment object must be allocated and initialized for further payment processing.
//
// ================================================================================================

typedef struct cr_payment_t cr_payment_t;

typedef enum
{
    // Call was completed successfully.
    CR_PAYMENT_RESULT_SUCCESS = 0,
    // A given parameter to the function was invalid.
    CR_PAYMENT_RESULT_INVALID_PARAMETER,
    // cr_payment_init must be called before using other functions.
    CR_PAYMENT_RESULT_NOT_INITIALIZED,
    // Returned by cr_payment_init when initialized was already called.
    CR_PAYMENT_RESULT_ALREADY_INITIALIZED,
    // cr_payment_init must be called before cr_payment_free.
    CR_PAYMENT_RESULT_NOT_TERMINATED,
    // Returned by cr_payment_term when terminate was already called.
    CR_PAYMENT_RESULT_ALREADY_TERMINATED,
    // There was a session error.
    CR_PAYMENT_RESULT_SESSION_ERROR,
    // Call was unexpected at this time, a violation of the internal state machine.
    CR_PAYMENT_RESULT_CALL_UNEXPECTED,
    // A fatal, unrecoverable error has occurred, payment should be aborted.
    CR_PAYMENT_RESULT_FATAL,
    // ADF_NAME given to cr_payment_select_application was invalid (not a given choice).
    CR_PAYMENT_RESULT_BAD_ADF_NAME,
    // Invalid notification received from k21
    CR_PAYMENT_RESULT_INVALID_NOTIFICATION,
    // A field was not found where requested or expected. (e.g. Retrieving cardholder name from arqc).
    CR_PAYMENT_RESULT_NOT_FOUND,
    // Selection account type was not valid.
    CR_PAYMENT_RESULT_INVALID_ACCOUNT_TYPE,
} cr_payment_result_t;

enum
{
    CR_EMV_FLOW_LANG_PREF_MAX = 4,
};

enum
{
    CR_PAYMENT_NDEF_MERCHANT_ID_MAX_LENGTH = 16,
    CR_PAYMENT_NDEF_CARD_ID_MAX_LENGTH = 80,
};

// This matches the `crs_emv_l2ctl_app_langpref_t` struct defined in ritual.yaml.
typedef struct cr_payment_language_preference_t {
    uint8_t chars[2];
} cr_payment_language_preference_t;

typedef struct cr_payment_account_type_list_data_t {
    uint8_t account_type_list[6];
} cr_payment_account_type_list_data_t;

typedef struct cr_payment_account_type_enum_list_data_t {
    cr_payment_account_type_t account_type_list[6];
} cr_payment_account_type_enum_list_data_t;

typedef struct cr_payment_merchant_loyalty_id_t {
    uint8_t id[32];
} cr_payment_merchant_loyalty_id_t;

typedef struct cr_payment_merchant_loyalty_id_list_t {
    cr_payment_merchant_loyalty_id_t ids[3];
    uint8_t count;
} cr_payment_merchant_loyalty_id_list_t;

typedef enum {
    CR_PAYMENT_LOYALTY_RESULT_SUCCESS,
    CR_PAYMENT_LOYALTY_RESULT_VAS_DATA_NOT_FOUND,
    CR_PAYMENT_LOYALTY_RESULT_CANCELED,
    CR_PAYMENT_LOYALTY_RESULT_TERMINATED,
    CR_PAYMENT_LOYALTY_RESULT_SKIPPED,
    CR_PAYMENT_LOYALTY_RESULT_URL_PUSH_FAILED
} cr_payment_loyalty_result_t;

typedef enum {
    CR_PAYMENT_VAS_PROTOCOL_URL,
    CR_PAYMENT_VAS_PROTOCOL_FULL,
    CR_PAYMENT_VAS_PROTOCOL_NONE
} cr_payment_vas_protocol_t;

typedef struct cr_payment_ndef_merchant_id_t {
    uint8_t id[CR_PAYMENT_NDEF_MERCHANT_ID_MAX_LENGTH];
} cr_payment_ndef_merchant_id_t;

typedef struct cr_payment_ndef_card_id_t {
    uint8_t id[CR_PAYMENT_NDEF_CARD_ID_MAX_LENGTH];
} cr_payment_ndef_card_id_t;

// Callback for when the state of the card detect switch on the reader has been requested or
// state has changed due to user interaction (user inserted or removed card).
typedef void (*cr_payment_card_presence_changed_t)(void *context,
                                                   cr_payment_t *payment,
                                                   cr_payment_card_presence_t last_card_presence,
                                                   cr_payment_card_presence_t card_presence,
                                                   bool will_continue_payment);

// Callback for when specific user interactions are required.
// `action_requested` is the action desired of the user
// `std_msg` is information that shall be displayed to the user.
// For example:
//  CR_PAYMENT_CARD_ACTION_INSERT -- A card needs to be inserted into the reader. Happens when
//   either an ICC enabled card is swiped or a start_payment is called when no card is present.
//
//  CR_PAYMENT_CARD_ACTION_INSERT_AGAIN -- A card error has been detected. Card needs to be removed
//   then reinserted.
//
//  CR_PAYMENT_CARD_ACTION_SWIPE -- The card does not have an ICC or the ICC cannot be powered
//  on. Card needs to be swiped.
//
//  CR_PAYMENT_CARD_ACTION_SWIPE_AGAIN --  The card swipe failed. The card needs to be reswiped.
typedef void (*cr_payment_card_action_required_t)(void *context,
                                                  cr_payment_t *payment,
                                                  cr_payment_card_action_t action_requested,
                                                  cr_payment_std_msg_t std_msg);

// Callback to notify that user must select an application from the list provided.
//  (Note that application selection is different from account selection which happens before
//  the start of the payment)
//
// This is required when the terminal cannot automatically determine which application to use.
// This occurs when there is more then 1 mutually supported application or when the single
// application requires explicit selection.
//
// `apps` is an array of `cr_payment_application_t` values with a length of `apps_len`.
typedef void (*cr_payment_application_selection_required_t)(void *context,
                                                            cr_payment_t *payment,
                                                            cr_payment_application_t const *apps,
                                                            size_t apps_len);

// Callback to notify that the user must select an account type from the list provided.
// (Note that account type selection is different from application selection. And note that
// there is a concept of an account selection at the start of the payment, which was
// inherited from R6 -- it might have be implemented for certification purpose. In R12, this
// start payment account selection is defaulted to 00. The second concept of account type
// selection from the card which is only used in R12.)
//
// This is required for certain brands, such as Interac.
//
// `account_types` is an array of `cr_payment_account_type_t` values with a length of `account_types_len`.
// `language_prefs` is an array of `cr_payment_language_preference_t` values. Each language
// is represented by a two-byte code. The card will always return 4 2-byte language codes.
// If a specific language isn't supported, then the value will be 0.
//
// Note that the language preference from the card is also sent up with this callback, but isn't
// needed to make an account type selection. No information about the selected language needs to be
// returned to the reader.
typedef void (*cr_payment_account_type_selection_required_t)(void *context,
                                                             cr_payment_t *payment,
                                                             cr_payment_account_type_t const *account_types,
                                                             size_t account_types_len,
                                                             cr_payment_language_preference_t const *language_prefs,
                                                             uint8_t *aid);

// Callback for when the payment has completed. This does not necessarily indicate successfully
// completed of a transaction.
//
// `data` is either an M1 packet or EMV clearing/reversal message or NULL. If not NULL, data
//   shall be sent to the server on the appropriate endpoint.
// `result` shows if the payment was successful, or how it failed.
// `card_info` contains information that shall be displayed to the user.
// `std_msg` is information that shall be displayed to the user.
//
// In the case of a successful payments (result is CR_PAYMENT_PAYMENT_RESULT_SUCCESS_*) and all emv
// payments (result is CR_PAYMENT_PAYMENT_RESULT_*_ICC_*) `data` will be non-NULL and is intended
// for the payment server. In all other cases, `data` should be NULL.
typedef void (*cr_payment_payment_complete_t)(void *context,
                                              cr_payment_t *payment,
                                              void const *data,
                                              size_t data_len,
                                              cr_payment_payment_result_t result,
                                              bool approved_offline,
                                              cr_card_info_t const *card_info,
                                              cr_payment_std_msg_t std_msg,
                                              cr_payment_timing_t const *payment_timings,
                                              size_t payment_timings_count,
                                              cr_payment_card_action_t card_action);

// Callback containing the information required to be sent to the server.
typedef void (*cr_payment_emv_authorization_request_t)(void *context,
                                                       cr_payment_t *payment,
                                                       void const *buf,
                                                       size_t buf_len,
                                                       bool is_card_presence_required,
                                                       cr_card_info_t const *card_info);

// Callback containing the information required to be sent to the server.
typedef void (*cr_payment_tmn_authorization_request_t)(void *context,
                                                       cr_payment_t *payment,
                                                       void const *buf,
                                                       size_t buf_len);

// Callback with card information from a passthrough magswipe. A passthrough swipe must be enabled
// with cr_payment_enable_swipe_passthrough. This enables the merchant to take payments in off-line
// mode, and perform certain other non-payment operations, such as use a swipe to search for
// customer data in a back-of-house flow.
//
// `data` is an M1 packet or NULL. If not NULL, data shall be sent to the server on the
//    appropriate endpoint.
// `card_info` contains information that shall be displayed to the user.
typedef void (*cr_payment_swipe_passthrough_t)(void *context,
                                               cr_payment_t *payment,
                                               void const *data,
                                               size_t data_len,
                                               cr_card_info_t *card_info,
                                               cr_payment_source_t payment_src);

// Callback with card information containing at the very least the cardholder's name.
// If the transaction was contactless, the name might be intentionally obfuscated and appear
// something like "\." or "Valued Customer".
typedef void (*cr_payment_cardholder_name_received_t)(void *context,
                                                      cr_payment_t *payment,
                                                      cr_card_info_t const *card_info);

// Callback for when an acknowledgment is received from an M1 configure or clear_configuration command.
// NOTE: For factory use only.
typedef void (*cr_payment_magswipe_flow_configuration_callback_t)(void *context,
                                                                  cr_payment_t *payment);

// Callback for when M1 health data is received from the reader.
// NOTE: For factory use only.
typedef void (*cr_payment_magswipe_flow_health_callback_t)(void *context,
                                                           cr_payment_t *payment,
                                                           uint32_t status);

// Callback for when an error message is received from an M1 configure or clear_configuration command.
// NOTE: For factory use only.
typedef void (*cr_payment_magswipe_flow_error_callback_t)(void *context,
                                                          cr_payment_t *payment);

// Callback for when M1 dump data is received from the reader.
// NOTE: For factory use only.
typedef void (*cr_payment_magswipe_flow_dump_callback_t)(void *context,
                                                         cr_payment_t *payment,
                                                         const crs_magswipe_dump_msg_t *dump_data);

// Callback for when a TMN transaction has completed.
//
// `result` - transaction result status  (tmn_transaction_result_t from crs_tmn_msgs.h)
typedef void (*cr_payment_tmn_transaction_complete_t)(void *context,
                                                      cr_payment_t *payment,
                                                      tmn_transaction_result_t result,
                                                      cr_payment_timing_t const *payment_timings,
                                                      size_t payment_timings_count);

// Callback for when a TMN transaction needs to request a UI message to be displayed.
//
// `msg_id` - msg ID for the display request
// `amount_string` - null terminated amount string (empty if none, max len 32)
// `balance_string` - null terminated balance string (empty if none, max len 32)
typedef void (*cr_payment_tmn_ui_request_t)(void *context,
                                            cr_payment_t *payment,
                                            crs_tmn_message_t msg_id,
                                            const char *amount_string,
                                            const char *balance_string);

// Callback for when a TMN transaction needs to request a audio request.
//
// `msg_id` - msg ID for the audio request
typedef void (*cr_payment_tmn_audio_request_t)(void *context,
                                            cr_payment_t *payment,
                                            crs_tmn_audio_t audio_id);

// Callback for TMN data to be sent to TMN Connection.
//
// `transaction_id` - the transaction_id to use for this TMN message
// `data` - payment result data intended for payment server (via TMN Proxy)
typedef void (*cr_payment_tmn_data_packet_callback_t)(void *context,
                                                      cr_payment_t *payment,
                                                      const char *transaction_id,
                                                      void const *data,
                                                      size_t data_len);

// Callback for when a TMN transaction is entering the final stage. After this
// event the transaction cannot be canceled and miryou flow will be needed if
// a transaction result is not received.
// `balance_before` - Balance on the card before the transaction
// `amount` - Transaction amount
// `miryo_data` - information needed for Miryo Auth in the event that Miryo is required
typedef void (*cr_payment_tmn_write_notify_t)(void *context,
                                              cr_payment_t *payment,
                                              uint32_t balance_before,
                                              uint32_t amount,
                                              void const *miryo_data,
                                              size_t miryo_data_len);

//Callback for audio visual request
//
//audio_visual_id audio to be played/ visual image t be displayed.
typedef void (*cr_payment_audio_visual_request_t)(void *context,
                                                   cr_payment_t *payment,
                                                   cr_audio_visual_id_t audio_visual_id);

//Callback for VAS response
//
// `protocol` - VAS protocol used
// `result` - Result code for VAS transaction
// `finished` - This can be the final response or followed by auth
// `merchant_loyalty_id` - merchant loyalty id that the data is associated with
// `data` - encrypted buyer loyalty id
// `data_len` - encrypted buyer loyalty id length
typedef void (*cr_payment_vas_response_t)(void *context,
                                          cr_payment_t *payment,
                                          cr_payment_vas_protocol_t protocol,
                                          cr_payment_loyalty_result_t result,
                                          bool finished,
                                          cr_payment_merchant_loyalty_id_t const *merchant_loyalty_id,
                                          void const *data,
                                          size_t data_len);

//Callback for NDEF Read complete
//'application_type' - Team management, Loyalty or Gift card
//'merchant id' - The merchant id on the card
//'card_id' - card unique id for the application, similar to PAN
//'card_id_length' - actual length of card id
//'card_type' - sub card type
//'result' - result of the read ndef command
typedef void (*cr_payment_read_ndef_complete_t)(void *context,
                                                cr_payment_t *payment,
                                                cr_payment_ndef_application_type_t application_type,
                                                cr_payment_ndef_merchant_id_t const *merchant_id,                                         
                                                cr_payment_ndef_card_id_t const *card_id,
                                                uint8_t card_id_length,
                                                uint8_t card_type, 
                                                cr_payment_ndef_result_t result);


//Callback for NDEF Write complete
//'result' - result of the write ndef command
typedef void (*cr_payment_write_ndef_complete_t)(void *context,
                                                 cr_payment_t *payment,                                                
                                                 cr_payment_ndef_result_t result);                                                
typedef struct cr_payment_event_api_t
{
    cr_payment_card_presence_changed_t on_card_presence_changed;
    cr_payment_card_action_required_t on_card_action_required;
    cr_payment_application_selection_required_t on_application_selection_required;
    cr_payment_account_type_selection_required_t on_account_type_selection_required;
    cr_payment_emv_authorization_request_t on_emv_authorization_request;
    cr_payment_emv_authorization_request_t on_contactless_emv_authorization_request;
    cr_payment_payment_complete_t on_payment_complete;
    cr_payment_swipe_passthrough_t on_swipe_passthrough;
    cr_payment_cardholder_name_received_t on_cardholder_name_received;


    // Optional callbacks for MSR factory tests
    cr_payment_magswipe_flow_configuration_callback_t on_msr_configure;
    cr_payment_magswipe_flow_health_callback_t on_msr_health;
    cr_payment_magswipe_flow_error_callback_t on_msr_error;
    cr_payment_magswipe_flow_dump_callback_t on_msr_dump;

    // Callbacks for TMN payment flow
    cr_payment_tmn_data_packet_callback_t on_tmn_data;
    cr_payment_tmn_transaction_complete_t on_tmn_transaction_complete;
    cr_payment_tmn_ui_request_t on_display_request;
    cr_payment_tmn_audio_request_t on_audio_request;
    cr_payment_tmn_authorization_request_t on_tmn_authorization_request;
    cr_payment_tmn_write_notify_t on_tmn_write_notify;

    //Callback for audio request from payment stack
    cr_payment_audio_visual_request_t on_audio_visual_request;

    //Callback for VAS response
    cr_payment_vas_response_t on_vas_response;
    //Callback for Read/Write ndef completion
    cr_payment_read_ndef_complete_t on_read_ndef_complete;
    cr_payment_write_ndef_complete_t on_write_ndef_complete;

    void *context;
} cr_payment_event_api_t;

typedef struct cr_payment_cfg_t
{
    uint16_t mcc; // merchant category code
    uint16_t transaction_currency_code; // ISO 4217
} cr_payment_cfg_t;

struct cr_cardreader_t;

// Feature bring up and tear down.
cr_payment_t *cr_payment_alloc(void);
cr_payment_result_t cr_payment_init(cr_payment_t *payment,
                                    struct cr_cardreader_t *cardreader,
                                    cr_payment_event_api_t const *api,
                                    cr_payment_cfg_t const *cfg);
cr_payment_result_t cr_payment_term(cr_payment_t *payment);
cr_payment_result_t cr_payment_free(cr_payment_t *payment);

crs_log_subsystem_t cr_payment_get_log_subsystem(void);

// Entry point for beginning a payment.
// `auth_amount` is in cents.
// `year` is in years since 2000
// `month` is month (1-12)
// `day` is the day of the month (1-31)
// `hour` is the hours since midnight (0-23)
// `minute` is minutes after the hour (0-59)
// `second` is seconds after the minute (0-59)
//
//  Note: A call to `cr_payment_start_payment` is not required for pure magswipe payments. However,
//  such a call would not result in any error. Pure magswipe payments are unique in that they
//  can result in an `on_payment_complete` without a matching `cr_payment_start_payment`.
cr_payment_result_t cr_payment_start_payment(cr_payment_t *payment,
                                             uint32_t auth_amount,
                                             cr_payment_account_type_t account_type,
                                             cr_payment_transaction_type_t transaction_type,
                                             uint8_t year,
                                             uint8_t month,
                                             uint8_t day,
                                             uint8_t hour,
                                             uint8_t minute,
                                             uint8_t second);

// This function generates a StartPaymentRequest and sends it via proto ritual.
// It supports both payment and VAS transactions as well as one-tap (VAS + payment)
// If cr_payment_set_loyalty_url_info was called beforehand, the reader will push the URL in ApplePay transactions.
// If cr_payment_set_loyalty_vas_info was called beforehand, the reader will first start a VAS transaction and then
// a payment transaction. If not ApplePay, the reader will convert VAS transaction into payment transaction
// to avoid the overhead of two transactions.
cr_payment_result_t cr_payment_start_payment_v2(cr_payment_t *payment,
                                                uint32_t auth_amount,
                                                uint16_t transaction_currency_code,
                                                cr_payment_transaction_type_t transaction_type,
                                                uint8_t year,
                                                uint8_t month,
                                                uint8_t day,
                                                uint8_t hour,
                                                uint8_t minute,
                                                uint8_t second);

// Get card information only.
cr_payment_result_t cr_payment_get_card_info(cr_payment_t *payment,
                                             uint8_t year,
                                             uint8_t month,
                                             uint8_t day,
                                             uint8_t hour,
                                             uint8_t minute,
                                             uint8_t second);

// Set parameters for URL pushing in ApplePay transactions.
cr_payment_result_t cr_payment_set_loyalty_url_info(cr_payment_t *payment,
                                                    cr_payment_merchant_loyalty_id_t const *merchant_loyalty_id, // for URL
                                                    char const *merchant_loyalty_url); // maximum 64 characters

// Set merchant loyalty ids for VAS transactions.
cr_payment_result_t cr_payment_set_loyalty_vas_info(cr_payment_t *payment,
                                                    cr_payment_merchant_loyalty_id_list_t const *merchant_loyalty_ids); // for Full VAS

// Start a VAS transaction.
cr_payment_result_t cr_payment_get_vas_data(cr_payment_t *payment);

// Cancel a payment already in progress (before payment_complete).
cr_payment_result_t cr_payment_cancel_payment(cr_payment_t *payment);

// Select the application on the card. Should be called from `on_application_selection_required`
// `adf_name` and `adf_name_len` is selected from the cr_payment_application_t list passed into the callback.
cr_payment_result_t cr_payment_select_application(cr_payment_t *payment, uint8_t const *adf_name, size_t adf_name_len);

// Select the account type to use on the card. Should be called from `on_account_type_selection_required`.
// The account_type passed to this call should come from the list of cr_payment_account_type_t passed
// to the `on_account_type_selection_required` callback.
cr_payment_result_t cr_payment_select_account_type(cr_payment_t *payment, cr_payment_account_type_t account_type);

// Tell the reader to process the server response for the authorization request from `on_emv_authorization_request`
// `arpc` is the data sent from the server.
cr_payment_result_t cr_payment_process_authorization_response(cr_payment_t *payment, void const *arpc, size_t arpc_len);

// Request the card presence to be reported. May be called when reader is plugged in (after
// reader_ready). Useful for when a card is already dipped prior to plugging into the device.
cr_payment_result_t cr_payment_request_card_presence(cr_payment_t *payment);

// Enable or disable magswipe passthrough. When enabled all swipes (whether part of a payment or not) will result in
// a `on_swipe_passthrough` callback. If enabled, swipes will not trigger a `on_payment_complete`.
cr_payment_result_t cr_payment_enable_swipe_passthrough(cr_payment_t *payment, bool enabled);

// Get last known card presence status lcr has w/o querying the reader
cr_payment_result_t cr_payment_get_last_known_card_presence(cr_payment_t *payment, cr_payment_card_presence_t *last_known_card_presence_out);

// Tell the reader that a payment is likely to happen soon and to powerup k400 in preperation
cr_payment_result_t cr_payment_send_powerup_hint(cr_payment_t *payment, uint32_t timeout_seconds);

// MSR factory tests for LCRPy
cr_payment_result_t cr_payment_msr_get_status(cr_payment_t *payment);
cr_payment_result_t cr_payment_msr_get_status_v2(cr_payment_t *payment, cr_payment_source_t payment_src);

cr_payment_result_t cr_payment_msr_configure(cr_payment_t *payment);
cr_payment_result_t cr_payment_msr_configure_v2(cr_payment_t *payment, cr_payment_source_t payment_src);

cr_payment_result_t cr_payment_msr_clear_configuration(cr_payment_t *payment);
cr_payment_result_t cr_payment_msr_clear_configuration_v2(cr_payment_t *payment, cr_payment_source_t payment_src);

cr_payment_result_t cr_payment_msr_dump(cr_payment_t *payment, cr_payment_source_t payment_src);

// Entry point for starting a TMN transaction.
// `transaction_type` - type of transaction (TMN_REQUEST_TRANSACTION for payments)
// `transaction_id` - 32 character transaction id (generated by App)
// `brand_id` - E-Money brand id
// `amount` - transaction amount
cr_payment_result_t cr_payment_tmn_start_transaction(cr_payment_t *payment,
                                                     crs_tmn_request_type_t transaction_type,
                                                     char const *transaction_id,
                                                     crs_tmn_brand_id_t brand_id,
                                                     uint32_t amount);

// Check the result of a previous transaction.
// `transaction_id` - 32 character transaction id (generated by App) for this new request
// `prev_transaction_id` - Transaction ID for the transaction we would like the result of
cr_payment_result_t cr_payment_tmn_check_result(cr_payment_t *payment,
                                                char const *transaction_id,
                                                crs_tmn_brand_id_t brand_id,
                                                char const *prev_transaction_id);

// Start Miryo recovery for a previous transaction. This will initiate a "check result"
// transaction with TMN, and in some cases may also lead to a "check balance" transaction.
// This is expected to eventually lead to a UI message (TMN_MSG_MIRYO_RESULT_SUCCESS,
// TMN_MSG_MIRYO_RESULT_FAILURE, or TMN_MSG_MIRYO_RESULT_UNKNOWN) and a matching result
// code (TMN_RESULT_SUCCESS, <error reason>, or TMN_RESULT_MIRYO_RESOLUTION_FAILURE).
// `miryo_data` - Miryo data from the 'write_notify' of the original payment
// `miryo_transaction_id` - 32 character transaction id (generated by App) for this new request.
//                           miryo_transaction_id should begin with the characters 'miryoCR'
cr_payment_result_t cr_payment_tmn_start_miryo(cr_payment_t *payment,
                                               uint8_t const *miryo_data,
                                               size_t miryo_data_len,
                                                char const *miryo_transaction_id);

// Void a transaction reported as 'unknown' result.
// `transaction_id` - 32 character transaction id (generated by App) for this new request
// `prev_transaction_id` - Transaction ID for the transaction we would like the result of
cr_payment_result_t cr_payment_tmn_void_unknown(cr_payment_t *payment,
                                                char const *transaction_id,
                                                crs_tmn_brand_id_t brand_id,
                                                char const *prev_transaction_id);

// Send bytes to reader (from TMN)
cr_payment_result_t cr_payment_tmn_send_bytes_to_reader(cr_payment_t *payment, uint8_t const *data, size_t data_len);

// Acknowledge Write notification
cr_payment_result_t cr_payment_tmn_write_notify_ack(cr_payment_t *payment);

// Cancel an active TMN transaction. If the transaction is waiting for polling it will be
// canceled using a TMN cancel request. If the card has been detected but the reader has not
// received a response to `write_notify` then the payment will be forced to terminate.
// Cancel after polling or during `write_notify` should only be used if we cannot Auth. If
// `write_notify_ack` was sent the cancel will be ignored and the payment will continue.
cr_payment_result_t cr_payment_tmn_cancel_request(cr_payment_t *payment);

// Start a Read NDEF Data Request.
cr_payment_result_t cr_payment_read_ndef(cr_payment_t *payment,
                                         cr_payment_ndef_application_type_t application_type,
                                         cr_payment_ndef_merchant_id_t const *merchant_id);

// Start a Write NDEF Data Request.
cr_payment_result_t cr_payment_write_ndef(cr_payment_t *payment,
                                          cr_payment_ndef_application_type_t application_type,
                                          cr_payment_ndef_merchant_id_t const *merchant_id,
                                          cr_payment_ndef_card_id_t const *card_id,
                                          uint8_t card_id_length,
                                          uint8_t card_type,
                                          bool override);