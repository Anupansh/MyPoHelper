//
//  NSObject+SQCSwizzlingAdditions.h
//  SquareCore
//
//  Created by Eric Firestone on 8/26/14.
//  Copyright (c) 2014 Square, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface NSObject (SQCSwizzlingAdditions)

///
/// @name Swizzling Methods
///

+ (void)SQ_swizzleInstanceSelector:(SEL)firstSelector toSelector:(SEL)secondSelector;
+ (void)SQ_swizzleClassSelector:(SEL)firstSelector toSelector:(SEL)secondSelector;

@end
