// Copyright (c) 2014 Square, Inc. All rights reserved.

#pragma once

#include <cardreader_shared/crs_payment.h>

#define CR_PAYMENT_DEFAULT_CURRENCY_CODE (840)
#define CR_CARDHOLDER_VERIFICATION_PERFORMED_MASK (0x3F)

// EMV Technical Fallback constants.

enum {
    CR_PAYMENT_MAX_ICC_FAILURES = 3,
    CR_PAYMENT_MAGSWIPE_DUPLICATE_TIMEOUT_MS = 4*1000,
    CR_PAYMENT_MAGSWIPE_MAX_TIME_BETWEEN_M1_MESSAGES_MS = 150,
    CR_PAYMENT_PIN_ENTRY_TIMEOUT_MS = 60*1000,
    CR_PAYMENT_TIMING_LABEL_SIZE = 16,
    CR_PAYMENT_MAX_TIMINGS = 16,
};

enum {
    /// Application definition filename max.
    CR_PAYMENT_APP_ADF_NAME_MAX = 16,
    /// Application label name max.
    CR_PAYMENT_APP_LABEL_MAX = 16,
    /// Application preferred name max.
    CR_PAYMENT_APP_PREFNAME_MAX = 16,
    /// Number of digits for the last four of a card's PAN.
    CR_PAYMENT_LAST4_LENGTH = 4,
    /// Maximum length for a cardholder's name taken from the Track 1 data.
    CR_PAYMENT_NAME_MAX_LENGTH = 26,
    /// Specifies the maximum prefix length of an issuer identification number in a card PAN.
    CR_PAYMENT_PAN_IIN_PREFIX_LENGTH = 6,
    /// Maximum length for the account type, it is list of 1 byte account types.
    CR_PAYMENT_ACCOUNT_TYPE_MAX = 6,
};

/// Standard CVM Results.
/// This is encoded according to byte 1 of EMVCo Book 4, Annex A4. See also Book 3 Annex C3 Table 39.
typedef enum
{
    /// The CVM failed.
    CR_CARDHOLDER_VERIFICATION_PERFORMED_FAILED = 0x00,
    /// The ICC performed a plaintext PIN verification offline.
    CR_CARDHOLDER_VERIFICATION_PERFORMED_OFFLINE_PLAINTEXT_PIN = 0x01,
    /// An enciphered PIN was verified online.
    CR_CARDHOLDER_VERIFICATION_PERFORMED_ONLINE_ENCIPHERED_PIN = 0x02,
    /// The ICC performed a plaintext PIN verification offline and is requesting signature.
    CR_CARDHOLDER_VERIFICATION_PERFORMED_OFFLINE_PLAINTEXT_PIN_AND_SIGNATURE = 0x03,
    /// The ICC performed an enciphered PIN verification offline.
    CR_CARDHOLDER_VERIFICATION_PERFORMED_OFFLINE_ENCIPHERED_PIN = 0x04,
    /// The ICC performed an enciphered PIN verification offline and is requesting signature.
    CR_CARDHOLDER_VERIFICATION_PERFORMED_OFFLINE_ENCIPHERED_PIN_AND_SIGNATURE = 0x05,
    /// The CVM was performed on the contactless device. (e.g. ApplePay thumbprint or AndroidPay passcode.)
    /// This value is arbitrarily chosen in the range of CVM result codes allocated for application use.
    CR_CARDHOLDER_VERIFICATION_PERFORMED_ON_DEVICE = 0x2A,
    /// The card is requesting a signature.
    CR_CARDHOLDER_VERIFICATION_PERFORMED_SIGNATURE = 0x1E,
    /// No CVM necessary.
    CR_CARDHOLDER_VERIFICATION_PERFORMED_NONE = 0x1F,
    /// not known
    CR_CARDHOLDER_VERIFICATION_PERFORMED_UNKNOWN = 0x3F,
} cr_cardholder_verification_performed_t;

enum
{
    /// This bit is set on cvm results tag 9F34 if the terminal should apply succeeding CV Rule if this CVM is unsuccessful.
    /// This bit should be stripped when parsing 9F34 results to populate CVM using cr_cardholder_verification_performed_t.
    CR_CARDHOLDER_VERIFICATION_PERFORMED_FLAG_CVM_FALLTHROUGH = 1 << 6,
    /// This bit is reserved for use, but unspecified. As such it should be stripped out of the CVM results for population of CVM using cr_cardholder_verification_performed_t.
    CR_CARDHOLDER_VERIFICATION_PERFORMED_FLAG_RFU_BIT8 = 1 << 7,
};

typedef enum
{
    CR_MAGSWIPE_TRACK_TYPE_BITMASK_NONE = 0,
    CR_MAGSWIPE_TRACK_TYPE_BITMASK_ONE = 1 << 0,
    CR_MAGSWIPE_TRACK_TYPE_BITMASK_TWO = 1 << 1,
    CR_MAGSWIPE_TRACK_TYPE_BITMASK_THREE = 1 << 2,
} cr_magswipe_track_type_bitmask_t;

typedef struct cr_payment_application_t {
    /// Bytes should be displayed on receipt.
    uint8_t application_definition_filename[CR_PAYMENT_APP_ADF_NAME_MAX];
    /// ADF Name is not NULL terminated, this indicates how many bytes it is.
    size_t application_definition_filename_length;
    /// Used for receipts and displaying to user when selection is required.
    char application_label[CR_PAYMENT_APP_LABEL_MAX + 1];
    // The preferred name of the application.
    char application_prefname[CR_PAYMENT_APP_PREFNAME_MAX + 1];
    uint32_t icodetableidx;
} cr_payment_application_t;

typedef struct {
    char label[CR_PAYMENT_TIMING_LABEL_SIZE];
    uint32_t delta_ms;
} cr_payment_timing_t;

typedef struct cr_card_info_t {
    /// The issuing brand of the card.
    crs_payment_issuer_id_t issuer_id;
    /// Last 4 digits of the PAN. NULL terminated string.
    char last4[CR_PAYMENT_LAST4_LENGTH + 1];
    /// Cardholder name. NULL Terminated string.
    char name[CR_PAYMENT_NAME_MAX_LENGTH + 1];
    /// The EMV card's chosen application. To be ignored in the case of magswipe.
    cr_payment_application_t application;
    /// Bitmask that specifies what tracks were read successfully.
    cr_magswipe_track_type_bitmask_t magswipe_track_type;
    /// CVM code for the CVM performed and/or negotiated.
    cr_cardholder_verification_performed_t cvm_performed;
} cr_card_info_t;

typedef enum
{
    CR_PAYMENT_CARD_PRESENCE_UNKNOWN = 0,
    CR_PAYMENT_CARD_PRESENCE_NOT_PRESENT,
    CR_PAYMENT_CARD_PRESENCE_PRESENT,
} cr_payment_card_presence_t;

typedef enum {
    CR_CARDREADER_READER_TYPE_UNKNOWN,
    CR_CARDREADER_READER_TYPE_GEN2,
    CR_CARDREADER_READER_TYPE_O1,
    CR_CARDREADER_READER_TYPE_R4,
    CR_CARDREADER_READER_TYPE_R6,
    CR_CARDREADER_READER_TYPE_R12,
    CR_CARDREADER_READER_TYPE_A10,
    CR_CARDREADER_READER_TYPE_X2,
    CR_CARDREADER_READER_TYPE_R12C,
    CR_CARDREADER_READER_TYPE_T2,
    CR_CARDREADER_READER_TYPE_X2B,
    CR_CARDREADER_READER_TYPE_T2B,
    CR_CARDREADER_READER_TYPE_S3
} cr_cardreader_reader_type_t;

typedef enum {
    /// Used to indicate no card action
    CR_PAYMENT_CARD_ACTION_NONE = 0,

    /// A card needs to be inserted into the reader. Happens when an ICC enabled
    /// card is swiped or a start_payment is called when no card is present.
    CR_PAYMENT_CARD_ACTION_INSERT,

    /// A card error has been detected. Card needs to be removed then
    /// reinserted.
    CR_PAYMENT_CARD_ACTION_INSERT_AGAIN,

    /// The card does not have an ICC or the ICC cannot be powered on. Card
    /// needs to be swiped.
    CR_PAYMENT_CARD_ACTION_SWIPE_TECHNICAL,

    /// The card has an ICC which isn't currently supported, but magswipe is
    /// allowed. Card needs to be swiped.
    CR_PAYMENT_CARD_ACTION_SWIPE_SCHEME,

    /// The card swipe failed. The card needs to be reswiped.
    CR_PAYMENT_CARD_ACTION_SWIPE_AGAIN,

    /// A contactless card needs to be inserted into the reader. Happens when
    /// a contactless card with chip requests that the chip be used.
    CR_PAYMENT_CARD_ACTION_INSERT_FROM_CONTACTLESS,

    /// The contactless portion of the presented card cannot be used. Swipe,
    /// insert or try another card contactlessly.
    CR_PAYMENT_CARD_ACTION_CONTACTLESS_CARD_ERROR_TRY_ANOTHER_CARD,

    /// A transient error was experienced with the presented contactless card,
    /// such as removing it too quickly from the field. Try presenting it again.
    CR_PAYMENT_CARD_ACTION_CONTACTLESS_CARD_ERROR_TRY_AGAIN,

    /// A phone was presented as a contactless payment instrument. The buyer's
    /// attention should be directed towards their phone which will provide them
    /// with further instructions.
    CR_PAYMENT_CARD_ACTION_CONTACTLESS_SEE_PHONE_FOR_INSTRUCTION,

    /// Multiple contactless cards were presented. Only one of those cards
    /// should be presented.
    CR_PAYMENT_CARD_ACTION_CONTACTLESS_PRESENT_ONLY_ONE,

    /// A locked Android Pay phone was presented as a contactless payment
    /// instrument. The buyer's attention should be directed towards
    /// their phone to unlock it so the payment can happen.
    CR_PAYMENT_CARD_ACTION_CONTACTLESS_UNLOCK_PHONE_TO_PAY,

    /// The contactless portion of the presented card cannot be used because the
    /// transaction or cumulative limit was exceeded. Try another card.
    CR_PAYMENT_CARD_ACTION_CONTACTLESS_CARD_LIMIT_EXCEEDED_ERROR_TRY_ANOTHER_CARD,

    /// The contactless portion of the presented card cannot be used because the
    /// transaction or cumulative limit was exceeded. Swipe or insert card.
    CR_PAYMENT_CARD_ACTION_CONTACTLESS_CARD_LIMIT_EXCEEDED_INSERT_CARD,

    /// If an Interac card is dipped and the transaction is under $100, then
    /// prompt the buyer to tap card instead since we do not support Interac dip
    /// or swipe.
    CR_PAYMENT_CARD_ACTION_REQUEST_TAP,

    /// A contactless card is requested to be presented again in response to an
    /// online issuer auth response (ex. issuer scripts, issuer-initiated restart),
    CR_PAYMENT_CARD_ACTION_ISSUER_REQUESTED_PRESENT_CARD_AGAIN,
} cr_payment_card_action_t;

/// Possible types of card entry methods for which a reader can initiate a
/// new transaction.
typedef enum {
    CR_PAYMENT_CARD_ENTRY_TYPE_CONTACT = 0,
    CR_PAYMENT_CARD_ENTRY_TYPE_CONTACTLESS = 1,
    CR_PAYMENT_CARD_ENTRY_TYPE_SWIPE = 2,
} cr_payment_card_entry_type_t;

/// Specify the payment source type
typedef enum {
    CR_PAYMENT_SRC_DEFAULT = -1,
    CR_PAYMENT_SRC_MSR_0 = 0,
    CR_PAYMENT_SRC_MSR_1 = 1,
    CR_PAYMENT_SRC_COUNT = 2,
} cr_payment_source_t;
