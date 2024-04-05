// Copyright (c) 2014 Square, Inc. All rights reserved.

#pragma once

#include <cardreader_shared/crs_power_msgs.h>

#include <stddef.h>
#include <stdint.h>

// Possible result codes for cr_power_* functions.
typedef enum
{
    CR_POWER_RESULT_SUCCESS = 0,
    CR_POWER_RESULT_INVALID_PARAMETER = 1,
    CR_POWER_RESULT_NOT_INITIALIZED = 2,
    CR_POWER_RESULT_ALREADY_INITIALIZED = 3,
    CR_POWER_RESULT_NOT_TERMINATED = 4,
    CR_POWER_RESULT_ALREADY_TERMINATED = 5,
    CR_POWER_RESULT_SESSION_ERROR = 7,
    CR_POWER_RESULT_CALL_UNEXPECTED = 8,
    CR_POWER_RESULT_FATAL = 9,
} cr_power_result_t;

struct cr_power_t;
struct cr_cardreader_t;

// Callback invoked when the reader provides battery voltage information.
typedef void (*cr_power_battery_voltage_cb_t)(void *context,
                                              struct cr_power_t *power,
                                              uint32_t const charge_percentage,
                                              int32_t const current,
                                              uint32_t const voltage,
                                              int32_t const temperature,
                                              bool const is_critical,
                                              crs_battery_mode_t battery_mode);

// Callback invoked to acknowledge a power reset or power off request.
typedef void (*cr_power_acknowledge_cb_t)(void *context,
                                          struct cr_power_t *power);

// Callback invoked to indicate an error with the battery
typedef void (*cr_power_battery_error_cb_t)(void *context,
                                            struct cr_power_t *power);

typedef struct cr_power_event_api_t
{
    // on_battery_voltage_response is invoked when LCR receives battery voltage information from
    // the reader in response to cr_power_get_battery_voltage.
    cr_power_battery_voltage_cb_t on_battery_voltage_response;
    // on_battery_error is invoked when LCR cannot read battery voltage information from the
    // reader in response to cr_power_get_battery_voltage.
    cr_power_battery_error_cb_t on_battery_error;
    // on_reset_acknowledged is invoked when LCR receives acknowledgement that the power has been
    // reset in response to cr_power_reset.
    cr_power_acknowledge_cb_t on_reset_acknowledged;
    // on_off_acknowledged is invoked when LCR receives acknowledgement that the power has been
    // turned off in response to cr_power_off.
    cr_power_acknowledge_cb_t on_off_acknowledged;
    // context holds a user specified pointer that will be passed as the first argument to the
    // above callbacks.
    void *context;
} cr_power_event_api_t;

// Allocates the memory for a cr_power_t.
struct cr_power_t *cr_power_alloc(void);

// Initializes a cr_power_t with the specified callbacks and registers the feature with the
// specified cardreader.
cr_power_result_t cr_power_init(struct cr_power_t *power,
                                struct cr_cardreader_t *cardreader,
                                cr_power_event_api_t const *event_api);

// Terminates a cr_power_t, deregistering the feature.
cr_power_result_t cr_power_term(struct cr_power_t *power);

// Frees the memory for a cr_power_t. The cr_power_t must have been previously terminated.
cr_power_result_t cr_power_free(struct cr_power_t *power);

// Retrieves the reader battery voltage. A call will be made (asynchronously) to
// cr_power_event_api_t::on_battery_voltage_received.
cr_power_result_t cr_power_get_battery_voltage(struct cr_power_t *power);

// Requests the reader power be reset. A call will be made (asynchronously) to
// cr_power_event_api_t::on_reset_acknowledged.
cr_power_result_t cr_power_reset(struct cr_power_t *power);

// Requests the reader power be turned off. A call will be made (asynchronously) to
// cr_power_event_api_t::on_off_acknowledged.
cr_power_result_t cr_power_off(struct cr_power_t *power);

// Converts a raw adc value to a voltage value.
float cr_power_convert_adc_value_to_voltage(struct cr_power_t *power, float adc_val);
