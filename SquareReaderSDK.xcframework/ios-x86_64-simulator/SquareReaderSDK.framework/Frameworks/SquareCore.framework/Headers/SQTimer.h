//
//  SQTimer.h
//  SquareCore
//
//  Created by Kyle Van Essen on 10/18/14.
//  Copyright (c) 2014 Square, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

#import <SquareCore/SquareCoreDefines.h>


/**
 SQTimer provides an NSTimer-like interface for a repeating or single use timer object.

 SQTimer behaves differently than NSTimer:
 - It does not retain its target.
 - It will automatically stop running when its target has been deallocated.
 - It may be repeatedly stopped and started.
 */
@interface SQTimer : NSObject

///
/// @name Creating Timers
///

/**
 Creates and returns a new timer configured with the provided settings.
 
 @note
 The timer is not scheduled. You need to call start to begin its execution.
 
 @param timeInterval The time interval at which to fire the timer. Must be > 0.0.
 @param target The target of the timer. Must be non-nil.
 @param action The selector on the target which should be invoked when the timer fires. Must be non-NULL.
 @param repeats YES if the timer should repeat, NO otherwise.
 
 @return A newly configured timer.
 */
- (nonnull instancetype)initWithTimeInterval:(NSTimeInterval)timeInterval
                                      target:(nonnull id)target
                                      action:(nonnull SEL)action
                                     repeats:(BOOL)repeats;

/**
 Creates and returns a new timer configured with the provided settings.
 
 @note
 The timer is not scheduled. You need to call start to begin its execution.
 
 @see
 See -initWithTimeInterval:target:action:repeats: for a full discussion of the available parameters.
 */
+ (nonnull instancetype)timerWithTimeInterval:(NSTimeInterval)timeInterval
                                       target:(nonnull id)target
                                       action:(nonnull SEL)action
                                      repeats:(BOOL)repeats;

/**
 Creates and returns a new scheduled timer configured with the provided settings.
 
 @note
 Since the timer is scheduled, its execution begins automatically. You do not need to call start.

 @see
 See -initWithTimeInterval:target:action:repeats: for a full discussion of the available parameters.
 */
+ (nonnull instancetype)scheduledTimerWithTimeInterval:(NSTimeInterval)timeInterval
                                                target:(nonnull id)target
                                                action:(nonnull SEL)action
                                               repeats:(BOOL)repeats;

/// Initializes a new NSTimer object using the block as the main body of execution for the timer. This timer needs to be scheduled on a run loop (via -[NSRunLoop addTimer:]) before it will fire.
/// - parameter:  fireDate   The time at which the timer should first fire.
/// - parameter:  interval  The number of seconds between firings of the timer. If seconds is less than or equal to 0.0, this method chooses the nonnegative value of 0.1 milliseconds instead
/// - parameter:  target  The receiver of a message that is sent when the timer fires
/// - parameter:  selector  The action to send to the target when the timer fires
/// - parameter:  userInfo  An arbitrary dictionary to preserve for the lifetime of a timer
/// - parameter:  repeats  If YES, the timer will repeatedly reschedule itself until invalidated. If NO, the timer will be invalidated after it fires.
- (nonnull instancetype)initWithFireDate:(nullable NSDate *)date
                                interval:(NSTimeInterval)ti
                                  target:(nonnull id)target
                                selector:(nonnull SEL)action
                                userInfo:(nullable id)userInfo
                                 repeats:(BOOL)repeats NS_DESIGNATED_INITIALIZER;

- (nonnull instancetype)init NS_UNAVAILABLE;
+ (nonnull instancetype) new NS_UNAVAILABLE;

///
/// @name Timer Configuration
///

/// The time interval (in seconds) at which the timer fires.
@property (nonatomic, assign, readonly) NSTimeInterval timeInterval;
/// YES if the timer repeats after firing, NO otherwise.
@property (nonatomic, assign, readonly) BOOL repeats;

/// The target of the timer. This value is not retained by the timer.
@property (nullable, nonatomic, weak, readonly) id target;
/// The selector which is invoked when the timer fires.
@property (nonnull, nonatomic, assign, readonly) SEL action;

/// The target fire date of the timer.
@property (nullable, nonatomic, copy, readonly) NSDate *fireDate;
/// An arbitrary dictionary of data to retain for the timer.
@property (nullable, nonatomic, strong, readonly) id userInfo;

///
/// @name Running Timers
///

/// YES if the timer is currently running, NO otherwise.
@property (nonatomic, assign, readonly, getter=isRunning) BOOL running;

/// Starts the timer on the current runloop. This method may be re-invoked on a timer which has previously stopped to restart it.
- (void)start;

/// Starts the timer on the provided runloop. This method may be re-invoked on a timer which has previously stopped to restart it.
- (void)startOnRunloop:(nonnull NSRunLoop *)runLoop;

/// Stops the timer. After invoking this method, you may call start to restart the timer.
- (void)stop;

/**
 Fires the timer if it is currently running.
 
 You can use this method to fire a repeating timer without interrupting its regular firing schedule.
 If the timer is non-repeating, it is automatically invalidated after firing, even if its scheduled fire date has not arrived.
 */
- (void)fire;

@end


@interface SQTimer (Unavailable)

+ (nonnull instancetype) new SQ_UNAVAILABLE("Unavailable. Please use -initWithTimeInterval:target:action:repeats:.");

- (nonnull instancetype)init SQ_UNAVAILABLE("Unavailable. Please use +timerWithTimeInterval:target:action:repeats:.");

@end
