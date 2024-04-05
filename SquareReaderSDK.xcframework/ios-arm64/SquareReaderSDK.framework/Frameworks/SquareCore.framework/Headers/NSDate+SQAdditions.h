//
//  NSDate+SQAdditions.h
//  SquareCore
//
//  Created by Kyle Van Essen on 5/1/14.
//  Copyright (c) 2014 Square, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface NSDate (SQAdditions)

///
/// @name Comparison
///

/// @return YES if the receiver is greater than `date`.
- (BOOL)SQ_isGreaterThan:(NSDate *)date;

/// @return YES if the receiver is greater than or equal to `date`.
- (BOOL)SQ_isGreaterThanOrEqualTo:(NSDate *)date;

/// @return YES if the receiver is equal to `date`.
- (BOOL)SQ_isOrderedSame:(NSDate *)date;

/// @return YES if the receiver is less than `date`.
- (BOOL)SQ_isLessThan:(NSDate *)date;

/// @return YES if the receiver is less than or equal to `date`.
- (BOOL)SQ_isLessThanOrEqualTo:(NSDate *)date;

@end
