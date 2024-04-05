@import Foundation;
#import <securesession_pinpad.h>

void PPIN_digitCountCallback(void *context, size_t digits);
void PPIN_submitButtonCallback(void *context, uint8_t *pinblock, size_t pinblock_len);
void PPIN_clearButtonCallback(void *context);
void PPIN_errorCallback(void *context, securesession_pinpad_app_error_t errorType);
