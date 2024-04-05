// Copyright 2017 Square, Inc.

#pragma once

#ifndef SHORT2BYTEARRAY
    #define SHORT2BYTEARRAY(v, ba)                  {ba[0] = (v >> 8); ba[1] = (uint8_t)v;}
#endif

#ifndef LONG2BYTEARRAY
    #define LONG2BYTEARRAY(v, ba)                  {ba[0] = (v >> 24); ba[1] = (uint8_t)(v >> 16);ba[2] = (uint8_t)(v >> 8); ba[3] = (uint8_t)v;}
#endif

#ifndef BYTE2SHORT
    #define BYTE2SHORT(x) ((((const uint8_t*)(x))[0]) | (((const uint8_t*)(x))[1] << 8))
#endif

#ifndef BYTE2LONG
    #define BYTE2LONG(x) ((((const uint8_t*)(x))[0]) | (((const uint8_t*)(x))[1] << 8) | (((const uint8_t*)(x))[2] << 16) | (((const uint8_t*)(x))[3] << 24))
#endif

#ifndef BYTE2SHORTLE
    #define BYTE2SHORTLE(x) ((((const uint8_t*)(x))[1]) | (((const uint8_t*)(x))[0] << 8))
#endif

#ifndef BYTE3LONGLE
    #define BYTE3LONGLE(x) ((((const uint8_t*)(x))[2]) |  (((const uint8_t*)(x))[1] << 8)|(((const uint8_t*)(x))[0] << 16))
#endif

#ifndef BYTE4LONGLE
    #define BYTE4LONGLE(x) ((((const uint8_t*)(x))[3]) | (((const uint8_t*)(x))[2] << 8) | (((const uint8_t*)(x))[1] << 16) | (((const uint8_t*)(x))[0] << 24))
#endif

#define  LEN_DATE                  3
#define  LEN_TRACK2_DATE           2
#define  LEN_FULL_DATE             4
#ifndef LEN_TIME
    #define  LEN_TIME              3
#endif
#ifndef LEN_TRANSACTION_TYPE
    #define  LEN_TRANSACTION_TYPE  1
#endif
#ifndef  LEN_AMOUNT
    #define  LEN_AMOUNT            6
#endif
#define  LEN_ACCOUNT_TYPE          1
#define  MAX_LEN_ACCOUNT_TYPE_LIST 6
#define  LEN_ISSUER_ARC            2
#define LEN_PTAG_SONIC_BRANDING    1

#define TAG_TMSCAPK_STRUCT_VERSION          0x01

#define TMS_CAPK_STRUCT_VERSION             3
#define TMS_CAPK_STRUCT_VERSION_OFFSET      2
#define TMS_CAPK_STRUCT_VERSION_LEN         4

typedef enum
{
    ETAG_IIN                              = 0x42,
    ETAG_AID                              = 0x4F,
    ETAG_APP_LABEL                        = 0x50,
    ETAG_TRACK1_DATA                      = 0x56,
    ETAG_TRACK2_ED                        = 0x57,
    ETAG_ICC_PAN_CN                       = 0x5A,
    ETAG_61                               = 0x61,
    ETAG_FCI                              = 0x6F,
    ETAG_70                               = 0x70,
    ETAG_IST1_B_71                        = 0x71,
    ETAG_IST2_B_72                        = 0x72,
    ETAG_77                               = 0x77,
    ETAG_80                               = 0x80,
    ETAG_AMOUNT_BIN                       = 0x81,
    ETAG_ICC_AIP_B                        = 0x82,
    ETAG_83                               = 0x83,
    ETAG_DF_NAME                          = 0x84,
    ETAG_KEY_VERSION                      = 0x85,
    ETAG_ISSUER_SCRIPT_COMMAND            = 0x86,
    ETAG_PRIORITY                         = 0x87,
    ETAG_SFI                              = 0x88,
    ETAG_ARC                              = 0x8A,
    ETAG_CDOL1                            = 0x8C,
    ETAG_CDOL2                            = 0x8D,
    ETAG_CVM_LIST                         = 0x8E,
    ETAG_CA_PUB_KEY_IDX_CARD              = 0x8F,
    ETAG_ISSUER_PUB_KEY_CERT              = 0x90,
    ETAG_ISSUER_AUTH_DATA                 = 0x91,
    ETAG_ISSUER_PUB_REMAINDER             = 0x92,
    ETAG_SSAD                             = 0x93, //Signed Static Application Data
    ETAG_ICC_AFL                          = 0x94,
    ETAG_TVR                              = 0x95,
    ETAG_TDOL                             = 0x97,
    ETAG_TC_HASH                          = 0x98,
    ETAG_CH_PIN                           = 0x99,
    ETAG_TRANSACTION_DATE                 = 0x9A,
    ETAG_TSI                              = 0x9B,
    ETAG_TRANSACTION_TYPE                 = 0x9C,
    ETAG_FCI_PROP_TEMPLATE                = 0xA5,
    ETAG_CARD_HOLDER_NAME                 = 0x5F20,
    ETAG_ICC_AEXPD_N                      = 0x5F24,
    ETAG_ICC_AED_N                        = 0x5F25,
    ETAG_ICC_ISSUER_COUNTRY_CODE_N        = 0x5F28,
    ETAG_TRANSACTION_CURR_CODE            = 0x5F2A,
    ETAG_LANG_PREFERENCE                  = 0x5F2D,
    ETAG_SERVICE_CODE                     = 0x5F30,
    ETAG_ICC_PANSN_N                      = 0x5F34,
    ETAG_TRANSACTION_CURR_EXP             = 0x5F36,
    ETAG_ISS_URL                          = 0x5F50,
    ETAG_DEK_IDENTIFIER                   = 0x5F53,
    ETAG_BANK_IDENTIFIER_CODE             = 0x5F54,
    ETAG_ICC_COMMON_DEBIT_COUNTRY_CODE    = 0x5F55,
    ETAG_ICC_ISSUER_COUNTRY_CODE_ALPHA3   = 0x5F56,
    ETAG_ACCOUNT_TYPE                     = 0x5F57,
    ETAG_ACQUIRER_IDENTIFIER              = 0x9F01,
    ETAG_AMOUNT                           = 0x9F02,
    ETAG_AMOUNT_OTHER                     = 0x9F03,
    ETAG_AMOUNT_OTHER_BIN                 = 0x9F04,
    ETAG_AID_TERMINAL                     = 0x9F06,
    ETAG_APP_USAGE_CONTROL                = 0x9F07,
    ETAG_APP_VER_CARD                     = 0x9F08,
    ETAG_APP_VER_READER                   = 0x9F09,
    ETAG_APPLICATION_PROPRIETARY_DATA     = 0x9F0A,
    ETAG_CH_NAME_EXT                      = 0x9F0B,
    ETAG_IAC_DEFAULT                      = 0x9F0D,
    ETAG_IAC_DENIAL                       = 0x9F0E,
    ETAG_IAC_ONLINE                       = 0x9F0F,
    ETAG_IAD                              = 0x9F10,
    ETAG_ISSUER_CODE_TAB_IDX              = 0x9F11,
    ETAG_APP_PREFERRED_NAME               = 0x9F12,
    ETAG_LAST_ONLINE_ATC                  = 0x9F13,
    ETAG_LOWER_CONS_OFFLINE_LIMIT         = 0x9F14,
    ETAG_MERCHANT_CAT_CODE                = 0x9F15,
    ETAG_MERCHANT_IDENTIFIER              = 0x9F16,
    ETAG_PTC                              = 0x9F17,
    ETAG_ISI_B_9F18                       = 0x9F18,
    ETAG_TRID                             = 0x9F19,
    ETAG_TERMINAL_COUNTRY_CODE            = 0x9F1A,
    ETAG_TERMINAL_FLOOR_LIMIT             = 0x9F1B,
    ETAG_TERMINAL_IDENTIFICATION          = 0x9F1C,
    ETAG_TERMINAL_RISK_MANAGEMENT_DATA    = 0x9F1D,
    ETAG_IFDSN                            = 0x9F1E,
    ETAG_MC_TRACK1_DD                     = 0x9F1F,
    ETAG_MC_TRACK2_DD                     = 0x9F20,
    ETAG_TRANSACTION_TIME                 = 0x9F21,
    ETAG_CA_PUBKEY_INDEX_READER           = 0x9F22,
    ETAG_UPPER_CONS_OFFLINE_LIMIT         = 0x9F23,
    ETAG_PAYMENT_ACCOUNT_REFERENCE        = 0x9F24,
    ETAG_ICC_LAST_4_DIGITS_PAN_N          = 0x9F25,
    ETAG_AC                               = 0x9F26,
    ETAG_CID                              = 0x9F27,
    ETAG_PE_PUB_KEY_CERT                  = 0x9F2D,
    ETAG_PE_PUB_KEY_EXP                   = 0x9F2E,
    ETAG_PE_PUB_KEY_REMAINDER             = 0x9F2F,
    ETAG_ISSUER_PUB_EXP                   = 0x9F32,
    ETAG_TERM_CAPABILITY                  = 0x9F33,
    ETAG_CVM_RESULTS                      = 0x9F34,
    ETAG_TERMINAL_TYPE                    = 0x9F35,
    ETAG_ATC                              = 0x9F36,
    ETAG_UN                               = 0x9F37,
    ETAG_PDOL                             = 0x9F38,
    ETAG_POS_ENTRY_MOD                    = 0x9F39,
    ETAG_APP_REF_CURRENCY                 = 0x9F3B,
    ETAG_ADD_CAPABILITIES                 = 0x9F40,
    ETAG_TRANSACTION_SC                   = 0x9F41,
    ETAG_APP_CURR_CODE                    = 0x9F42,
    ETAG_ICC_ACE_N                        = 0x9F44,
    ETAG_DATA_AUTH_CODE                   = 0x9F45,
    ETAG_ICC_PUB_KEY_CERT                 = 0x9F46,
    ETAG_ICC_PUB_KEY_EXP                  = 0x9F47,
    ETAG_ICC_PUB_KEY_REMAINDER            = 0x9F48,
    ETAG_DDOL                             = 0x9F49,
    ETAG_SDA_TAG_LIST_ICC                 = 0x9F4A,
    ETAG_SDAD                             = 0x9F4B, //Signed Dynamic Application Data
    ETAG_ICC_DYNAMIC_NUMBER               = 0x9F4C,
    ETAG_LOG_ENTRY                        = 0x9F4D,
    ETAG_MERCHANT_NAME_LOC                = 0x9F4E,
    ETAG_LOG_FORMAT                       = 0x9F4F,
    ETAG_OFFLINE_ACCUMULATOR_BAL          = 0x9F50,
    ETAG_DRDOL                            = 0x9F51,
    ETAG_TRANSACTION_CAT_CODE             = 0x9F53,
    ETAG_DS_ODS_CARD                      = 0x9F54,
    ETAG_PROGRAM_ID                       = 0x9F5A,
    ETAG_DS_DOL                           = 0x9F5B,
    ETAG_DS_REQ_OPERATOR_ID               = 0x9F5C,
    ETAG_APP_CAP_INFO_ICC                 = 0x9F5D,
    ETAG_DS_ID                            = 0x9F5E,
    ETAG_DS_SLOT_AVAILABILITY             = 0x9F5F,
    ETAG_CVC3_T1                          = 0x9F60,
    ETAG_CVC3_T2                          = 0x9F61,
    ETAG_PCVC3_T1                         = 0x9F62,
    ETAG_PUNATC_T1                        = 0x9F63,
    ETAG_NATC_T1                          = 0x9F64,
    ETAG_PCVC3_T2                         = 0x9F65,
    ETAG_PUNATC_T2                        = 0x9F66,
    ETAG_NATC_T2                          = 0x9F67,
    ETAG_ICC_UDOL                         = 0x9F69,
    ETAG_UN_MC                            = 0x9F6A,
    ETAG_MC_TRACK2_DATA                   = 0x9F6B,
    ETAG_CTQ                              = 0x9F6C,
    ETAG_MSR_APP_VER_READER               = 0x9F6D,
    ETAG_THIRD_PARTY_DATA                 = 0x9F6E,
    ETAG_DS_SLOT_MANAGEMENT_CONTROL       = 0x9F6F,
    ETAG_CARD_INTERFACE_CAPABILITIES      = 0x9F70,
    ETAG_DE_PROTECTED_DATA_ENVELOPE_1     = 0x9F70,
    ETAG_DE_PROTECTED_DATA_ENVELOPE_2     = 0x9F71,
    ETAG_DE_PROTECTED_DATA_ENVELOPE_3     = 0x9F72,
    ETAG_DE_PROTECTED_DATA_ENVELOPE_4     = 0x9F73,
    ETAG_DE_PROTECTED_DATA_ENVELOPE_5     = 0x9F74,
    ETAG_DE_UNPROTECTED_DATA_ENVELOPE_1   = 0x9F75,
    ETAG_DE_UNPROTECTED_DATA_ENVELOPE_2   = 0x9F76,
    ETAG_DE_UNPROTECTED_DATA_ENVELOPE_3   = 0x9F77,
    ETAG_DE_UNPROTECTED_DATA_ENVELOPE_4   = 0x9F78,
    ETAG_DE_UNPROTECTED_DATA_ENVELOPE_5   = 0x9F79,
    ETAG_DS_SUMMARY_1                     = 0x9F7D,
    ETAG_MOBILE_SUPPORT_INDICATOR         = 0x9F7E,
    ETAG_DS_UNPREDICTABLE_NUMBER          = 0x9F7F,
    ETAG_FCI_ISSUER_DATA                  = 0xBF0C,
    ETAG_INTL_FLOOR_LIMIT                 = 0xDF45,
    ETAG_POS_CH_INTERACTION_INFO          = 0xDF4B,
    ETAG_DS_INPUT_CARD                    = 0xDF60,
    ETAG_DS_DIGEST_H                      = 0xDF61,
    ETAG_INTERAC_APP_SELECTION_FLAG       = 0xDF62, // Conflicts
    ETAG_DS_ODS_INFO                      = 0xDF62,
    ETAG_DS_ODS_TERMINAL                  = 0xDF63,
    //TODO: Move following tags to new enum either Mastercard or EMVCL
    ETAG_DS_SUMMARY_2                     = 0xDF8101,
    ETAG_DS_SUMMARY_3                     = 0xDF8102,
    ETAG_BAL_READ_BEFORE_GENAC            = 0xDF8104,
    ETAG_BAL_READ_AFTER_GENAC             = 0xDF8105,
    ETAG_DATA_NEEDED                      = 0xDF8106,
    ETAG_CDOL1_RELATED_DATA               = 0xDF8107,
    ETAG_DS_AC_TYPE                       = 0xDF8108,
    ETAG_DS_INPUT_TERMINAL                = 0xDF8109,
    ETAG_DS_ODS_INFO_READER               = 0xDF810A,
    ETAG_DS_SUMMARY_STATUS                = 0xDF810B,
    ETAG_KERNEL_ID                        = 0xDF810C,
    ETAG_DSVN_TERMINAL                    = 0xDF810D,
    ETAG_DS_POST_GAC_PUTDATA_STATUS       = 0xDF810E,
    ETAG_DS_PRE_GAC_PUTDATA_STATUS        = 0xDF810F,
    ETAG_DS_PROCEED_FIRST_WRITE_FLAG      = 0xDF8110,
    ETAG_TAGS_TO_READ                     = 0xDF8112,
    ETAG_DRDOL_RELATED_DATA               = 0xDF8113,
    ETAG_REFERENCE_CONTROL_PARAM          = 0xDF8114,
    ETAG_TERMINAL_ERROR_INDICATION        = 0xDF8115,
    ETAG_UI_REQ_DATA                      = 0xDF8116,
    ETAG_CARD_DATA_INPUT_CAP              = 0xDF8117,
    ETAG_CVM_CAP_CVM_REQ                  = 0xDF8118,
    ETAG_CVM_CAP_NO_CVM_REQ               = 0xDF8119,
    ETAG_DEFAULT_UDOL                     = 0xDF811A,
    ETAG_CL_MC_KERNEL_CFG                 = 0xDF811B,
    ETAG_MAX_LIFETIME_TTL_RECORD          = 0xDF811C, //Max Lifetime of Torn Transaction Log Record
    ETAG_MAX_NO_TTL_RECORD                = 0xDF811D, //Max Number of Torn Transaction Log Records
    ETAG_MSR_CVM_CAP_CVM_REQ              = 0xDF811E,
    ETAG_SECURITY_CAP                     = 0xDF811F,
    ETAG_PDOL_RELATED_DATA                = 0xDF8111,
    ETAG_TAC_DEFAULT                      = 0xDF8120,
    ETAG_TAC_DENIAL                       = 0xDF8121,
    ETAG_TAC_ONLINE                       = 0xDF8122,
    ETAG_CL_FLOOR_LIMIT                   = 0xDF8123,
    ETAG_CL_TR_LIMIT_NO_ON_DEVICE_CVM     = 0xDF8124, //Reader Contactless Transaction Limit (No On-device CVM),
    ETAG_CL_TR_LIMIT_ON_DEVICE_CVM        = 0xDF8125, //Reader Contactless Transaction Limit (On-device CVM)
    ETAG_READER_CVM_REQ_LIMIT             = 0xDF8126, //Reader CVM Required Limit
    ETAG_TIME_OUT_VALUE                   = 0xDF8127,
    ETAG_IDS_STATUS                       = 0xDF8128,
    ETAG_OUTCOME_PARAM_SET                = 0xDF8129,
    ETAG_DDCARD_T1                        = 0xDF812A,
    ETAG_DDCARD_T2                        = 0xDF812B,
    ETAG_MSR_CVM_CAP_NO_CVM_REQ           = 0xDF812C,
    ETAG_MSG_HOLD_TIME                    = 0xDF812D,
    ETAG_CT_KERNEL_CFG                    = 0xDF812E,
    ETAG_HOLD_TIME                        = 0xDF8130,
    ETAG_PHONE_MSG_TABLE                  = 0xDF8131,

    ETAG_DEFAULT_DDOL                     = 0xDF8132, // Conflicts
    ETAG_DEFAULT_TDOL                     = 0xDF8133, // Conflicts
    ETAG_RRP_GRACE_PERIOD_MIN             = 0xDF8132,
    ETAG_RRP_GRACE_PERIOD_MAX             = 0xDF8133,
    ETAG_ICC_UN                           = 0xDF8134, // Conflicts
    ETAG_RRP_CAPDU_EXPECTED_TIME_TERM     = 0xDF8134,
    ETAG_RRP_RAPDU_EXPECTED_TIME_TERM     = 0xDF8135,
    ETAG_RRP_ACCURACY_THRESHOLD           = 0xDF8136,
    ETAG_RRP_TIME_MISMATCH_THRESHOLD      = 0xDF8137,
    PTAG_PAYMENT_METHOD                   = 0xDF8138, //this tag is used to identify if payment method is apple pay
    PTAG_ACCOUNT_TYPE_LIST                = 0xDF8139, //this tag lists supported account type for an application
                                                        // each account type is one byte as define in crs_define_type.h
    PTAG_ICC_AID_LIST                     = 0xDF8140,
    PTAG_CANDIDATE_AID_LIST               = 0xDF8141,

    ETAG_RRP_ENTROPY_TERMINAL             = 0xDF8301,
    ETAG_RRP_ENTROPY_DEVICE               = 0xDF8302,
    ETAG_RRP_APDU_MIN_TIME                = 0xDF8303,
    ETAG_RRP_APDU_MAX_TIME                = 0xDF8304,
    ETAG_RRP_APDU_DEVICE_ESTIMATED_TIME   = 0xDF8305,
    ETAG_RRP_TIME_MEASURED                = 0xDF8306,
    ETAG_RRP_COUNTER                      = 0xDF8307,

    ETAG_TORN_RECORD                      = 0xFF8101,
    ETAG_TAGS_TO_WRITE_BEFORE_GAC         = 0xFF8102,
    ETAG_TAGS_TO_WRITE_AFTER_GAC          = 0xFF8103,
    ETAG_DATA_TO_SEND                     = 0xFF8104,
    ETAG_DATA_RECORD                      = 0xFF8105, //defined by MasterCard, can be used with all parser
    ETAG_TERMINAL_DD_DATA                 = 0xFF8106, //defined by MasterCard, can be used with all parser
    ETAG_ADVICE_RECORD                    = 0xFF8108,
    ETAG_REVERSAL_RECORD                  = 0xFF8109,
    ETAG_EMV_FINANCIAL_REQ                = 0xFF810A,
    ETAG_EMV_FINANCIAL_CONF               = 0xFF810B,
    PTAG_SERVICE_DEBUG_DATA               = 0xFF810C, //data included to support debug logging

    ETAG_TARGET_PERCENT_FOR_RANDOMSEL           = 0xDF8201,  //Target percentage to be used for Random Selection
    ETAG_THRESHOLD_FOR_BIASED_RANDOMSEL         = 0xDF8202, //Threshold Value for Biased Random Selection
    ETAG_MAXTARGET_PERCENT_FOR_BIASED_RANDOMSEL = 0xDF8203, //Maximum Target percentage to be used for Biased Random Selection
    ETAG_ICC_UID                                = 0xDF8205,
    ETAG_INTERAC_TERMINAL_CAPABILITIES          = 0xDF8206,//for contacless only interac reader

    // Interac specific tags
    ETAG_TERMINAL_CONTACTLESS_RECEIPT_REQUIRED_LIMIT   = 0x9F5D,
    ETAG_TERMINAL_OPTION_STATUS                        = 0x9F5E,
    ETAG_TERMINAL_CONTACTLESS_FLOOR_LIMIT              = 0x9F5F,

    // Amex specifc tags

    ETAG_AMEX_EXPRESSPAY_TERMINAL_CAPABILITIES = 0x9F6D,
    ETAG_AMEX_ENHANCED_CONTACTLESS_READER_CAPABILITIES  = 0x9F6E,
    ETAG_AMEX_MOBILE_CVM_RESULT                = 0x9F71,

    // Discover specific tags
    ETAG_DISCOVER_OFFLINE_BALANCE               = 0xD1,
    ETAG_DISCOVER_CPR                           = 0x9F71,
    ETAG_DISCOVER_AVN                           = 0x9F7D,
    ETAG_DISCOVER_DCVV                          = 0x9F7E,
    ETAG_DISCOVER_DCVV_9F80                     = 0x9F80,

    // JCB-CL specific tags
    ETAG_JCB_CARDHOLDER_VERIFICATION_STATUS     = 0x9F50,
    ETAG_JCB_TERMINAL_COMPATIBILITY_INDICATOR   = 0x9F52,
    ETAG_JCB_TERMINAL_INTERCHANGE_PROFILE       = 0x9F53,
    ETAG_JCB_MSD_DEFAULT_MDOL                   = 0x9F5C,
    ETAG_JCB_OFFLINE_BALANCE                    = 0x9F5F,
    ETAG_JCB_ISSUER_UPDATE_PARAMETER            = 0x9F60,

    // VAS specific tags
    ETAG_VAS_APPLICATION_VERSION_NUMBER_MOBILE   = 0x9F21,
    ETAG_VAS_APPLICATION_VERSION_NUMBER_TERMINAL = 0x9F22,
    ETAG_VAS_MOBILE_CAPABILITIES                 = 0x9F23,
    ETAG_VAS_UNPREDICTABLE_NUMBER_MOBILE         = 0x9F24,
    ETAG_VAS_MERCHANT_LOYALTY_ID                 = 0x9F25,
    ETAG_VAS_TERMINAL_CAPABILITIES               = 0x9F26,
    ETAG_VAS_DATA                                = 0x9F27,
    ETAG_VAS_UNPREDICTABLE_NUMBER_TERMINAL       = 0x9F28,
    ETAG_VAS_MERCHANT_LOYALTY_URL                = 0x9F29,
    PTAG_VAS_MERCHANT_LOYALTY_ID_LIST            = 0xDF8142,

    PTAG_AID_ACTUAL_LEN                      = 0xC1, //used internally to store aid actual length in candidate list entry
    PTAG_KERNEL_ID                           = 0xC2, //used internally to store kid in candidate list entry
    PTAG_ENCIPHERED_PIN_DATA                 = 0xC0,

    PTAG_TRANSACTION_TYPE_BITMASK            = 0xDF8511,
    PTAG_TRANSACTION_RELATED_DEFAULT_DATA    = 0xFF8512,
    PTAG_ADD_REVOCATION_LIST_ENTRY           = 0xFF8513,
    PTAG_EFTPOS_LEGACY_CARD_OUTCOME_DOL      = 0xDF8513,
    PTAG_EFTPOS_APP_SELECTION_SUPPORTED      = 0xDF8514,
    PTAG_LEAST_COST_ROUTING_LIMIT            = 0xDF8515,
    PTAG_LEAST_COST_ROUTING_BINLIST          = 0xDF8516,

    PTAG_CERTIFICATION_FEATURE               = 0xDF8520,
    PTAG_CT_MAX_CARD_ERROR_COUNT             = 0xDF8521, //number of contact card errors before prompting to use MSR if supported by term capabilities
                                                            //if zero or not present, will never prompt for MSR
    PTAG_SELECTED_COMBINATION                = 0xDF8522,
    PTAG_STATUS_BYTES                        = 0xDF8523,
    PTAG_READER_SUPPORTED_LIST               = 0xDF8524,
    PTAG_APP_SELECTION_INDICATOR             = 0xDF8525, //Indicates whether the associated AID in the terminal must match the AID in the card exactly including the length of the AID,
                                                         //or only up to the length of the AID in the terminal. There is only one Application Selection Indicator per AID in the terminal. 1 = partial AID match permitted
    PTAG_DE_CAP_INFO                         = 0xDF8526,
    PTAG_TORN_TEMP_RECORD                    = 0xDF8527,
    PTAG_COMMAND_ID                          = 0xDF8528,
    PTAG_LAST_CARD_RESPONSE                  = 0xDF8529,
    PTAG_ENTRYPOINT_CONFIG                   = 0xDF8530,
    PTAG_PREPROCESSING_INDICATOR             = 0xDF8531, //2 byte Value:
                                                            //1st byte = bit-1 = Status Check Requested, bit-2 = CL-Application Not Allowed, bit-3 = Zero Amount, bit-4= Reader CVM Required Limit Exceeded, bit-5= Reader Contactless Floor Limit Exceeded
                                                            //2nd Byte = copy of TTQ, represent 2nd byte of TTQ, each kernel (if required) must ORed with actual TTQ second byte
    PTAG_PREPROCESSING_CHECK_FLAG            = 0xDF8532, // one byte value = bit-1  Status Check Support Flag, bit-2-Zero Amount Allowed Flag, bit-3 transaction limit, bit-4 CVM limit, bit-5 reader Floor limit, bit-7 PP_CHECK_FLAG_ZERO_AMOUNT_NOT_ALLOWED
    PTAG_CL_TR_LIMIT                         = 0xDF8533, //
    PTAG_PREPROCESSING_TTQ                   = 0xDF8534, //4 byte TTQ represent Visa TTQ
    PTAG_RSA_KEY_ALGO_INDICATOR              = 0xDF8535,
    PTAG_HASH_ALGO_INDICATOR                 = 0xDF8536,
    PTAG_CRYPTO_RSA_RECOVER_INPUT            = 0xDF8537,
    PTAG_TORN_RECORD                         = 0xDF8538,
    PTAG_SELECTNEXT_OUTCOME_PARAM_SET        = 0xFF8539,
    PTAG_GPO_CMD_DATA                        = 0xDF853A,
    PTAG_GAC1_CMD_DATA                       = 0xDF853B,
    PTAG_GAC2_CMD_DATA                       = 0xDF853C,
    PTAG_EMV_OUTCOME_DOL                     = 0xDF853D,
    PTAG_MSD_OUTCOME_DOL                     = 0xDF853E,
    PTAG_REVERSAL_OUTCOME_DOL                = 0xDF853F,
    PTAG_ADVICE_OUTCOME_DOL                  = 0xDF8540,
    PTAG_AMEX_UN_RANGE                       = 0xDF8541, //range of generated UN
    PTAG_TRACK2_DATA                         = 0xDF8542,
    PTAG_TRACK1_DATA                         = 0xDF8543,
    PTAG_GENERATE_NEW_UN                     = 0xDF8544,
    PTAG_IS_RESTARTED                        = 0xDF8545,
    PTAG_UNKOWNTAGS_UPDATE_CONDITION         = 0xDF8546,
    PTAG_SUPPORTED_AID_KERNEL_ID_MAPPING     = 0xDF8547,
    PTAG_SUPPRESSION_CODE_OR_CONDITIONS      = 0xFF8548,
    PTAG_SUPPRESSION_CODE_CONDITIONS         = 0xDF8549,
    PTAG_TERMINAL_COUNTRY_CODE_ALPHA3        = 0xDF854A, //this will used in Selection process to prepare primary and secondary list defined by Interac. by default it is CAN
    PTAG_MSG_SIGNAL_SET                      = 0xFF854B,
    PTAG_MAX_CARD_READ_RETRY                 = 0xDF854C,
    PTAG_END_APP_TRY_AGAIN_OUTCOME           = 0xFF854D,
    PTAG_ISSUER_PUB_KEY_PLAIN_CERT           = 0xDF854E,
    PTAG_ICC_PUB_KEY_PLAIN_CERT              = 0xDF854F,
    PTAG_PE_PUB_KEY_PLAIN_CERT               = 0xDF8550,
    PTAG_SDAD_PLAIN_CERT                     = 0xDF8551,
    PTAG_SSAD_PLAIN_CERT                     = 0xDF8552,
    PTAG_TRANSACTION_LOG_FLAG                = 0xDF8553,
    PTAG_EXCEPTION_FILE_HASH_DOL             = 0xDF8554,

    PTAG_ISSUER_SCRIPT_RESULT                = 0xDF8556,
    PTAG_MERCHANT_FORCED_ONLINE              = 0xDF8557,
    PTAG_ISSURE_VOICE_REFERRAL               = 0xDF8558,
    PTAG_ASK_ACCOUNT_TYPE                    = 0xDF8559,
    PTAG_TRANSACTION_AMOUNT                  = 0xDF855A,
    PTAG_PIN_INPUT                           = 0xDF855B,
    PTAG_TRANSACTION_FEATURE                 = 0xDF855C,

    PTAG_START_CONTACT_CARD_REMOVAL          = 0xDF855E, //EMV module doesn't handle contact card removal
                                                            //but it notify in outcome by adding this tag that App can handle card removal.
    PTAG_UI_STATUS                           = 0xDF855F,
    PTAG_PARTIAL_EMV_TX                      = 0xDF8560, // two byte 0 RFU,
                                                            // byte 1 = 0x01 perform partial emv for contactless,
                                                            // byte 1 = 0x02 perform partial emv for contact

    PTAG_OUT_SIGNAL                          = 0xFF8561,
    PTAG_CARDHOLDER_PREFERRED_LANGUAGE       = 0xDF8562, //EMV will return this tag if card holder language.
    PTAG_CL_PARTIAL_SELECT                   = 0xDF8563,
    PTAG_PIN_BYPASS_ENABLED                  = 0xDF8564, // enable / disable pin bypass feature
    PTAG_MSD_NOCVN17_OUTCOME_DOL             = 0xDF8565,
    PTAG_PIN_BYPASS_INTL_ONLY_ENABLED        = 0xDF8567,
    PTAG_TRANSACTION_LIMIT_SET               = 0xDF8568,
    PTAG_FIELDOFF_DELAY                      = 0xDF8569,
    PTAG_DRL_ACTIVE                          = 0xDF856A,
    PTAG_GPO_RESP_DATA                       = 0xDF856B, //used to store GPO resp w/o SDAD for D-PAS ODA
    PTAG_CT_CVM_REQUIRED_LIMIT               = 0xDF856C, // Defines the CVM required limit for Contact txn
    PTAG_CT_CVM_CAP_BELOW_LIMIT              = 0xDF856D, // Defines the CVM Capability below CVM required limit for Contact txn
    PTAG_CT_MCC_WHITELIST_FOR_CVM_CAP        = 0xDF856E, // Defines the MCC white list to apply CVM Capability below CVM required limit for Contact txn
    PTAG_SPE_PAYMENT_FEATURE                 = 0xDF856F, // Defines a list of features supported by K21 that needs K400 support

    PTAG_CRYPTO_INPUT_DATA                   = 0xDF8570,
    PTAG_CRYPTO_KEY_DATA                     = 0xDF8571,
    PTAG_CRYPTO_ICV_DATA                     = 0xDF8572,
    PTAG_RRP_SDAD_DATA                       = 0xDF8573,
    PTAG_ENABLE_APPLICATION_SELECTION_FLAG   = 0xDF8574,
    PTAG_ENABLE_PSE_SELECTION                = 0xDF8575,

    PTAG_COMMON_DEBIT_AID_LIST               = 0xDF8576,
    PTAG_COMMON_DEBIT_ENABLED                = 0xDF8577,
    PTAG_ENABLE_UNLOCK_PHONE                 = 0xDF8578,
    PTAG_AMOUNT_OK_TIMEOUT                   = 0xDF8579,
    PTAG_SELECT_ACCOUNT_TIMEOUT              = 0xDF857A,
    PTAG_MISC_CONFIGURATION                  = 0xDF857B, //b7-b1 rfu, b0=enable/disable led-buzzer request on collision error
    PTAG_MAX_ALLOWED_COLLISION_ERROR         = 0xDF857C, //nfc driver, cannot distinguish between noise and collision.
                                                            //process CI will count collision error and return collision error host only if
                                                            //count > max_allowed_collision_error
    PTAG_SCHEME_FALLBACK_LIST                = 0xDF857D,
    PTAG_ENABLE_GET_TRID                     = 0xDF857E, //enables get data command to get TRID in Kernel02
    PTAG_ENABLE_SELECT_VAS                   = 0xDF857F, //enables select vas command in cl entry point

    PTAG_SONIC_BRANDING                      = 0xDF8601, //enables sonic branding for an application
    PTAG_ENABLE_PAN_MASKING                  = 0xDF8602, //enables pan masking in order to protect production card PANs
    PTAG_COMMON_DEBIT_TYPE                   = 0xDF8603, // Identify an application if it is common debit application
    PTAG_BUZZER_LED_DATA                     = 0xDF8604, // Tag include buzzer led sequence information
    PTAG_CARD_WAIT_TIMEOUT                   = 0xDF8605, // Tag used internally to hold card timeout value
    PTAG_ADDITIONAL_SPE_PAYMENT_FEATURE      = 0xDF8606, // Additional bytes of feature flags from cpu1 via start transaction request


    PTAG_TERM_DATA_CFG_VER                   = 0xDF21,
    PTAG_TERM_LANG_CODE                      = 0xDF22,   // Can be a list of supported languages
    PTAG_TERM_TENDER_TYPE                    = 0xDF23,
    PTAG_TERM_ALLOWED_TRANSACTIONS           = 0xDF24,
    PTAG_PIN_PAD_TIMER_DIGITS                = 0xDF25, // individual digit
    PTAG_PIN_PAD_TIMER                       = 0xDF26, // complete entry
    PTAG_TX_TIMEOUT                          = 0xDF27,
    PTAG_START_CARD_REMOVAL_ALERT_TONE       = 0xDF29,
    PTAG_TRACK2_ENC_FLAG                     = 0xDF2A, //Flag to indicate weather to encrypt track2 or not
    PTAG_IS_CAHSBACK_AMT_PART_OF_AMT_AUTH    = 0xDF2B,
    PTAG_CURRENCY_SYMBOL_ASCII               = 0xDF2D,
    PTAG_PUBKEY_MODULUS                      = 0xDF31,
    PTAG_PUBKEY_EXP                          = 0xDF32,
    PTAG_PUBKEY_CHECKSUM                     = 0xDF33,
    PTAG_REVOKED_CA_PUBKEY_INDEX             = 0xDF34,
    PTAG_REVOKED_CERT_SERIAL_NUMBER          = 0xDF35,
    PTAG_CA_PUBKEY_EXPIRY_DATE               = 0xDF36,
    PTAG_CONFIGURATION_NUMBER                = 0xDF37,

    PTAG_CANDIDATE_LIST_ENTRY                = 0xE1,
    PTAG_AID_ENTRY                           = 0xE1,
    PTAG_RID_ENTRY                           = 0xE1,
    PTAG_PUBLICKEY_ENTRY                     = 0xE2,
    PTAG_REVOCATION_LIST_ENTRY               = 0xE3,
    PTAG_CURRENCY_MAP_ENTRY                  = 0xE3,

    PTAG_VISA_CVN17_ENABLE                   = 0xDF8317,
    PTAG_VISA_TRACK1_INCLUDED                = 0xDF831C,
    PTAG_VISA_TRACK2_INCLUDED                = 0xDF832C,
    PTAG_VISA_TERM_ENTRY_CAPABILITY          = 0xDF833C,

    ETAG_VISA_AOSA                           = 0x9F5D,
    ETAG_VISA_CARD                           = 0x9F69,
    ETAG_VISA_FFI                            = 0x9F6E,
    ETAG_VISA_CED                            = 0x9F7C,      // Customer Exclusive Data

    PTAG_VISA_IRWIN_READER_TERMINAL          = 0xFF8107,

    ETAG_INTERAC_TERM_OPTION_STATUS          = 0x9F5E,
    ETAG_INTERAC_MERCHANT_TYPE_IND           = 0x9F58,
    ETAG_INTERAC_TTI                         = 0x9F59,
    ETAG_INTERAC_TTT                         = 0x9F5A,
    ETAG_INTERAC_CTI                         = 0x9F63,
    ETAG_TTQ                                 = 0x9F66,
    ETAG_INTERAC_FFI                         = 0x9F70,     // form factor indicator
    PTAG_INTERAC_RETRY_COUNTER               = 0xDF8204,

    // JCB-CL specific tags
    PTAG_COMBINATION_OPTIONS                 = 0xDF8611,
    PTAG_TRANSACTION_MODE                    = 0xDF8612,

    // elite test case tags
    PTAG_UIRESPONSE_CODE                     = 0xD1,
    PTAG_UIMESSAGE_ACTORID                   = 0xD2,

    PTAG_UIRESPONSE_TOUCHPADKEY              = 0xD3,
    PTAG_UIRESPONSE_INPUT                    = 0xD4,
    PTAG_UIRESPONSE_PINBYPASSED              = 0xD5,
    PTAG_UIRESPONSE_LISTINDEX                = 0xD6,
    PTAG_UIRESPONSE_ACCOUNTTYPE              = 0xD7,
    PTAG_UIRESPONSE_VOICEREFER               = 0xD8,

    PTAG_DETRESPONSE_ID                      = 0xDA,
    PTAG_DETRESPONSE_DATA                    = 0xDB,
    PTAG_DETRESPONSE_NEXT_DET_REQUIRED       = 0xDC,

    PTAG_SIGNALRESPONSE_P1                   = 0xDD,
    PTAG_SIGNALRESPONSE_DATA                 = 0xDE,

    PTAG_DEKREQUEST_ID                       = 0xDF01,
    PTAG_DEKREQUEST_DATA                     = 0xDF02,
    PTAG_DEKREQUEST_READY_TO_RECEIVE         = 0xDF03,

    PTAG_UIREQUEST_USER_INTERFACE_TYPE       = 0xDF10,
    PTAG_UIREQUEST_MSG_ID_COUNT              = 0xDF11,
    PTAG_UIREQUEST_MSG_ID                    = 0xDF12,
    PTAG_UIREQUEST_TIMEOUT_MS                = 0xDF13,
    PTAG_UIREQUEST_LANGUAGE_PREFERENCE       = 0xDF14,
    PTAG_UIREQUEST_TERMINAL_DEFAULT_LANGUAGE = 0xDF15,
    PTAG_UIREQUEST_TRANSACTION_TYPE          = 0xDF16,
    PTAG_UIREQUEST_TRANSACTION_CURRENCY_CODE = 0xDF17,
    PTAG_UIREQUEST_AMOUNT_AUTHORIZED         = 0xDF18,
    PTAG_UIREQUEST_AMOUNT_AUTHORIZED_OTHER   = 0xDF19,
    PTAG_UIREQUEST_DIALOG_BOX                = 0xDF1A,
    PTAG_UIREQUEST_INPUTTYPE                 = 0xDF1B,
    PTAG_UIREQUEST_KEY_TIMEOUT_MS            = 0xDF1C,
    PTAG_UIREQUEST_MAX_DIGITS                = 0xDF1D,
    PTAG_UIREQUEST_PERIOD_OFFSET             = 0xDF1E,
    PTAG_UIREQUEST_PIN_BYPASS_ENABLED        = 0xDF1F,
    PTAG_UIREQUEST_APP_LABEL                 = 0xDF20,
    PTAG_UIREQUEST_CARD_INFO_TLV             = 0xDF21,
    PTAG_UIREQUEST_LIST_COUNT                = 0xDF22,
    PTAG_UIREQUEST_LIST                      = 0xDF23,
    PTAG_UIREQUEST_SELECTED_AID              = 0xDF24,
    PTAG_UIREQUEST_ACCOUNT_TYPE_LIST         = 0xDF25,
    PTAG_UIREQUEST_AUDIO_VISUAL_ID           = 0xDF26,
    PTAG_UIREQUEST_BUZZER_LED_SEQUENCE       = 0xDF27,
    PTAG_UIREQUEST_CURRENCY_EXPONENT         = 0xDF28,

    PTAG_UIREQUEST_STATUS                    = 0xDF30,

    PTAG_STARTPAYREQ_TRANSACTION_MODE        = 0xDF31,

    PTAG_VASRESPONSE_PROTOCOL                = 0xDF40,
    PTAG_VASRESPONSE_RESULT                  = 0xDF41,
    PTAG_VASRESPONSE_DATA                    = 0xDF42,
    PTAG_VASRESPONSE_FINISHED                = 0xDF43,

    PTAG_UIREQUEST_ISSUER_ID                 = 0xDF46,
    PTAG_UIREQUEST_PAN_LAST4                 = 0xDF47,
    PTAG_UIREQUEST_CH_NAME                   = 0xDF48,
    PTAG_UIREQUEST_PSEUDO_PAN                = 0xDF49,
    PTAG_UIREQUEST_PANBLOCK                  = 0xDF4A,

    PTAG_TXRS_APP_NOTIFY                     = 0xFF8801,
    PTAG_TXRS_APP_NOTIFY_LANG_PREFS          = ETAG_LANG_PREFERENCE,
    PTAG_TXRS_APP_NOTIFY_ICODE_TBL_IDX       = 0xDF8801,
    PTAG_TXRS_APP_NOTIFY_ADF_NAME            = ETAG_DF_NAME,
    PTAG_TXRS_APP_NOTIFY_LABEL               = ETAG_APP_LABEL,
    PTAG_TXRS_APP_NOTIFY_PREF_NAME           = ETAG_APP_PREFERRED_NAME,
    PTAG_TXRS_APP_NOTIFY_PRORITY             = ETAG_PRIORITY,
    PTAG_TXRS_APP_EXP_SEL_REQ                = 0xDF8802,

    PTAG_TXRS_NOTIFICATION                   = 0xDF8803,
    PTAG_TXRS_POS_ENTRY_MODE                 = 0xDF8804,

    PTAG_TXRS_INTERCHANGE                    = 0xFF8802,
    PTAG_TXRS_INTERCHANGE_TYPE               = 0xDF8805,
    PTAG_TXRS_INTERCHANGE_ONLINE_PIN_PRESENT = 0xDF8806,
    PTAG_TXRS_INTERCHANGE_PLAIN_TEXT_TLV     = 0xFF8803,
    PTAG_TXRS_INTERCHANGE_ENCRYPTED_TLV      = 0xFF8804,

    PTAG_TXRS_ERROR_LED_BUZZER_SEQ           = 0xDF8807,
    PTAG_TXRS_FALLBACK                       = 0xDF8808,

    PTAG_TXRS_RESULT                         = 0xFF8805,
    PTAG_TXRS_RESULT_CODE                    = 0xDF8809,
    PTAG_TXRS_RESULT_DISPOSITION             = 0xDF880A,
    PTAG_TXRS_SIGNATURE_REQUESTED            = 0xDF880B,

    PTAG_TXRS_RESULT_CARD_INFO               = 0xFF8806,
    PTAG_TXRS_RESULT_CARD_INFO_ISSUER_ID     = 0xDF880C,
    PTAG_TXRS_RESULT_CARD_INFO_LAST_FOUR     = 0xDF880D,
    PTAG_TXRS_RESULT_CARD_INFO_NAME          = ETAG_CARD_HOLDER_NAME,

    PTAG_TXRS_PROFILE_SUPPORTED              = 0xDF880E,
} payment_tags_t;

typedef enum
{
    ACCOUNT_TYPE_DEFAULT     = 0x00,
    ACCOUNT_TYPE_SAVINGS     = 0x10,
    ACCOUNT_TYPE_CHEQUING    = 0x20,
    ACCOUNT_TYPE_CREDIT      = 0x30,
    ACCOUNT_TYPE_INVALID     = 0xFF
} account_type_t;
