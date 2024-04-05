//
//  SQDebugAssertionConfiguration.h
//  SquareCore
//
//  Created by Kyle Van Essen on 5/6/14.
//  Copyright (c) 2014 Square, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>


/**
 The assertion mode used for debug exceptions.
 
 Note:
    All modes post a SQDebugExceptionWasRaisedNotification.
 */
typedef NS_ENUM(NSUInteger, SQDebugAssertionMode) {
    /// Debug assertions will throw a caught exception. This needs to be set explicitly by calling
    /// `setAssertionMode` if the application is consuming SquareCore as a pre-built dependency.
    SQDebugAssertionModeDebugBuild = 1,

    /// Debug assertions will log to the system console.
    SQDebugAssertionModeReleaseBuild,

    /// Debug assertions will cause the tests to fail if not expected.
    SQDebugAssertionModeXCTestEnvironment,
};


@interface SQDebugAssertionConfiguration : NSObject

+ (instancetype)sharedInstance;

///
/// @name Environment
///

/// @return YES if running inside an XCTest environment. NO otherwise.
+ (BOOL)isInXCTestEnvironment;
/// @return YES if the `DEBUG` flag is set. NO otherwise.
+ (BOOL)isInDebugEnvironment;

/**
 The current assertion mode.

 Note:
    Setting to an invalid value for the current environment will reset it back to the default value.
 */
@property (nonatomic, assign) SQDebugAssertionMode assertionMode;

/// Resets `assertionMode` back to the default for the current environment.
- (void)resetAssertionMode;

///
/// @name Measuring Assertions
///

+ (void)debugAssertionFired;

/// The current count of debug assertions that have occurred on this thread.
+ (NSUInteger)debugAssertionCountForCurrentThread;

///
/// @name Expecting Assertions
///

/// Invoked by testing macros when they begin expecting a debug assertion.
+ (void)startExpectingDebugAssertion;
/// Invoked by testing macros when they stop expecting a debug assertion.
+ (void)stopExpectingDebugAssertion;

/// @return YES if a debug assertion is expected to be fired. NO otherwise.
+ (BOOL)isExpectingDebugAssertionOnCurrentThread;

@end
