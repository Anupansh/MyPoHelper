//
//  CSOerstedAnalogSignalDecoder.h
//  CoreSwipe
//
//  Created by Martin Mroz on 5/14/13.
//  Copyright (c) 2013 Square, Inc. All rights reserved.
//

#import <SquareReader/CSAnalogSignalDecoder.h>
#import <SquareReader/CSSwipedPaymentCard.h>


@interface CSOerstedAnalogSignalDecoder : CSAnalogSignalDecoder

/**
 Applies a 129-tap highpass filter to the input signal with a cutoff frequency of 500Hz and a
 transition width of 500Hz. Attenuation at the low 10s of Hz is -35dB and over 500Hz is +/- 1dB.
 The filter also eliminates any leading rise in the signal. Due to the way FIR filters work,
 the input signal must be at least 129 samples. The resulting signal will be 128 samples shorter
 than the input due to corruption resulting from initial conditions. For additional information
 read "iPhone 6S and 6S Plus O1 Signal Filtering Procedure", ALERT-1710 and RI-12319.

 @param inputSignal The input signal to apply the filter to. Must be non-NULL and at least 129 samples long.
   Input is 16-bit 44.1KHz padded, signed, little-endian PCM waveform data.
 @return The input signal after application of the filter or NULL if initial conditions are not met.
   Result is 16-bit 44.1KHz padded, signed, little-endian PCM waveform data.
   Output will be 128 samples shorter than the input.
 */
+ (CSBMCSignalRef)createSignalByApplyingiPhone6SFilterToSignal:(CSBMCSignalRef)inputSignal;

/**
 Per RI-12886, attempting to apply the iPhone 6S filter can crash in vDSP_desamp on devices
 running iOS prior to version 9.0. This is liklely due to a bug in Accelerate on iOS prior to version 9.0.
 The minimum version of iOS required by the iPhone 6S and the 6S Plus is 9.0 and therefore limiting
 application of the filter will not prevent the fix from working as intended on affected devices.
 
 @param systemVersion The current iOS system version string as reported by UIDevice (i.e. "9.0.1").
 @return YES if the iPhone 6S filter should be applied based on the system version, NO otherwise.
 */
+ (BOOL)shouldApplyiPhone6SFilterWithiOSSystemVersion:(NSString *)systemVersion;

@end


@interface CSSwipedPaymentCard (CSOerstedPaymentCard)

+ (instancetype)paymentCardWithEncryptedOerstedTrackData:(NSData *)trackData trackType:(CSTrackType)type;

@end
