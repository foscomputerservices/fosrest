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
    NSLog(@"###### Test START ######");


#define END_TEST { \
    NSLog(@"###### Test END ######"); \
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
    NSLog(@"###### Test SETUP NO Login ######"); \
    [super setUp]; \
    \
    [[FOSLoginManagerTests class] setupStandardWebServiceConfig]; \
}


#define TEARDOWN_NOLOGIN \
- (void)tearDown { \
    NSLog(@"###### Test TEARDOWN ######"); \
    [[FOSLoginManagerTests class] tearDownWebService]; \
    \
    [super tearDown]; \
}


#define SETUP_TEARDOWN_NOLOGIN \
    SETUP_NOLOGIN \
    TEARDOWN_NOLOGIN

#define SETUP_LOGIN(options) \
- (void)setUp { \
    NSLog(@"###### Test SETUP WITH Login ######"); \
    [super setUp]; \
\
    [[FOSLoginManagerTests class] setupStandardWebServiceConfigAndLogInWithOptions:options]; \
}

#define TEARDOWN_LOGIN \
- (void)tearDown { \
    [[FOSLoginManagerTests class] tearDownWebServiceAndLogOut]; \
\
    [super tearDown]; \
}

#define SETUP_TEARDOWN_LOGIN(options) \
    SETUP_LOGIN(options) \
    TEARDOWN_LOGIN


@interface FOSFoundationTests : XCTestCase

@end