//
//  LCREventlogFeature_Internal.h
//  cardreader
//
//  Created by Martin Mroz on 2/18/15.
//  Copyright (c) 2015 Square, Inc. All rights reserved.
//

#import "CREventlogFeature.h"

#import <cardreader/cr_eventlog_feature.h>


@interface CREventlogFeature ()

@property (nonatomic, readonly, assign) struct cr_eventlog_t *eventlog;

@property (nonatomic, assign, readonly) cr_eventlog_data_cb_t on_data_received_cb;
@property (nonatomic, assign, readonly) cr_eventlog_profile_cb_t on_profile_received_cb;

@end
