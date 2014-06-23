//
//  FOSFoundationTests.h
//  FOSFoundationTests
//
//  Created by David Hunt on 12/22/12.
//  Copyright (c) 2011 FOS Computer Services. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "FOSLoginManagerTests.h"


#define START_TEST \
    dispatch_semaphore_t semaphore = dispatch_semaphore_create(0); \
    FOSLogInfo(@"###### Test START ######"); \
    FOSSetLogLevel(FOSLogLevelPedantic);


#define END_TEST { \
    FOSSetLogLevel(FOSLogLevelInfo); \
    FOSLogInfo(@"###### Test END ######"); \
    dispatch_semaphore_signal(semaphore); }

#define WAIT_FOR_TEST_END { \
    CGFloat interval = 0.5f; \
    NSUInteger loopCount = 0, maxCount = (NSUInteger)((1.0f / interval) * 60.0f); \
    while (dispatch_semaphore_wait(semaphore, DISPATCH_TIME_NOW)) { \
        if (loopCount++ < maxCount) { \
            [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode \
                                     beforeDate:[NSDate dateWithTimeIntervalSinceNow:interval]]; \
        } \
        else { \
            [NSException raise:@"FOSTesting" format:@"###### Test timed out!!! ######"]; \
        } \
    } \
}

#define SETUP_NOLOGIN \
- (void)setUp { \
    FOSSetLogLevel(FOSLogLevelInfo); \
    FOSLogInfo(@"###### Test SETUP NO Login ######"); \
    [super setUp]; \
    \
    [[FOSLoginManagerTests class] setupStandardWebServiceConfig]; \
    FOSSetLogLevel(FOSLogLevelDebug); \
}


#define TEARDOWN_NOLOGIN \
- (void)tearDown { \
    FOSSetLogLevel(FOSLogLevelInfo); \
    FOSLogInfo(@"###### Test TEARDOWN ######"); \
    [[FOSLoginManagerTests class] tearDownWebService]; \
    \
    [super tearDown]; \
    FOSSetLogLevel(FOSLogLevelDebug); \
}


#define SETUP_TEARDOWN_NOLOGIN \
    SETUP_NOLOGIN \
    TEARDOWN_NOLOGIN

#define SETUP_LOGIN(options) \
- (void)setUp { \
    FOSSetLogLevel(FOSLogLevelInfo); \
    FOSLogInfo(@"###### Test SETUP WITH Login ######"); \
    [super setUp]; \
\
    [[FOSLoginManagerTests class] setupStandardWebServiceConfigAndLogInWithOptions:options]; \
    FOSSetLogLevel(FOSLogLevelDebug); \
}

#define TEARDOWN_LOGIN \
- (void)tearDown { \
    FOSSetLogLevel(FOSLogLevelInfo); \
    [[FOSLoginManagerTests class] tearDownWebServiceAndLogOut]; \
\
    [super tearDown]; \
    FOSSetLogLevel(FOSLogLevelDebug); \
}

#define SETUP_TEARDOWN_LOGIN(options) \
    SETUP_LOGIN(options) \
    TEARDOWN_LOGIN


@interface FOSFoundationTests : XCTestCase

@end
