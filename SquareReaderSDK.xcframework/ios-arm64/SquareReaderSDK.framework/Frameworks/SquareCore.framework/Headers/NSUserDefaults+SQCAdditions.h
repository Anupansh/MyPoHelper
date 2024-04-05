//
//  NSUserDefaults+SQCAdditions.h
//  Pods
//
//  Created by Joseph Hankin on 3/28/17.
//
//

#import <Foundation/Foundation.h>


NS_ASSUME_NONNULL_BEGIN


@interface NSUserDefaults (SQCAdditions)

/**
 If this property is unset, it will return <code>[NSUserDefaults standardUserDefaults]</code>.  Set this property during
 app or framework initialization to have it return a separate instance of <code>NSUserDefaults</code>.

 When Square frameworks are used in third-party developers' apps, they should not store data in the
 <code>standardUserDefaults</code> instance, lest it be commingled with the developers' own data.  Square apps and
 frameworks should use the <code>SQC_squareUserDefaults</code> instance instead of calling <code>standardUserDefaults</code>
 directly.  Frameworks vended to third-party developers can then set this property to be a separate instance of 
 <code>NSUserDefaults</code>, making the Square instance distinct from the developer's <code>standardUserDefaults</code>.
 */

@property (class, nonatomic, strong) NSUserDefaults *squareUserDefaults;

@end


NS_ASSUME_NONNULL_END
