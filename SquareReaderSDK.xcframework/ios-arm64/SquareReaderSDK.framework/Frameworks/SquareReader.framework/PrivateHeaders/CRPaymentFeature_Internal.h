//
//  CRPaymentFeature_Internal.h
//  cardreader
//
//  Created by Dave Apgar on 5/11/16.
//  Copyright © 2016 Square, Inc. All rights reserved.
//

#import <cardreader/cr_payment_defines.h>
#import <SquareReader/CRPaymentFeature.h>


typedef NS_ENUM(NSUInteger, CRPaymentInteractionType) {
    CRPaymentInteractionTypeUnknown,
    CRPaymentInteractionTypePayment,
    CRPaymentInteractionTypeRefund,
    CRPaymentInteractionTypeCheckBalance, // TMN + QuicPay-only
    CRPaymentInteractionTypeOnlineTest, // TMN-only
    CRPaymentInteractionTypeMiryo, // TMN
    CRPaymentInteractionTypeVoid // TMN
};


/**
 Convert a C array of cr_payment_timing_t objects to CRPaymentTiming. Exposed for testing.
 @param timings Array of cr_payment_timing_t structs at least timings_count large.
 @param timings_count The number of cr_payment_timing_t structs to convert to CRPaymentTiming objects.
 @return NSArray of CRPaymentTiming objects or nil.
 */
NSArray * _Nullable CRPaymentTimingsFromUnderlyingPaymentTimings(cr_payment_timing_t const * _Nullable timings, size_t timings_count);
crs_tmn_brand_id_t crs_tmn_brand_id_tFromCRTMNBrand(CRTMNBrand brand);
CRTMNUIMessage CRTMNUIMessageFromcrs_tmn_message_t(crs_tmn_message_t message);
CRAudioMessage CRAudioMessageFromcrs_tmn_audio_t(crs_tmn_audio_t message);
CRTMNPaymentResult CRTMNPaymentResultFromtmn_transaction_result_t(tmn_transaction_result_t result);

@interface CREMVPaymentInteraction ()

@property (nonatomic, assign) NSUInteger authorizationAmountCents;
@property (nonatomic, assign) CRPaymentInteractionType type;

@end

@interface CRTMNPaymentInteraction ()

@property (nonatomic, assign) NSUInteger authorizationAmountCents;
@property (nonatomic, assign) CRPaymentInteractionType type;
@property (nonatomic, assign) CRTMNBrand brand;
@property (nonatomic, nullable, copy) NSString *transactionId;
@property (nonatomic, nullable, copy) NSData *miryoData;

@end

@interface CRPaymentFeature ()

@property (nonatomic, null_resettable, readonly, assign) struct cr_payment_t *payment;

@property (nonatomic, readonly, assign) cr_payment_event_api_t event_api;
@property (nonatomic, readonly, assign) cr_payment_cfg_t cfg;

@property (nonatomic, assign, getter=isRequestingCardInfo) BOOL requestingCardInfo;
@property (nonatomic, assign) BOOL receivedAuthRequest;
@property (nonatomic, assign) CRPaymentInteractionType activeInteractionType;

@property (nonatomic, copy, readwrite, nullable) NSUUID *accountSelectionSessionID;

- (void)_cardInfoRequestDidFinishWithAuthData:(nullable NSData *)authData paymentCard:(nullable CRPaymentCard *)paymentCard entryType:(CRPaymentFeatureCardEntryType)entryType errorCode:(CRPaymentCardInfoRequestErrorCode)errorCode;

@end
