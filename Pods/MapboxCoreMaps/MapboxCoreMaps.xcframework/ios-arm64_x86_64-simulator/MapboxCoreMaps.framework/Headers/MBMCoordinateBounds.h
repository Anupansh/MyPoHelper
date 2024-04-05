// This file is generated and will be overwritten automatically.

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>

/** A rectangular area as measured on a two-dimensional map projection. */
NS_SWIFT_NAME(CoordinateBounds)
__attribute__((visibility ("default")))
@interface MBMCoordinateBounds : NSObject

// This class provides custom init which should be called
- (nonnull instancetype)init NS_UNAVAILABLE;

// This class provides custom init which should be called
+ (nonnull instancetype)new NS_UNAVAILABLE;

- (nonnull instancetype)initWithSouthwest:(CLLocationCoordinate2D)southwest
                                northeast:(CLLocationCoordinate2D)northeast;

- (nonnull instancetype)initWithSouthwest:(CLLocationCoordinate2D)southwest
                                northeast:(CLLocationCoordinate2D)northeast
                           infiniteBounds:(BOOL)infiniteBounds;

/** Coordinate at the southwest corner. */
@property (nonatomic, readonly) CLLocationCoordinate2D southwest;

/** Coordinate at the northeast corner. */
@property (nonatomic, readonly) CLLocationCoordinate2D northeast;

/**
 * If set to `true`, an infinite (unconstrained) bounds covering the world coordinates would be used.
 * Coordinates provided in `southwest` and `northeast` fields would be omitted and have no effect.
 */
@property (nonatomic, readonly, getter=isInfiniteBounds) BOOL infiniteBounds;


@end
