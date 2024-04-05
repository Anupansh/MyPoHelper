//
//  CRPaymentApplication.h
//  cardreader
//
//  Created by Tamir Duberstein on 11/14/14.
//  Copyright (c) 2014 Square, Inc. All rights reserved.
//

/// PaymentApplication is the EMV term for a Payment Account. That is, instances
/// of this class are accounts which can be charged.

#import <Foundation/Foundation.h>


@interface CRPaymentApplication : NSObject

/// Bytes should be displayed on receipt.
@property (nonatomic, readonly, copy) NSData *definitionFilename;

/// Used for receipts and displaying to user when selection is required.
@property (nonatomic, readonly, copy) NSString *label;

@property (nonatomic, readonly, copy) NSString *preferredName;

@end
