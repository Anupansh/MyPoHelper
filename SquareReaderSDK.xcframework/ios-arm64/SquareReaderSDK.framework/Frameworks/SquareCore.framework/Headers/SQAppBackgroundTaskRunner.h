//
//  SQAppBackgroundTaskRunner.h
//  SquareCore
//
//  Created by Nitish Bhayana on 12/16/20.
//


#if SQUARECORE_IOS
#import <UIKit/UIApplication.h>
#elif SQUARECORE_MAC
#import <AppKit/NSApplication.h>
#endif


// Implementation agnostic protocol.
// Useful for mocking.
@protocol SQAppBackgroundTaskRunner <NSObject>

- (UIBackgroundTaskIdentifier)beginBackgroundTaskWithName:(NSString *)taskName expirationHandler:(void (^)(void))handler;

- (void)endBackgroundTask:(UIBackgroundTaskIdentifier)identifier;

@end


// Default, UIApplication based implementation.
@interface SQAppBackgroundTaskRunner : NSObject <SQAppBackgroundTaskRunner>

+ (instancetype)backgroundTaskRunner;

- (instancetype)init NS_UNAVAILABLE;
- (instancetype)initWithUIApplication:(UIApplication *)app;

@property (nonatomic, strong, readonly) UIApplication *app;

@end

