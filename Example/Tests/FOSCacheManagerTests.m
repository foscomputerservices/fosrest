//
//  FOSCacheManagerTests.m
//  FOSREST
//
//  Created by David Hunt on 1/3/13.
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

#import "FOSCacheManagerTests.h"
#import "FOSRESTTests.h"
#import "FOSLoginManagerTests.h"

@implementation FOSCacheManagerTests

#pragma mark - Test Configuration Methods

SETUP_TEARDOWN_LOGIN(FOSRESTConfigOptionsNone | FOSRESTConfigAutomaticallySynchronize)

#pragma mark - Tests

- (void)testFlushCaches {
    START_TEST

    [[FOSRESTConfig sharedInstance].cacheManager flushCaches:^(BOOL cancelled, NSError *error) {
        XCTAssertTrue([NSThread isMainThread], @"Wrong thread!");

        END_TEST
    }];

    WAIT_FOR_TEST_END
}

- (void)testFinalOp {
    START_TEST

    FOSSleepOperation *sleepOp = [FOSSleepOperation sleepOperationWithSleepInterval:2.0f];

    FOSBackgroundOperation *finalOp = [FOSBackgroundOperation backgroundOperationWithRequest:^(BOOL cancelled, NSError *error) {

        XCTAssertTrue(!sleepOp.isExecuting, @"Dependent op is executing???");
        XCTAssertTrue(sleepOp.isFinished, @"Dependent op hasn't run???");

        END_TEST
    }];

    [[FOSRESTConfig sharedInstance].cacheManager queueOperation:sleepOp
                                        withCompletionOperation:finalOp
                                                  withGroupName:@"Test finalOp"];

    WAIT_FOR_TEST_END
}

@end
