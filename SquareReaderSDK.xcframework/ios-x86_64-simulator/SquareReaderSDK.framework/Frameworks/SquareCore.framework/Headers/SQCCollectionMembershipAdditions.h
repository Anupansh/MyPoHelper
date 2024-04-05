//
//  SQCCollectionAdditions.h
//  SquareCore
//
//  Created by Kyle Van Essen on 5/18/12.
//  Copyright (c) 2012 Square Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

#import <SquareCore/SquareCoreDefines.h>


@protocol SQCCollectionMembershipAdditions <NSObject>

@required

/// @return YES if the collection contains an object whose -valueForKey: method returns `value`.
- (BOOL)SQC_containsObjectWithValue:(id)value forKeyPath:(NSString *)keyPath SQ_NONNULL(2);

/// @return The first object in the collection whose -valueForKey: method returns `value`.
- (id)SQC_anyObjectWithValue:(id)value forKeyPath:(NSString *)keyPath SQ_NONNULL(2);

@end


///
/// @name Flat Collections
///


@interface NSArray (SQCCollectionMembershipAdditions) <SQCCollectionMembershipAdditions>
@end


@interface NSSet (SQCCollectionMembershipAdditions) <SQCCollectionMembershipAdditions>
@end


@interface NSOrderedSet (SQCCollectionMembershipAdditions) <SQCCollectionMembershipAdditions>
@end


@interface NSHashTable (SQCCollectionMembershipAdditions) <SQCCollectionMembershipAdditions>
@end


///
/// @name Key/Value Collections
///


@interface NSDictionary (SQCCollectionMembershipAdditions) <SQCCollectionMembershipAdditions>
@end


@interface NSMapTable (SQCCollectionMembershipAdditions) <SQCCollectionMembershipAdditions>
@end
