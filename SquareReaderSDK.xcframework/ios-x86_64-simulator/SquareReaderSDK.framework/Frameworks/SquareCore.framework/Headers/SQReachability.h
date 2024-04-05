//
//  SQReachability.h
//  SquareCore
//
//  Created by Tristan O'Tierney on 2/18/09.
//  Copyright 2008 Square, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

#import <SquareCore/SquareCoreDefines.h>


typedef NS_ENUM(NSUInteger, SQReachabilityStatus) {
    /// The device is not connected to any network.
    SQReachabilityStatusNotReachable = 0,
    /// The device is connected to WiFi, or ethernet (Mac only).
    SQReachabilityStatusViaWiFi = 1,
#if SQUARECORE_IOS
    /// The device is connected to a celluar network: EDGE, 3G, 4G, LTE, etc (iOS only).
    SQReachabilityStatusViaCarrier = 2,
#endif
};

/// Indicates when the reachability of the device changes. Always delivered to the main queue.
extern NSString *const SQReachabilityDidChangeNotification;

/// Posted within SQReachabilityDidChangeNotification's userInfo. Contains the current connection status.
extern NSString *const SQReachabilityStatusKey;
/// Posted within SQReachabilityDidChangeNotification's userInfo. Contains the previous connection status.
extern NSString *const SQReachabilityPreviousStatusKey;
/// Posted within SQReachabilityDidChangeNotification's userInfo if the device connected to the internet.
extern NSString *const SQReachabilityDidConnectKey;
/// Posted within SQReachabilityDidChangeNotification's userInfo if the device disconnected from the internet.
extern NSString *const SQReachabilityDidDisconnectKey;


@interface SQReachability : NSObject

/// The current connection status of the device.
@property (atomic, assign, readonly) SQReachabilityStatus internetConnectionStatus;

/// @return YES if the device is connected to the internet. NO otherwise.
@property (nonatomic, assign, readonly, getter=isConnectedToInternet) BOOL connectedToInternet;

/// The shared reachability instance.
+ (SQReachability *)sharedReachability;

@end
