//
//  NSFileManager+SQAdditions.h
//  SquareCore
//
//  Created by Kyle Van Essen on 4/16/14.
//  Copyright (c) 2014 Square, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface NSFileManager (SQAdditions)

/**
 When Square frameworks are used in third-party developers' apps, supporting files should be nested in designated Square directories in order to avoid naming conflicts with files belonging to the host apps. Frameworks vended to third-party developers should set this to a non-nil value. By default this value is nil, meaning files are stored at the root of their respective directories.
 
 Example: 'Application Support/Analytics.sqlite' becomes 'Application Support/Square/Analytics.sqlite'.
 */
@property (class, nonatomic, copy) NSString *SQ_defaultParentFolder;

///
/// @name NSSearchPathDirectory Additions
///

/// The application support directory for the application.
- (NSURL *)SQ_userApplicationSupportDirectoryURL;

/**
 The directory for the provided search path.
 
 @return The file URL, or nil if the search path directory could not be found.
 */
- (NSURL *)SQ_userDirectoryURLForSearchPath:(NSSearchPathDirectory)searchPath;

@end
