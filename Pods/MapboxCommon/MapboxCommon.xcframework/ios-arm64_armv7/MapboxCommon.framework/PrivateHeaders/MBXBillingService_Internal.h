// This file is generated and will be overwritten automatically.

#import <Foundation/Foundation.h>
#import <MapboxCommon/MBXBillingSessionStatus_Internal.h>
#import <MapboxCommon/MBXOnBillingServiceError_Internal.h>
#import <MapboxCommon/MBXSKUIdentifier_Internal.h>

NS_SWIFT_NAME(BillingService)
__attribute__((visibility ("default")))
@interface MBXBillingService : NSObject

// This class provides custom init which should be called
- (nonnull instancetype)init NS_UNAVAILABLE;

// This class provides custom init which should be called
+ (nonnull instancetype)new NS_UNAVAILABLE;

+ (void)triggerBillingEventForAccessToken:(nonnull NSString *)accessToken
                                userAgent:(nonnull NSString *)userAgent
                            skuIdentifier:(MBXSKUIdentifier)skuIdentifier
                                 callback:(nonnull MBXOnBillingServiceError)callback;
+ (void)beginBillingSessionForAccessToken:(nonnull NSString *)accessToken
                                userAgent:(nonnull NSString *)userAgent
                            skuIdentifier:(MBXSKUIdentifier)skuIdentifier
                                 callback:(nonnull MBXOnBillingServiceError)callback
                                 validity:(NSTimeInterval)validity;
+ (void)pauseBillingSessionForSkuIdentifier:(MBXSKUIdentifier)skuIdentifier;
+ (void)resumeBillingSessionForSkuIdentifier:(MBXSKUIdentifier)skuIdentifier
                                    callback:(nonnull MBXOnBillingServiceError)callback;
+ (void)stopBillingSessionForSkuIdentifier:(MBXSKUIdentifier)skuIdentifier;
+ (MBXBillingSessionStatus)getSessionStatusForSkuIdentifier:(MBXSKUIdentifier)skuIdentifier;
+ (nonnull NSString *)getSessionSKUTokenIfValidForSkuIdentifier:(MBXSKUIdentifier)skuIdentifier __attribute((ns_returns_retained));
+ (nonnull NSString *)getUserSKUTokenForSkuIdentifier:(MBXSKUIdentifier)skuIdentifier __attribute((ns_returns_retained));

@end
