// Copyright (c) 2015 Square, Inc. All rights reserved.

#pragma once

#include <stddef.h>
#include <stdint.h>

// Possible result codes for cr_user_interaction_* functions.
typedef enum
{
    CR_USER_INTERACTION_RESULT_SUCCESS = 0,
    CR_USER_INTERACTION_RESULT_INVALID_PARAMETER = 1,
    CR_USER_INTERACTION_RESULT_NOT_INITIALIZED = 2,
    CR_USER_INTERACTION_RESULT_ALREADY_INITIALIZED = 3,
    CR_USER_INTERACTION_RESULT_NOT_TERMINATED = 4,
    CR_USER_INTERACTION_RESULT_ALREADY_TERMINATED = 5,
    CR_USER_INTERACTION_RESULT_SESSION_ERROR = 6,
    CR_USER_INTERACTION_RESULT_CALL_UNEXPECTED = 7,
    CR_USER_INTERACTION_RESULT_FATAL = 8,
} cr_user_interaction_result_t;

struct cr_user_interaction_t;
struct cr_cardreader_t;

// Allocates the memory for a cr_user_interaction_t.
struct cr_user_interaction_t *cr_user_interaction_alloc(void);

// Initializes a cr_user_interaction_t with the specified callbacks and registers the feature with the
// specified cardreader.
cr_user_interaction_result_t cr_user_interaction_init(struct cr_user_interaction_t *user_interaction,
                                                      struct cr_cardreader_t *cardreader);

// Terminates a cr_user_interaction_t, deregistering the feature.
cr_user_interaction_result_t cr_user_interaction_term(struct cr_user_interaction_t *user_interaction);

// Frees the memory for a cr_user_interaction_t. The cr_user_interaction_t must have been previously terminated.
cr_user_interaction_result_t cr_user_interaction_free(struct cr_user_interaction_t *user_interaction);

cr_user_interaction_result_t cr_user_interaction_identify_reader(struct cr_user_interaction_t *user_interaction);
