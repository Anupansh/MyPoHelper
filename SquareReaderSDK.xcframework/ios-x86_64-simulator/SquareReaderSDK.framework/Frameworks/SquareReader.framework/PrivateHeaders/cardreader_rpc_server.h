// Copyright 2017 Square, Inc.

#pragma once

#include <stdbool.h>
#include <stdint.h>
#include <stdlib.h>

enum {
    CARDREADER_RPC_SERVER_DEFAULT_PORT = 50016
};

typedef struct cardreader_rpc_server_t cardreader_rpc_server_t;
typedef struct cardreader_rpc_server_backend_t cardreader_rpc_server_backend_t;

typedef int (*cardreader_rpc_server_reset_spe_cb_t)(void);

typedef struct {
    cardreader_rpc_server_reset_spe_cb_t reset_spe;
} cardreader_rpc_server_host_api_t;

typedef void (*cardreader_rpc_server_set_recv_resp_cb_t)(void *recv_resp_cb);
typedef bool (*cardreader_rpc_server_send_cmd_t)(void *sq_see_client, const uint8_t *serialized_command, size_t serialized_command_len, uint8_t *serialized_response_out, size_t *serialized_response_len_out);

typedef struct {
    cardreader_rpc_server_send_cmd_t send_cmd;
    void *context;
} cardreader_rpc_server_sq_see_api_t;

// Enable logging.
void cardreader_rpc_server_enable_logging(void);

// Create a USB cardreader backend
cardreader_rpc_server_backend_t *cardreader_rpc_server_backend_usb_create(void);

// Create a UART cardreader backend
cardreader_rpc_server_backend_t *cardreader_rpc_server_backend_uart_create(int fd);

// Initialize the RPC server and connect to the SPE
cardreader_rpc_server_t *cardreader_rpc_server_create(int client_socket, cardreader_rpc_server_backend_t *backend, cardreader_rpc_server_host_api_t* host_api, cardreader_rpc_server_sq_see_api_t *sq_see_api);

// Disconnect from the SPE and cleanup RPC server resources
void cardreader_rpc_server_destroy(cardreader_rpc_server_t *server);

// Run the RPC server
void cardreader_rpc_server_run(cardreader_rpc_server_t *server);
