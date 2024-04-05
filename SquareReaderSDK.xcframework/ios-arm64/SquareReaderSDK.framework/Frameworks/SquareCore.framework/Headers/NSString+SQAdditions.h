//
//  NSString+SQAdditions.h
//  SquareCore
//
//  Created by Kyle Van Essen on 4/16/14.
//  Copyright (c) 2014 Square, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface NSString (SQAdditions)

///
/// @name URL Escaping
///

/**
 Creates a new string and percent-escapes all possible characters. Useful for placing strings in URLs.

 @return A new string, with all percent-encodeable characters converted to their percent-escaped equivalents.
 */
- (NSString *)SQ_stringByPercentEscapingString;

///
/// @name String Casing
///

/// @return A new string converted to uppercase. Uses the currentLocale.
- (NSString *)SQ_uppercaseStringWithCurrentLocale;
/// @return A new string with all words capitalized. Uses the currentLocale.
- (NSString *)SQ_capitalizedStringWithCurrentLocale;
/// @return A new string converted to lowercase. Uses the currentLocale.
- (NSString *)SQ_lowercaseStringWithCurrentLocale;

@end
