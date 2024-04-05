//
//  CRPaymentCard+CPCPaymentCard.h
//  Pods
//
//  Created by Zachary Drayer on 2/23/18.
//
//

#import <CorePaymentCard/CorePaymentCard.h>

@class CRPaymentCard;


@interface CPCPaymentCard (CRPaymentCardSupport)

- (void)populateWithPaymentCard:(CRPaymentCard *_Nonnull)paymentCard;

@end
