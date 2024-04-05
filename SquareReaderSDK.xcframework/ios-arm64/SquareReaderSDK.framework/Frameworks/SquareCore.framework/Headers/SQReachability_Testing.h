//
//  SQReachability_Testing.h
//  SquareCore
//
//  Created by Kyle Van Essen on 5/1/14.
//  Copyright (c) 2014 Square, Inc. All rights reserved.
//

#import <SquareCore/SQReachability.h>
#import <SystemConfiguration/SystemConfiguration.h>


@interface SQReachability ()

@property (atomic, assign, readonly, getter=isListeningForNetworkChanges) BOOL listeningForNetworkChanges;

@property (atomic, assign, readonly) SCNetworkReachabilityRef reachabilityRef;

- (void)_updateInternetConnectionStatusWithReachabilityFlags:(SCNetworkReachabilityFlags)flags;

@end


void SQReachabilityCallback(SCNetworkReachabilityRef target, SCNetworkReachabilityFlags flags, void *info);

SQReachabilityStatus SQReachabilityStatusForFlags(SCNetworkReachabilityFlags flags);
