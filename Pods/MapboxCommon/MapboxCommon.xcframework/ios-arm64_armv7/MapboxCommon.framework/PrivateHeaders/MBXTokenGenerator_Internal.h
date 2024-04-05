// This file is generated and will be overwritten automatically.

#import <Foundation/Foundation.h>
#import <MapboxCommon/MBXSKUIdentifier_Internal.h>

NS_SWIFT_NAME(TokenGenerator)
__attribute__((visibility ("default")))
@interface MBXTokenGenerator : NSObject

// This class provides custom init which should be called
- (nonnull instancetype)init NS_UNAVAILABLE;

// This class provides custom init which should be called
+ (nonnull instancetype)new NS_UNAVAILABLE;

+ (nonnull NSString *)getSKUTokenForIdentifier:(MBXSKUIdentifier)identifier __attribute((ns_returns_retained)) __attribute__((deprecated));
+ (nonnull NSString *)getSessionSKUTokenForIdentifier:(MBXSKUIdentifier)identifier
                                             validity:(NSTimeInterval)validity __attribute((ns_returns_retained)) __attribute__((deprecated));
+ (nonnull NSString *)generateSessionSKUTokenForIdentifier:(MBXSKUIdentifier)identifier
                                                  validity:(NSTimeInterval)validity __attribute((ns_returns_retained)) __attribute__((deprecated));
+ (nonnull NSString *)getSKUTokenIfValidForIdentifier:(MBXSKUIdentifier)identifier __attribute((ns_returns_retained)) __attribute__((deprecated));

@end
