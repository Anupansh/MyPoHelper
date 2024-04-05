//
//  SquareCoreDefines.h
//  SquareCore
//
//  Created by Kyle Van Essen on 8/5/13.
//  Copyright (c) 2013 Square, Inc. All rights reserved.
//

#import <Foundation/NSObjCRuntime.h>
#import <SquareCore/SquareCoreDebugAssertDefines.h>


/**
 Turns `_string` into a C string.

 Example:
 // Creates "foo == true".
 _SQStringifyMacro(foo == true);
 */
#define _SQStringifyMacro(_string) #_string

///
/// @name Logging
///


/**
 In DEBUG environments, logs the passed in string.

 In non-DEBUG environments, nothing is logged.
 */
#if DEBUG
#define SQDebugLog(...)     \
    if (YES) {              \
        NSLog(__VA_ARGS__); \
    }
#else
#define SQDebugLog(...)     \
    if (NO) {               \
        NSLog(__VA_ARGS__); \
    }
#endif


///
/// @name Errors & Assertions
///

/**
 DEBUG:
  `SQCheckCondition` will throw a caught exception and return "result" if "condition" is false.

 Non-DEBUG & XCTest:
  `SQCheckCondition` will simply return "result" if "condition" is false.

 XCTest Notes:
  When writing tests that expect `SQCheckCondition` to fire, you should wrap the method causing the
  check condition to fire with `SQTAssertHitsDebugException`. Any non-caught `SQCheckCondition` will cause your unit tests to fail.
  Conversely, if you wrap a method call with `SQTAssertHitsDebugException` and it does not throw an assertion, your unit tests will fail.

 Example:
    SQCheckCondition(isProperlyConfigured, nil, @"Foo was not properly configured.");
 */
#define SQCheckCondition(condition, result, ...) \
    _SQPrimitiveDebugAssert(NSAssert, (condition), return result, nil, self, _cmd, __PRETTY_FUNCTION__, __VA_ARGS__)

#define SQCheckCCondition(condition, result, ...) \
    _SQPrimitiveDebugAssert(NSCAssert, (condition), return result, nil, nil, NULL, __PRETTY_FUNCTION__, __VA_ARGS__)

#define SQCheckConditionWithContext(condition, result, context, ...) \
    _SQPrimitiveDebugAssert(NSAssert, (condition), return result, context, nil, NULL, __PRETTY_FUNCTION__, __VA_ARGS__)


/**
 DEBUG:
  `SQDebugAssert` and `SQRaiseDebugException` will throw a caught exception.

 Non-DEBUG & XCTest:
  `SQDebugAssert` and `SQRaiseDebugException` will log the result.

 XCTest Notes:
  When writing tests that expect `SQDebugAssert` or `SQRaiseDebugException` to fire, you should wrap the method causing the
  check condition to fire with `SQTAssertHitsDebugException`. Any non-caught `SQDebugAssert` will cause your unit tests to fail.
  Conversely, if you wrap a method call with `SQTAssertHitsDebugException` and it does not throw an assertion, your unit tests will fail.

 Example:
    SQRaiseDebugException(@"We shouldn't get here.");
    SQDebugAssert(foo != nil, @"Foo should not be nil. Falling back to `bar`.");
 */
#define SQDebugAssert(condition, ...) \
    _SQPrimitiveDebugAssert(NSAssert, (condition), , nil, self, _cmd, __PRETTY_FUNCTION__, __VA_ARGS__)

#define SQDebugCAssert(condition, ...) \
    _SQPrimitiveDebugAssert(NSCAssert, (condition), , nil, nil, NULL, __PRETTY_FUNCTION__, __VA_ARGS__)

#define SQDebugAssertWithContext(condition, context, ...) \
    _SQPrimitiveDebugAssert(NSAssert, (condition), , context, nil, NULL, __PRETTY_FUNCTION__, __VA_ARGS__)

#define SQRaiseDebugException(...) \
    SQDebugAssert(NO, __VA_ARGS__)

#define SQRaiseCDebugException(...) \
    SQDebugCAssert(NO, __VA_ARGS__)

#define SQRaiseDebugExceptionWithContext(context, ...) \
    SQDebugAssertWithContext(NO, context, __VA_ARGS__)

/**
 Raises an uncaught exception with the given format string as it's reason.
 */
#define SQRaiseException(...) \
    @throw [NSException exceptionWithName:NSInternalInconsistencyException reason:[NSString stringWithFormat:__VA_ARGS__] userInfo:nil]

/**
 Raises an uncaught exception used to indicate the method must be overidden by subclasses.
 */
#define SQRaiseUnimplementedAbstractMethodException() \
    SQRaiseException(@"Subclasses of %@ must implement %@.", [self class], NSStringFromSelector(_cmd))

/**
 Raises an uncaught exception used to indicate that this method is an initializer inherited from a superclass that is no longer a valid means of instantiating this object.
 */
#define SQRaiseInvalidInitializerException() \
    SQRaiseException(@"%@ is not a valid initializer to use for %@. Use the designated initializer instead.", NSStringFromSelector(_cmd), [self class]);

/**
 Raises an uncaught exception used to indicate that the class must be subclassed in order to be used.
 */
#define SQAssertRequiresSubclass(abstractClass)                                                \
    if ([self class] == abstractClass) {                                                       \
        SQRaiseException(@"%@ cannot be used directly, you must subclass it.", abstractClass); \
    }


///
/// @name Strong & Weak Declarations
///


/**
 Creates a strong, weak, or block reference to "originalName".

 Example:
    // Declares "strongSelf" as a strong reference to self.
    SQStrongify(self, strongSelf);
 */
#define SQStrongify(originalName, strongName) \
    __strong __typeof__(originalName) strongName = originalName

/**
 `SQWeakify` should only be used in one of the following use cases:
    - To avoid a retain cycle within a block that references an object *and* the block itself is owned by the object, either directly or indirectly.
    - If you explicitly do not want the object to live as long as the block, e.g., the object is ephemeral and execution of the block is not required to maintain correct object state.
 */
#define SQWeakify(originalName, weakName) \
    __weak __typeof__(originalName) weakName = originalName

#define SQBlockify(originalName, blockName) \
    __block __typeof__(originalName) blockName = originalName


///
/// @name Compile Time Key Paths
///


/**
 Provides the ability to verify key paths at compile time.

 If "keyPath" does not exist, a compile-time error will be generated.

 Example:
    // Verifies "isFinished" exists on "operation".
    NSString *key = SQKeyPath(operation, isFinished);

    // Verifies "isFinished" exists on self.
    NSString *key = SQSelfKeyPath(isFinished);

    // Verifies "isFinished" exists on instances of NSOperation.
    NSString *key = SQTypedKeyPath(NSOperation, isFinished);
 */
#define SQKeyPath(object, keyPath) \
    ({ if (NO) { (void)((object).keyPath); } @#keyPath; })

#define SQSelfKeyPath(keyPath) SQKeyPath(self, keyPath)
#define SQTypedKeyPath(ObjectClass, keyPath) SQKeyPath(((ObjectClass *)nil), keyPath)
#define SQProtocolKeyPath(Protocol, keyPath) SQKeyPath(((id<Protocol>)nil), keyPath)


///
/// @name Compile Time Selectors
///


/**
 Provides the ability to verify @selectors at compile time.

 If "selectorName" does not exist, a compile-time error will be generated.

 Example:
    // Verifies -cancel exists on "operation".
    SEL selector = SQSelector(operation, cancel);

    // Verifies -cancel exists on self.
    SEL selector = SQSelfSelector(cancel);

    // Verifies "cancel" exists on instances of NSOperation.
    NSString *key = SQTypedSelector(NSOperation, cancel);
 */
#define SQSelector(object, selectorName) \
    ({ if (NO) { (void)[(object) selectorName]; } @selector(selectorName); })

#define SQSelfSelector(selectorName) SQSelector(self, selectorName)
#define SQTypedSelector(ObjectClass, selectorName) SQSelector(((ObjectClass *)nil), selectorName)
#define SQProtocolSelector(Protocol, selectorName) SQSelector(((id<Protocol>)nil), selectorName)

/**
 Identical to SQSelector, except for selectors that take an argument.

 Argument must be of type id.

 Example:
    // Verifies -cancelWithError: exists on "operation".
    SEL selector = SQSelector1(operation, cancelWithError:);
 */
#define SQSelector1(object, selectorName)                     \
    ({                                                        \
        if (NO) {                                             \
            id __SQC_placeholderArgument = (id)[NSNull null];       \
            (void)[(object)selectorName __SQC_placeholderArgument]; \
        }                                                     \
                                                              \
        @selector(selectorName);                              \
    })

#define SQSelfSelector1(selectorName) SQSelector1(self, selectorName)
#define SQTypedSelector1(ObjectClass, selectorName) SQSelector1(((ObjectClass *)nil), selectorName)
#define SQProtocolSelector1(Protocol, selectorName) SQSelector1(((id<Protocol>)nil), selectorName)

/**
 Identical to SQSelector, except for selectors that take two arguments.

 Arguments must be of type id.

 Example:
    // Verifies -cancelWithError:completion: exists on "operation".
    SEL selector = SQSelector2(operation, cancelWithError:, completion:);
 */
#define SQSelector2(object, selectorComponent1, selectorComponent2)                                        \
    ({                                                                                                     \
        if (NO) {                                                                                          \
            id __SQC_placeholderArgument = (id)[NSNull null];                                                    \
            (void)[(object)selectorComponent1 __SQC_placeholderArgument selectorComponent2 __SQC_placeholderArgument]; \
        }                                                                                                  \
                                                                                                           \
        @selector(selectorComponent1 selectorComponent2);                                                  \
    })

#define SQSelfSelector2(selectorComponent1, selectorComponent2) SQSelector2(self, selectorComponent1, selectorComponent2)
#define SQTypedSelector2(ObjectClass, selectorComponent1, selectorComponent2) SQSelector2(((ObjectClass *)nil), selectorComponent1, selectorComponent2)
#define SQProtocolSelector2(Protocol, selectorComponent1, selectorComponent2) SQSelector2(((id<Protocol>)nil), selectorComponent1, selectorComponent2)


///
/// @name Memory Management
///


/**
 Use to provide default "set or return if equal" behaviour when overriding a method setter.

 Example:
    - (void)setName:(NSString *)name;
    {
        SQSynthesizeCopiedSetter(_name, name);

        // Perform your implementation here.
    }
 */
#define SQSynthesizeSetter(ivar, newValue) \
    {                                      \
        if (ivar == newValue) {            \
            return;                        \
        }                                  \
        ivar = newValue;                   \
    }

#define SQSynthesizeSetterWithComparator(ivar, newValue, comparator) \
    {                                                                \
        if (comparator(ivar, newValue)) {                            \
            return;                                                  \
        }                                                            \
        ivar = newValue;                                             \
    }

#define SQSynthesizeCopiedSetter(ivar, newValue) \
    {                                            \
        if (ivar == newValue) {                  \
            return;                              \
        }                                        \
        ivar = [newValue copy];                  \
    }

/**
 Release and NULL a CFType pointer. Does nothing if passed NULL.

 Example:
    CFArrayRef array = (bool ? someArray : NULL);

    SQCFReleaseAndNull(array);

 */
#define SQCFReleaseAndNull(object) \
    {                              \
        if (object) {              \
            CFRelease(object);     \
        };                         \
        object = NULL;             \
    }


///
/// @name Designated Initializer
///

/**
 Marks an init method as being the designated initializer for the class.

 Any init method calling a [super init...] chain that does not call this method will generate a compiler warning.

 Example:
    - (instancetype)initWithFoo:(id)foo SQ_DESIGNATED_INITIALIZER;
 */
#define SQ_DESIGNATED_INITIALIZER \
    __attribute__((objc_designated_initializer))

///
/// @name Class Constraints
///

/**
  Any attempt to subclass a class annotated with SQ_FINAL is reported as a compile-time error.

 Example:
 SQ_FINAL
 @interface FinalClass : NSObject
 @end
 */

#define SQ_FINAL \
    __attribute__((objc_subclassing_restricted))

///
/// @name Deprecations & Warnings
///

/**
 Marks method, class, or value as deprecated and unsupported. Signifies the method, class, or value will soon be removed.

 Example:
    - (void)deprecatedMethod SQ_DEPRECATED("deprecatedMethod is deprecated. Please use newShinyMethod instead.");
 */
#define SQ_DEPRECATED(ReasonCString) \
    __attribute__((deprecated(ReasonCString)))

/**
 Marks method, class, or value as unavailable.
 Attempting to use the method, class, or value will result in a compile-time error.

 Example:
    - (void)unavailableMethod SQ_UNAVAILABLE("unavailableMethod is not available in a Merchant-facing environment.");
 */
#define SQ_UNAVAILABLE(ReasonCString) \
    __attribute__((unavailable(ReasonCString)))

///
/// @name Behaviours & Enforcement
///

#ifdef NS_NOESCAPE
    #define SQ_NOESCAPE NS_NOESCAPE
#else
    #define SQ_NOESCAPE
#endif

/**
 When overriding this method, subclasses must call super in their implementation.
 A missing call to super will result in a compile-time error.

 Example:
    - (void)superRequiredMethod SQ_REQUIRES_SUPER;
 */
#define SQ_REQUIRES_SUPER \
    __attribute__((objc_requires_super))

/**
 !!! DEPRECATED! DO NOT USE! Use `nonnull` or `_Nonnull` annotations on parameters instead.

 Mark arguments to a method or function as requiring a non-nil/NULL/Nil value.

 Argument is a 1-indexed, comma-deliminated list of indexes which must be non-nil/NULL/Nil.

 Example:
    - (void)performWithNonNilValue:(id)value SQ_NONNULL(1);
 */
#define SQ_NONNULL(...) \
    __attribute__((nonnull(__VA_ARGS__)))

/**
 Used to mark a section of code as TODO (ldap name) "message".

 To generate warnings, set the below conditional to 1. Defaults to zero where the SQ_TODO are silently discarded as warnings cause Xcode to be incredibly slow.

 Example:
    SQ_TODO("apgar", "Refactor this to be testable.");
 */
#if 0
#define SQ_PRAGMA_STRINGIFY(string) _Pragma(#string)
#define SQ_TODO(ldapname, todoMessage) SQ_PRAGMA_STRINGIFY(message "TODO: (" ldapname ") " todoMessage)
#else
#define SQ_TODO(ldapnname, todoMessage)
#endif


///
/// @name Clang Diagnostics
///

/**
 Allows easier pushing and popping of clang warnings.

 Example (Ignoring undeclared selectors):
    SQClangDiagnosticPushIgnored("-Wundeclared-selector");

    // Without SQClangDiagnosticPush, this is a compiler error.
    SEL undeclaredSelector = @selector(thisSelectorDoesNotExist:::);

    SQClangDiagnosticPop;
 */
#define SQClangDiagnosticPush() \
    _Pragma("clang diagnostic push")

#define SQClangDiagnosticPushIgnored(IgnoredFlagString) \
    SQClangDiagnosticPush() _Pragma(_SQStringifyMacro(clang diagnostic ignored IgnoredFlagString))

#define SQClangDiagnosticPop() \
    _Pragma("clang diagnostic pop")


///
/// @name Feature Flags
///

/**
 Force all feature flags to be turned on.

 To be turned on as a build flag to ensure that all features build together cleanly.
 */
#ifndef ENABLE_ALL_FEATURE_FLAGS
#define ENABLE_ALL_FEATURE_FLAGS 0
#endif

/**
 Used to compile in/out features not yet ready to ship, or features being incrementally developed. To disable a feature even when ENABLE_ALL_FEATURE_FLAGS is on, set the value to -1

 Note:
    To enable all feature flags in a target, define ENABLE_ALL_FEATURE_FLAGS to 1.

 Example:
    #define ENABLE_MY_NEW_FEATURE 1

    #if ENABLE(MY_NEW_FEATURE)
        // Feature specific code...
    #endif
 */
#define ENABLE(SQ_FEATURE)                                        \
    (!(defined ENABLE_##SQ_FEATURE && ENABLE_##SQ_FEATURE < 0) && \
     ((defined ENABLE_ALL_FEATURE_FLAGS && ENABLE_ALL_FEATURE_FLAGS) || (defined ENABLE_##SQ_FEATURE && ENABLE_##SQ_FEATURE)))


///
/// @name String Manipulation
///

/**
 Ensures that the returned string is never a NULL value.
 */
#define SQEmptyStringIfNil(string) \
    (NSString * _Nonnull)({ __typeof__(string) __s = (string); __s ? __s : @""; })

/**
 Ensures that the returned object is never an empty string.
 */
#define SQNilIfEmptyString(string) ({ __typeof__(string) __s = (string); __s.length == 0 ? nil : __s; })

/**
 Returns "YES" if "bool" is true, "NO" otherwise.
 */
#define SQYESNOStringForBOOL(bool) \
    ({ __typeof__(bool) __b = (bool); __b ? @"YES" : @"NO"; })

/**
 Checks if nullable objects are equal.

 Returns "YES" when obj1 and obj2 are both nil or when the selector "isEqual:"
 for the objects return "YES".

 Else returns "NO"

 Example:
 SQAreNullableObjectsEqual(nil, nil) // YES
 SQAreNullableObjectsEqual(@"Hello", nil) // NO
 SQAreNullableObjectsEqual(@"Hello", @"Hello") // YES
 */
#define SQAreNullableObjectsEqual(obj1, obj2) \
    ({ __typeof__(obj1) __o1 = (obj1); __typeof(obj2) __o2 = (obj2); \
    ((__o1 == __o2) || (__o1 && __o2 && [__o1 isEqual:__o2])); })


///
/// @name Block Invocations
///

/**
 Ensures that the block is not NULL before executing it.
 */
#define SQInvokeBlock(blockName, ...) \
    do {                              \
        if (blockName != NULL) {      \
            blockName(__VA_ARGS__);   \
        }                             \
    } while (NO)

/**
 Shortcut for safely invoking a completion block on the main queue. Note that invocation is always asynchronous.
 */
#define SQInvokeMainQueueBlock(blockName, ...)                     \
    do {                                                           \
        if (blockName != NULL) {                                   \
            [[NSOperationQueue mainQueue] addOperationWithBlock:^{ \
                blockName(__VA_ARGS__);                            \
            }];                                                    \
        }                                                          \
    } while (NO)


///
/// @name Mac & iOS Builds
///

#if TARGET_OS_IPHONE
#define SQUARECORE_IOS 1
#define SQUARECORE_MAC 0
#else
#define SQUARECORE_IOS 0
#define SQUARECORE_MAC 1
#endif
