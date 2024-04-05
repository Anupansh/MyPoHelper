//
//  NSDictionary+SQCAdditions.h
//  SquareCore
//
//  Created by Kyle Van Essen on 4/27/15.
//  Copyright (c) 2015 Square, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

#import <SquareCore/SquareCoreDefines.h>


@interface NSDictionary (SQCAdditions)

/**
 Returns the value associated with a given key, restricted to the provided objectClass.

 @param key
 Required. The key for which to return the corresponding value.
 
 @param objectClass
 Required. The class of the key's corresponding value.
 If the value is not this class or a subclass, nil is returned.
 
 @return The value associated with key, or nil if no value is associated with key or the value's class is not objectClass.
 */
- (id)SQC_objectForKey:(id)key objectClass:(Class)objectClass SQ_NONNULL(2);

@end
