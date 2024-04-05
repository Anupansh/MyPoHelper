//
//  NSObject+SQCSelectorAdditions.h
//  SquareCore
//
//  Created by Kyle Van Essen on 10/18/14.
//  Copyright (c) 2014 Square, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

#import <SquareCore/SquareCoreDefines.h>


@interface NSObject (SQCCachingAdditions)

///
/// @name Caching Method Results
///

/**
 The cached result of performing the provided selector on the receiver.
 
 If the selector has been previously invoked via SQC_cachedPerformSelector, the cached result
 will be returned. Eg, the original implementation will only be called once.
 
 This method is threadsafe.
 
 @discussion
 This method is useful if you need a simple layer of caching around a stateless method. For example,
 to cache the result of a call to a 'keysPathsForValuesAffecting...' style method.
 
 @param selector The selector which should be performed.
 @return The cached result of the method invocation.
 */
+ (id)SQC_cachedPerformSelector:(SEL)selector SQ_NONNULL(1);

/**
 The cached result of performing the provided selector on the receiver.
 
 If the selector has been previously invoked via SQC_cachedPerformSelector, the cached result
 will be returned. Eg, the original implementation will only be called once.
 
 This method is threadsafe.
 
 @discussion
 This method is useful if you need a simple layer of caching around a stateless method. For example,
 to cache the result of a call to a 'keysPathsForValuesAffecting...' style method.
 
 @param selector The selector which should be performed.
 @return The cached result of the method invocation.
 */
- (id)SQC_cachedPerformSelector:(SEL)selector SQ_NONNULL(1);

@end


@interface NSObject (SQCARCSelectorAdditions)

///
/// @name Perform Returns Void Selector
///

/**
 Performs the provided selector on the receiver.
 */
- (void)SQC_performVoidSelector:(SEL)aSelector SQ_NONNULL(1);

/**
 Performs the provided selector on the receiver, passing it the provided object as the argument.
 */
- (void)SQC_performVoidSelector:(SEL)aSelector withObject:(id)object SQ_NONNULL(1);

/**
 Performs the provided selector on the receiver, passing it the provided objects as the arguments.
 */
- (void)SQC_performVoidSelector:(SEL)aSelector withObject:(id)object1 withObject:(id)object2 SQ_NONNULL(1);

///
/// @name Perform Returns Autoreleased Selector
///

/**
 Performs the provided selector on the receiver.
 The method should return void or an autoreleased object.
 */
- (id)SQC_performReturnsAutoreleasedSelector:(SEL)aSelector SQ_NONNULL(1);

/**
 Performs the provided selector on the receiver, passing it the provided object as the argument.
 The method should return void or an autoreleased object.
 */
- (id)SQC_performReturnsAutoreleasedSelector:(SEL)aSelector withObject:(id)object SQ_NONNULL(1);

/**
 Performs the provided selector on the receiver, passing it the provided objects as the arguments.
 The method should return void or an autoreleased object.
 */
- (id)SQC_performReturnsAutoreleasedSelector:(SEL)aSelector withObject:(id)object1 withObject:(id)object2 SQ_NONNULL(1);

///
/// @name Perform Returns Retained Selector
///

/**
 Performs the provided selector on the receiver.
 The method should return void or a retained object.
 */
- (id)SQC_performReturnsRetainedSelector:(SEL)aSelector NS_RETURNS_RETAINED SQ_NONNULL(1);

/**
 Performs the provided selector on the receiver, passing it the provided object as the argument.
 The method should return void or an retained object.
 */
- (id)SQC_performReturnsRetainedSelector:(SEL)aSelector withObject:(id)object NS_RETURNS_RETAINED SQ_NONNULL(1);

/**
 Performs the provided selector on the receiver, passing it the provided objects as the arguments.
 The method should return void or an retained object.
 */
- (id)SQC_performReturnsRetainedSelector:(SEL)aSelector withObject:(id)object1 withObject:(id)object2 NS_RETURNS_RETAINED SQ_NONNULL(1);

@end


@interface NSObject (SQCARCDeprecationAdditions)

///
/// @name ARC-Deprecated Methods
///

/// Deprecated; the ARC compiler does not know the memory management semantics of the selector.
- (id)performSelector:(SEL)aSelector SQ_DEPRECATED("Deprecated under ARC. Use methods available in SQCARCSelectorAdditions.");

/// Deprecated; the ARC compiler does not know the memory management semantics of the selector.
- (id)performSelector:(SEL)aSelector withObject:(id)object SQ_DEPRECATED("Deprecated under ARC. Use methods available in SQCARCSelectorAdditions.");

/// Deprecated; the ARC compiler does not know the memory management semantics of the selector.
- (id)performSelector:(SEL)aSelector withObject:(id)object1 withObject:(id)object2 SQ_DEPRECATED("Deprecated under ARC. Use methods available in SQCARCSelectorAdditions.");

@end
