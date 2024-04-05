// Copyright 2017, Square Inc.
#pragma once
#include <stdint.h>

// CC2640 and BTStack require opposite endianness UUIDs
#define REVERSE_UUID(x) {x[15], x[14], x[13], x[12], x[11], x[10], x[9], x[8], x[7], x[6], x[5], x[4], x[3], x[2], x[1], x[0]}

#define ATT_UUID_SIZE 16

typedef enum {
    SQBLE_PROFILE_CHAR_NONE = -1,
    SQBLE_PROFILE_READER_RX_CHAR,          // W - Reader RX
    SQBLE_PROFILE_READER_TX_CHAR,          // RN - Reader TX
    SQBLE_PROFILE_MTU_CHAR,                // RN 1 byte - negotiated MTU
    SQBLE_PROFILE_CONN_INTERVAL_CHAR,      // RN 1 byte - negotiated connection interval
    SQBLE_PROFILE_BOND_STATUS_CHAR,        // RN 1 byte - bond status
    SQBLE_PROFILE_CONN_CONTROL_CHAR,       // W 1 byte - connection control
    SQBLE_PROFILE_COMMS_VERSION_CHAR,      // R - comms version as bytes
    SQBLE_PROFILE_ACK_VECTOR_CHAR,         // R 2 byte - ack vector
    SQBLE_PROFILE_SERVICE_VERSION_CHAR,    // R 1 byte - service version. Increment when the characteristic change between firmware versions.
    SQBLE_PROFILE_NUM_OF_CHARS
} sqble_profile_char_id_t;

typedef enum {
    SQBLE_PROFILE_BOND_STATUS_NOT_BONDED = 0,
    SQBLE_PROFILE_BOND_STATUS_BONDING_FAILED,
    SQBLE_PROFILE_BOND_STATUS_BONDED_TO_CONNECTED_PEER,
    SQBLE_PROFILE_BOND_STATUS_BONDED_TO_OTHER_PEER
} sqble_profile_bond_status_t;

typedef enum {
    SQBLE_PROFILE_CONN_CONTROL_FORGET_BOND = 0,
    SQBLE_PROFILE_CONN_CONTROL_INITIATE_BONDING,
    SQBLE_PROFILE_CONN_CONTROL_EXCHANGE_MTU,
    SQBLE_PROFILE_CONN_CONTROL_UPDATE_CONN_PARAMS,
    SQBLE_PROFILE_CONN_CONTROL_SEND_SLAVE_SECURITY_REQ,
    SQBLE_PROFILE_CONN_CONTROL_DISCONNECT,
    SQBLE_PROFILE_CONN_CONTROL_INDICATE_SERVICE_CHANGE,
    SQBLE_PROFILE_CONN_CONTROL_RESET_TRANSPORT,
} sqble_profile_conn_control_t;

typedef const uint8_t att_uuid_t[ATT_UUID_SIZE];

extern att_uuid_t sqble_profile_service_uuid;
extern att_uuid_t sqble_profile_reader_rx_char_uuid;
extern att_uuid_t sqble_profile_reader_tx_char_uuid;
extern att_uuid_t sqble_profile_mtu_char_uuid;
extern att_uuid_t sqble_profile_conn_interval_char_uuid;
extern att_uuid_t sqble_profile_bond_status_char_uuid;
extern att_uuid_t sqble_profile_conn_control_char_uuid;
extern att_uuid_t sqble_profile_comms_version_char_uuid;
extern att_uuid_t sqble_profile_ack_vector_char_uuid;
extern att_uuid_t sqble_profile_service_version_char_uuid;
const char *sqble_profile_uuid_to_pretty_name(att_uuid_t uuid);
