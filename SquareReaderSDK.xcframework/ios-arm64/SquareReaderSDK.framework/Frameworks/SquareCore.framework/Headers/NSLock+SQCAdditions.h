//
//  NSLock+SQCAdditions.h
//  SquareCore
//
//  Created by Dan Federman on 2/10/16.
//  Copyright © 2016 Square, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface NSLock (SQCAdditions)

/*
 Locks, performs the provided block, then unlocks.
 
 @param block A block to execute within the context of the receiver.
 */
- (void)SQC_perform:(nonnull dispatch_block_t)block;

@end
