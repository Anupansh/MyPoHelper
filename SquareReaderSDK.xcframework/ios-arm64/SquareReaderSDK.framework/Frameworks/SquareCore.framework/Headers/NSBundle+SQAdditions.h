//
//  NSBundle+SQAdditions.h
//  SquareCore
//
//  Created by Kyle Van Essen on 12/13/2013.
//  Copyright (c) 2013 Square, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface NSBundle (SQAdditions)

+ (NSBundle *)squareCoreResourcesBundle;

/// Returns an NSBundle containing localized resources for display with the specific locale.
/// If the provided locale (language and country) is not available, falls back to language only,
/// and then to the current locale.
- (NSBundle *)SQ_localizedBundleWithLocale:(NSLocale *)locale;

@end
