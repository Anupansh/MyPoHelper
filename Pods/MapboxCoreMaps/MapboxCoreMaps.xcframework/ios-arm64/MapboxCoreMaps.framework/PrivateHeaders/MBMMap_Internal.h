// This file is generated and will be overwritten automatically.

#import <MapboxCoreMaps/MBMMap.h>
#import <MapboxCoreMaps/MBMAsyncOperationResultCallback_Internal.h>
#import <MapboxCoreMaps/MBMQueryFeatureExtensionCallback_Internal.h>
#import <MapboxCoreMaps/MBMQueryFeatureStateCallback_Internal.h>
#import <MapboxCoreMaps/MBMQueryFeaturesCallback_Internal.h>

@interface MBMMap ()
- (void)queryRenderedFeaturesForShape:(nonnull NSArray<MBMScreenCoordinate *> *)shape
                              options:(nonnull MBMRenderedQueryOptions *)options
                             callback:(nonnull MBMQueryFeaturesCallback)callback;
- (void)queryRenderedFeaturesForBox:(nonnull MBMScreenBox *)box
                            options:(nonnull MBMRenderedQueryOptions *)options
                           callback:(nonnull MBMQueryFeaturesCallback)callback;
- (void)queryRenderedFeaturesForPixel:(nonnull MBMScreenCoordinate *)pixel
                              options:(nonnull MBMRenderedQueryOptions *)options
                             callback:(nonnull MBMQueryFeaturesCallback)callback;
- (void)querySourceFeaturesForSourceId:(nonnull NSString *)sourceId
                               options:(nonnull MBMSourceQueryOptions *)options
                              callback:(nonnull MBMQueryFeaturesCallback)callback;
- (void)queryFeatureExtensionsForSourceIdentifier:(nonnull NSString *)sourceIdentifier
                                          feature:(nonnull MBXFeature *)feature
                                        extension:(nonnull NSString *)extension
                                   extensionField:(nonnull NSString *)extensionField
                                             args:(nullable NSDictionary<NSString *, id> *)args
                                         callback:(nonnull MBMQueryFeatureExtensionCallback)callback;
- (void)getFeatureStateForSourceId:(nonnull NSString *)sourceId
                     sourceLayerId:(nullable NSString *)sourceLayerId
                         featureId:(nonnull NSString *)featureId
                          callback:(nonnull MBMQueryFeatureStateCallback)callback;
+ (void)clearDataForResourceOptions:(nonnull MBMResourceOptions *)resourceOptions
                           callback:(nonnull MBMAsyncOperationResultCallback)callback;
@end
