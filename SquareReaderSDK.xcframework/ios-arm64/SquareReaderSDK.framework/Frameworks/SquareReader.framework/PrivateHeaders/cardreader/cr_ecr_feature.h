// Copyright (c) 2020 Square, Inc. All rights reserved.

#pragma once

#include <stdint.h>
#include <stddef.h>
#include <stdbool.h>

#include <cardreader_shared/crs_log.h>

typedef enum
{
    CR_ECR_RESULT_SUCCESS = 0,
    CR_ECR_RESULT_INVALID_PARAMETER,
    CR_ECR_RESULT_NOT_INITIALIZED,
    CR_ECR_RESULT_ALREADY_INITIALIZED,
    CR_ECR_RESULT_NOT_TERMINATED,
    CR_ECR_RESULT_ALREADY_TERMINATED,
    CR_ECR_RESULT_SESSION_ERROR,
} cr_ecr_result_t;

struct cr_cardreader_t;
struct cr_ecr_t;

typedef void (*cr_ecr_detect_card_t)(void *context, struct cr_ecr_t *ecr);
typedef void (*cr_ecr_send_command_apdu_t)(void *context, struct cr_ecr_t *ecr, uint8_t const *data, size_t data_len);
typedef void (*cr_ecr_deactivate_card_t)(void *context, struct cr_ecr_t *ecr, bool wait_for_removal);
typedef void (*cr_ecr_cancel_t)(void *context, struct cr_ecr_t *ecr);

typedef struct cr_ecr_event_api_t
{
    cr_ecr_detect_card_t detect_card;
    cr_ecr_send_command_apdu_t send_command_apdu;
    cr_ecr_deactivate_card_t deactivate_card;
    cr_ecr_cancel_t cancel;
    void* context;
} cr_ecr_event_api_t;

// Allocates the memory for a cr_ecr_t.
struct cr_ecr_t *cr_ecr_alloc(void);

// Initializes a cr_ecr_t with the specified callbacks and registers the feature with the specified cardreader.
cr_ecr_result_t cr_ecr_init(struct cr_ecr_t *ecr, struct cr_cardreader_t *cardreader, cr_ecr_event_api_t const *event_api);

// Terminates a cr_ecr_t, deregistering the feature.
cr_ecr_result_t cr_ecr_term(struct cr_ecr_t *ecr);

// Frees the memory for a cr_ecr_t. The cr_ecr_t must have been previously terminated.
cr_ecr_result_t cr_ecr_free(struct cr_ecr_t *ecr);

// Retrieves the identifier for the ecr subsystem that can be used for setting a subsystem specific log threshold.
crs_log_subsystem_t cr_ecr_get_log_subsystem(void);

// Sends a card detected message.
cr_ecr_result_t cr_ecr_send_card_detected(struct cr_ecr_t *ecr);

// Sends a response apdu.
cr_ecr_result_t cr_ecr_send_response_apdu(struct cr_ecr_t *ecr, uint8_t const *data, size_t data_len);

// Sends a card error.
cr_ecr_result_t cr_ecr_send_card_error(struct cr_ecr_t *ecr);

// Sends a card deactivated message.
cr_ecr_result_t cr_ecr_send_card_deactivated(struct cr_ecr_t *ecr, bool wait_for_removal);
