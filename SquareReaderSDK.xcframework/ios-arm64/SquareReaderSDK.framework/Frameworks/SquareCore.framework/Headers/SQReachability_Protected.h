//
//  SQReachability_Protected.h
//  SquareCore
//
//  Created by Alan Fineberg on 4/28/2014
//  Copyright 2014 Square, Inc. All rights reserved.
//

#import <SquareCore/SQReachability.h>


@interface SQReachability ()

/// If YES, `connectedToInternet` will always return YES. Useful in testing or demo environments. Defaults to NO.
@property (atomic, assign) BOOL connectedToInternetAlwaysReportsYes;

@end
