//  Copyright (c) 2013-2016 Square Inc. All rights reserved.

#import "MSWLogger.h"


@interface MSWLogger ()

- (void)delayUntilValidTicket:(NSTimeInterval)timeout completionOnMainQueue:(void (^)(void))completion;

@end
