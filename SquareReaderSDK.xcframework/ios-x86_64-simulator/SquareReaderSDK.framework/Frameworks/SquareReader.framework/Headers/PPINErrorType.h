@import Foundation;

typedef NS_ENUM(NSUInteger, PPINErrorType) {
    PPINErrorTypeNone = 0,
    PPINErrorTypeTooManyDigits = 1,
    PPINErrorTypeTooFewDigits = 2,
    PPINErrorTypeTamperDetected = 3,
    PPINErrorTypeUnspecified = 4
};
