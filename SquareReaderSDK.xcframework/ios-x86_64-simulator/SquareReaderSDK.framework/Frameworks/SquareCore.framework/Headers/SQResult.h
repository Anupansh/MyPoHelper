//
//  SQResult.h
//  SquareCore
//
//  Created by Zachary Drayer on 11/12/18.
//  Copyright © 2018 Square. All rights reserved.
//

#import <Foundation/Foundation.h>

#import <SquareCore/SquareCoreDefines.h>

SQ_FINAL
@interface SQResult<__covariant Value, __covariant Error>: NSObject

- (nonnull instancetype)init NS_UNAVAILABLE;
+ (nonnull instancetype) new NS_UNAVAILABLE;

- (nonnull instancetype)initWithValue:(nonnull const Value)value NS_DESIGNATED_INITIALIZER;
- (nonnull instancetype)initWithError:(nonnull const Error)error NS_DESIGNATED_INITIALIZER;

- (void)matchValue:(void (^_Nonnull)(Value _Nonnull const))valueBlock
             error:(void (^_Nonnull)(Error _Nonnull const))errorBlock NS_SWIFT_NAME(match(value:error:));

@property (nullable, nonatomic, strong, readonly) Value value;
@property (nullable, nonatomic, strong, readonly) Error error;

@property (nonatomic, assign, readonly, getter=isSuccess) BOOL success;
@property (nonatomic, assign, readonly, getter=isFailure) BOOL failure;

@end
