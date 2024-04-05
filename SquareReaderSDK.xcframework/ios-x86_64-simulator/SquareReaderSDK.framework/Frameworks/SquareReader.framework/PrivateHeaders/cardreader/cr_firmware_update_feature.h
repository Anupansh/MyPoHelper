// Copyright (c) 2014 Square, Inc. All rights reserved.

#pragma once

#include <cardreader_shared/crs_pack.h>
#include <cardreader_shared/crs_fwup_msgs.h>

#include <stdint.h>
#include <stddef.h>
#include <stdbool.h>

struct cr_firmware_update_feature_t;
struct cr_cardreader_t;

// Possible result codes for cr_firmware_update_* functions.
typedef enum
{
    CR_FIRMWARE_UPDATE_FEATURE_RESULT_SUCCESS = 0,
    CR_FIRMWARE_UPDATE_FEATURE_RESULT_ERROR,
    CR_FIRMWARE_UPDATE_FEATURE_RESULT_INVALID_PARAMETER,
    CR_FIRMWARE_UPDATE_FEATURE_RESULT_MISSING_MANIFEST,
    CR_FIRMWARE_UPDATE_FEATURE_RESULT_SESSION_ERROR,
    CR_FIRMWARE_UPDATE_FEATURE_RESULT_NOT_INITIALIZED,
    CR_FIRMWARE_UPDATE_FEATURE_RESULT_ALREADY_TERMINATED,
    CR_FIRMWARE_UPDATE_FEATURE_RESULT_CALL_UNEXPECTED,
} cr_firmware_update_feature_result_t;

// A version info pair contains a human readable name and version number for a reader
// firmware component. For example { .name="K21", .version="1.2.3" }.

typedef enum {
    CR_FIRMWARE_UPDATE_VERSION_INFO_K21 = 0,
    CR_FIRMWARE_UPDATE_VERSION_INFO_K400_CPU0,
    CR_FIRMWARE_UPDATE_VERSION_INFO_K400_CPU1,
    CR_FIRMWARE_UPDATE_VERSION_INFO_BLE,
    CR_FIRMWARE_UPDATE_VERSION_INFO_TMS,
    CR_FIRMWARE_UPDATE_VERSION_INFO_CAPKS,
    CR_FIRMWARE_UPDATE_VERSION_INFO_TMS_CAPKS,
    CR_FIRMWARE_UPDATE_VERSION_INFO_FPGA,
    CR_FIRMWARE_UPDATE_VERSION_INFO_K450_CPU0,
    CR_FIRMWARE_UPDATE_VERSION_INFO_K450_CPU1
} cr_firmware_update_version_info_t;

typedef struct {
    cr_firmware_update_version_info_t name;
    char version[16];
} cr_firmware_update_version_info_pair_t;

// on_receive_manifest is invoked when LCR receives a firmware manifest from the reader in
// response to cr_firmware_update_feature_get_manifest. If required_update is set, this
// indicates the reader requires an update to proceed.
typedef void (*cr_firmware_update_receive_manifest_cb_t)(void *context,
                                                         struct cr_firmware_update_feature_t *firmware_update,
                                                         void const *manifest,
                                                         size_t manifest_len,
                                                         bool required_update,
                                                         cr_firmware_update_feature_result_t result);

// on_progress is invoked 1 or more times when LCR is sending a firmware image in response to
// cr_firmware_update_feature_send_data.
typedef void (*cr_firmware_update_progress_cb_t)(void *context,
                                                 struct cr_firmware_update_feature_t *firmware_update,
                                                 int completion_percentage);

// on_result is invoked when LCR completes sending a firmware image in response to
// cr_firmware_update_feature_send_data.
typedef void (*cr_firmware_update_result_cb_t)(void *context,
                                               struct cr_firmware_update_feature_t *firmware_update,
                                               crs_fwup_result_t result);

// on_version_info is invoked when LCR has human readable version info to present (after receiving
// a manifest from the reader).
typedef void (*cr_firmware_update_version_info_cb_t)(void *context,
                                                     struct cr_firmware_update_feature_t *firmware_update,
                                                     cr_firmware_update_version_info_pair_t *infos,
                                                     size_t infos_count);

// on_tms_country is invoked when LCR has a tms country code in response to the country code being present
typedef void (*cr_firmware_update_tms_country_cb_t)(void *context,
                                               struct cr_firmware_update_feature_t *firmware_update,
                                               char* country_code);

typedef struct cr_firmware_update_feature_event_api_t
{
    cr_firmware_update_receive_manifest_cb_t on_receive_manifest;
    cr_firmware_update_progress_cb_t on_progress;
    cr_firmware_update_result_cb_t on_result;
    cr_firmware_update_version_info_cb_t on_version_info;
    cr_firmware_update_tms_country_cb_t on_tms_country;
    // context holds a user specified pointer that will be passed as the first argument to the
    // above callbacks.
    void *context;
} cr_firmware_update_feature_event_api_t;

// Allocates the memory for a cr_firmware_update_feature_t.
struct cr_firmware_update_feature_t *cr_firmware_update_feature_alloc(void);

// Initializes a cr_firmware_update_feature_t with the specified callbacks and registers the
// feature with the specified cardreader.
cr_firmware_update_feature_result_t cr_firmware_update_feature_init(struct cr_firmware_update_feature_t *firmware_update,
                                                                    struct cr_cardreader_t *cardreader,
                                                                    cr_firmware_update_feature_event_api_t const *api);

// Terminates a cr_firmware_update_feature_t, deregistering the feature.
cr_firmware_update_feature_result_t cr_firmware_update_feature_term(struct cr_firmware_update_feature_t *firmware_update);

// Frees the memory for a cr_firmware_update_feature_t. The cr_firmware_update_feature_t must have
// been previously terminated.
cr_firmware_update_feature_result_t cr_firmware_update_feature_free(struct cr_firmware_update_feature_t *firmware_update);

// Retrieves the firmware manifest. A call will be made (asynchronously) to
// cr_firmware_update_feature_event_api_t::on_receive_manifest.
cr_firmware_update_feature_result_t cr_firmware_update_feature_get_manifest(struct cr_firmware_update_feature_t *firmware_update);

// Retrieves the firmware manifest with a reader signature. A call will be made (asynchronously) to
// cr_firmware_update_feature_event_api_t::on_receive_manifest. For older firmwares that do not support
// signed manifests, LCR will construct a signed manifest proto for the reader's response (the signature
// fields will be omitted from the proto in this case).
cr_firmware_update_feature_result_t cr_firmware_update_feature_get_manifest_v2(struct cr_firmware_update_feature_t *firmware_update);

// Send a firmware image to the reader. Progress is reported via (asynchronous) calls to
// cr_firmware_update_feature_event_api_t::on_progress which will be called 1 or more times, after
// which a call to cr_firmware_update_feature_event_api_t::on_result will be made. The firmware
// image contained in data is buffered in memory and trickled out to the reader. If sending of the
// firmware image is interrupted (e.g. by a process crash) it can be restarted by sending the same
// data again when the process restarts.
//
// The contents of the header and data are intended to be opaque for callers.  The header indicates
// the type of the update, the slot, the length, etc.  The data is an encrypted blob.  Both are
// sent down by Tarkin in response to the reader's current firmware manifest.
cr_firmware_update_feature_result_t cr_firmware_update_feature_send_data(struct cr_firmware_update_feature_t *firmware_update,
        uint8_t *header, size_t header_length, uint8_t *data, size_t data_length,
        uint8_t *block_index_table, size_t block_index_table_length);

// Quit the current update. To resume the update, make another call to
// cr_firmware_update_feature_send_data with the same parameters.
cr_firmware_update_feature_result_t cr_firmware_update_feature_stop_sending_data(struct cr_firmware_update_feature_t *firmware_update);
