//
//  CRFirmwareUpdateFeature_Internal.h
//  SquareReader
//
//  Created by Ken Wigginton on 6/26/17.
//  Copyright (c) 2017 Square, Inc. All rights reserved.
//

#import <cardreader/cr_firmware_update_feature.h>

#import <SquareReader/CRFirmwareUpdateFeature.h>


@interface CRFirmwareUpdateVersionInfoPair ()

- (instancetype)initWithVersionPair:(cr_firmware_update_version_info_pair_t)version_pair;

@end

@interface CRFirmwareUpdateFeature ()

@property (nonatomic, readonly, assign) struct cr_firmware_update_feature_t *firmwareUpdate;

@property (nonatomic, readonly, assign) cr_firmware_update_receive_manifest_cb_t on_receive_manifest_cb;
@property (nonatomic, readonly, assign) cr_firmware_update_progress_cb_t on_progress_cb;
@property (nonatomic, readonly, assign) cr_firmware_update_result_cb_t on_result_cb;
@property (nonatomic, readonly, assign) cr_firmware_update_version_info_cb_t on_version_info_cb;

@end
