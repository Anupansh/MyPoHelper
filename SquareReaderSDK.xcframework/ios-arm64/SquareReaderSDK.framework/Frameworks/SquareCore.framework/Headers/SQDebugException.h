//
//  SQDebugException.h
//  SquareCore
//
//  Created by Kyle Van Essen on 5/8/14.
//  Copyright (c) 2014 Square, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

#import <SquareCore/SQDebugAssertionConfiguration.h>

///
/// @name Functions
///

/// Set a breakpoint on this function to catch debug assertions.
static inline void SQDebugAssertionFired(void) {}


///
/// @name Notifications
///

/**
 Posted when a debug exception occurs.
 
 Note:
    - The notification is posted on the thread of the exception.
    - The object of the notification is the instance of SQDebugException which occurred.
 */
extern NSString *const SQDebugExceptionWasRaisedNotification;


@interface SQDebugException : NSObject

///
/// @name Initialization
///

/**
 This is subsumed by the initializer with the context paramater. All macros have been updated to use that one.
 */
- (instancetype)initWithConditionString:(NSString *)conditionString
                                message:(NSString *)message
                           functionName:(const char *)functionName
                                 object:(id)object
                               selector:(SEL)selector;

- (instancetype)initWithConditionString:(NSString *)conditionString
                                message:(NSString *)message
                                context:(NSString *)context
                           functionName:(const char *)functionName
                                 object:(id)object
                               selector:(SEL)selector;

///
/// @name Assertion Data
///

/**
 The condition string which resulted in the failure.
 
 Example:
    In SQDebugAssert(oneVar == anotherVar, @"Values should be equal."), the condition string is @"oneVar == anotherVar".
 */
@property (nonatomic, copy, readonly) NSString *conditionString;
/**
 The message passed to the receiver.

 Example:
    In SQDebugAssert(oneVar == anotherVar, @"Values should be equal."), the message is @"Values should be equal.".
 */
@property (nonatomic, copy, readonly) NSString *message;

/// Additional context to include when logging this message.
@property (nonatomic, copy, readonly) NSString *context;


/// The function that the receiver occurred in. Nil if the exception occurred in an Objective-C method.
@property (nonatomic, copy, readonly) NSString *functionName;

/// The object that the receiver occurred in. Nil if the exception occurred in a C function.
@property (nonatomic, strong, readonly) id object;
/// The selector of the method that the receiver occurred in. Nil if the exception occurred in a C function.
@property (nonatomic, assign, readonly) SEL selector;


///
/// @name Additional Information
///

/// The assertion mode in which the receiver was triggered.
@property (nonatomic, assign, readonly) SQDebugAssertionMode assertionMode;

///
/// @name Posting Debug Exceptions
///

/// Posts a notification (on the current thread) for observers of SQDebugExceptionWasRaisedNotification.
- (void)postNotification;

@end
