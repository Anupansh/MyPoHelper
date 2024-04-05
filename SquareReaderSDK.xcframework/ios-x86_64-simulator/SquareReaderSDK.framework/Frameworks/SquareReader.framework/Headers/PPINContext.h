@import Foundation;
#import <SquareReader/PPINErrorType.h>

@protocol PPINContext

- (void)PPIN_inputDidUpdateDigitCount:(size_t)digits animated:(BOOL)animated;
- (void)PPIN_inputDidSubmitWithData:(NSData *)data;
- (void)PPIN_inputDidClear;
- (void)PPIN_inputErrorDidOccur:(PPINErrorType)errorType;

@end
