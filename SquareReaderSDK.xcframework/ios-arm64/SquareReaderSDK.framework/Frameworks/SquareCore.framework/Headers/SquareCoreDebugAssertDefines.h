// MARK: Formatter Exempt

//
//  SquareCoreDebugAssertDefines.h
//  SquareCore
//
//  Created by Kyle Van Essen on 5/9/14.
//  Copyright (c) 2014 Square, Inc. All rights reserved.
//

#import <SquareCore/SQDebugAssertionConfiguration.h>
#import <SquareCore/SQDebugException.h>

///
/// @name Debug Assertion Macros
///

/**
 Implementation backing all SQDebug(C)Assert and SQCheck(C)Condition macros.
 
 @param ns_assert_macro The Foundation assertion macro to use when throwing exceptions.
 @param condition The condition to check. Should be YES on success, and NO on failure.
 @param return_statement An optional return statement to insert if `condition` is false.
 @param assertion_object The object responsible for the assertion.
 @param assertion_selector The selector in which the assertion occurred.
 @param assertion_function The function in which the assertion occurred.
 @param __VA_ARGS__ A format string providing details about the assertion.
 */
#define _SQPrimitiveDebugAssert(ns_assert_macro, condition, return_statement, assertion_context, assertion_object, assertion_selector, assertion_function, ...)                                                                                                                                                                                   \
    { \
        const BOOL __SQC_conditionResult = !!(condition); \
        \
        if (!__SQC_conditionResult) { \
            NSString *__SQC_conditionString = @_SQStringifyMacro(condition); \
            NSString *__SQC_logMessage = [NSString stringWithFormat:__VA_ARGS__]; \
            \
            SQDebugAssertionFired(); \
            SQDebugException *__SQC_exception = [[SQDebugException alloc] initWithConditionString:__SQC_conditionString message:__SQC_logMessage context:assertion_context functionName:assertion_function object:assertion_object selector:assertion_selector]; \
            \
            [SQDebugAssertionConfiguration debugAssertionFired]; \
            [__SQC_exception postNotification]; \
            \
            SQDebugAssertionMode __SQC_mode = SQDebugAssertionConfiguration.sharedInstance.assertionMode; \
            \
            /* Don't log anything on SQDebugAssertionModeReleaseBuild, could contain sensitive information */ \
            if (__SQC_mode == SQDebugAssertionModeDebugBuild) { \
                @try { \
                    ns_assert_macro(NO, @"%@ %@", __SQC_logMessage, assertion_context); \
                } \
                @catch (NSException * __SQC_e) { NSLog(@"%@ %@", __SQC_logMessage, assertion_context); } \
            } else if (__SQC_mode == SQDebugAssertionModeXCTestEnvironment) { \
                if (![SQDebugAssertionConfiguration isExpectingDebugAssertionOnCurrentThread]) { \
                    ns_assert_macro(NO, @"%@ %@", __SQC_logMessage, assertion_context); \
                } \
            } \
            \
            return_statement; \
        } \
    }
