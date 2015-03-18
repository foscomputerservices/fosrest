//
//  FOSRESTTests.h
//  FOSRESTTests
//
//  Created by David Hunt on 12/22/12.
//
//  The MIT License (MIT)
//
//  Copyright (c) 2015 FOS Services, LLC
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in all
//  copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
//  SOFTWARE.
//

@import UIKit;
#import <XCTest/XCTest.h>
#import "FOSREST.h"
#import "FOSLoginManagerTests.h"

#define TEST_LOG_LEVEL (FOSLogLevelPedantic)

#define START_TEST \
    dispatch_semaphore_t semaphore = dispatch_semaphore_create(0); \
    FOSLogInfo(@"###### Test START ######"); \
    FOSSetLogLevel(FOSLogLevelPedantic);


#define END_TEST { \
    FOSSetLogLevel(TEST_LOG_LEVEL); \
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
    FOSSetLogLevel(TEST_LOG_LEVEL); \
    FOSLogInfo(@"###### Test SETUP NO Login ######"); \
    [super setUp]; \
    \
    [[FOSLoginManagerTests class] setupStandardWebServiceConfig]; \
    FOSSetLogLevel(FOSLogLevelDebug); \
}


#define TEARDOWN_NOLOGIN \
- (void)tearDown { \
    FOSSetLogLevel(TEST_LOG_LEVEL); \
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
    FOSSetLogLevel(TEST_LOG_LEVEL); \
    FOSLogInfo(@"###### Test SETUP WITH Login ######"); \
    [super setUp]; \
\
    [[FOSLoginManagerTests class] setupStandardWebServiceConfigAndLogInWithOptions:options]; \
    FOSSetLogLevel(FOSLogLevelDebug); \
}

#define TEARDOWN_LOGIN \
- (void)tearDown { \
    FOSSetLogLevel(TEST_LOG_LEVEL); \
    [[FOSLoginManagerTests class] tearDownWebServiceAndLogOut]; \
\
    [super tearDown]; \
    FOSSetLogLevel(FOSLogLevelDebug); \
}

#define SETUP_TEARDOWN_LOGIN(options) \
    SETUP_LOGIN(options) \
    TEARDOWN_LOGIN


@interface FOSRESTTests : XCTestCase

@end
