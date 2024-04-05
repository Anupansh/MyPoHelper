//
//  SQCCollectionFunctionalAdditions.h
//  SquareCore
//
//  Created by Kyle Van Essen on 2/11/15.
//  Copyright (c) 2015 Square, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

#import <SquareCore/SquareCoreDefines.h>


@protocol SQCCollectionFunctionalAdditions <NSObject>

@required

/**
 Filters the receiver by iterating all contained elements, adding them to the
 returned collection if 'filterBlock' returns YES when passed that object.
 
 Conceptually similar to 'filtered[CollectionType]UsingPredicate:[NSPredicate predicateWithBlock:...'.
 
 @param filterBlock A block used to filter the collection. Returns YES if the passed object should be included, NO otherwise.
 @return A new filtered collection of the same type as the receiver. If no elements passed the 'filterBlock', an empty collection is returned.
 
 @example
 [1, 2, 3, 4, 5].filter({int in return int.isOdd()}) -> [1, 3, 5]
 */
- (instancetype)SQC_filter:(BOOL (^)(id object))filterBlock SQ_NONNULL(1);

/**
 Maps the receiver to another collection by iterating all contained elements, passing each to the provided 'mapBlock'.
 The object returned from 'mapBlock' is then added to a secondary collection, which is returned from the method.

 @param mapBlock A block used to map each element in the collection. Return nil from the 'mapBlock' to skip mapping that element.
 @return A new mapped collection of the same type as the receiver. If no elements were returned by the 'mapBlock', an empty collection is returned.
 
 @example
 [1, 2, 3, 4].map({int in return (int * 2)}) -> [2, 4, 6, 8]
 */
- (id)SQC_map:(id (^)(id object))mapBlock SQ_NONNULL(1);

/**
 Recursively flattens collections contained within the receiver into a single collection, and returns the result.
 
 @return A new flattened collection of the same type as the receiver.
 
 @example
 [1, [2, 3], [[4]], [5], [[[6]]], [[]]].flatten -> [1, 2, 3, 4, 5, 6]
 */
- (instancetype)SQC_flatten;

/**
 Returns YES if any of the elements in the collection pass the 'filterBlock', NO otherwise.

 @param filterBlock A block used to query the collection. Returns YES if the passed in object passes, NO otherwise.
 @return YES if any elements in the collection passed the 'filerBlock', NO otherwise.

 @example
 [1, 2, 3, 4, 5].anyPassing({int in return int == 2}) -> YES
 [1, 2, 3, 4, 5].anyPassing({int in return int == 10}) -> NO
 */
- (BOOL)SQC_anyPassing:(BOOL (^)(id object))filterBlock SQ_NONNULL(1);

/**
 Returns YES if all of the elements in the collection pass the 'filterBlock', NO otherwise.

 @param filterBlock A block used to query the collection. Returns YES if the passed in object passes, NO otherwise.
 @return YES if all elements in the collection passed the 'filerBlock', NO otherwise.

 @example
 [1, 2, 3, 4, 5].allPassing({int in return int < 6}) -> YES
 [1, 2, 3, 4, 5].allPassing({int in return int < 4}) -> NO
 */
- (BOOL)SQC_allPassing:(BOOL (^)(id object))filterBlock SQ_NONNULL(1);

@end


///
/// @name Collections
///


@interface NSArray (SQCCollectionFunctionalAdditions) <SQCCollectionFunctionalAdditions>

- (NSArray *)SQC_map:(id (^)(id object))mapBlock;

@end


@interface NSSet (SQCCollectionFunctionalAdditions) <SQCCollectionFunctionalAdditions>

- (NSSet *)SQC_map:(id (^)(id object))mapBlock;

@end


@interface NSOrderedSet (SQCCollectionFunctionalAdditions) <SQCCollectionFunctionalAdditions>

- (NSOrderedSet *)SQC_map:(id (^)(id object))mapBlock;

@end


@interface NSCountedSet (SQCCollectionFunctionalAdditions) <SQCCollectionFunctionalAdditions>

- (NSCountedSet *)SQC_map:(id (^)(id object))mapBlock;

@end


@interface NSHashTable (SQCCollectionFunctionalAdditions) <SQCCollectionFunctionalAdditions>

- (NSHashTable *)SQC_map:(id (^)(id object))mapBlock;

@end
