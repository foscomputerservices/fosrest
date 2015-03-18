//
//  FOSSleepOperationTests.m
//  FOSREST
//
//  Created by David Hunt on 12/8/13.
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

#import <XCTest/XCTest.h>
#import "FOSRESTTests.h"

@interface FOSSleepOperationTests : XCTestCase

@end

@implementation FOSSleepOperationTests

SETUP_TEARDOWN_NOLOGIN

- (void)testSimpleSleep {
    START_TEST

    NSDate *startNow = [NSDate date];
    NSTimeInterval sleepInterval = 3.0f;

    FOSSleepOperation *sleepOp = [FOSSleepOperation sleepOperationWithSleepInterval:sleepInterval];
    FOSBackgroundOperation *finalOp = [FOSBackgroundOperation backgroundOperationWithRequest:^(BOOL cancelled, NSError *error) {

        NSDate *endNow = [NSDate date];

        XCTAssertFalse(cancelled, @"Cancelled???");
        XCTAssertNil(error, @"Error: %@???", error.description);

        XCTAssertTrue([endNow timeIntervalSinceDate:startNow] >= sleepInterval, @"Sleep time is off???");

        END_TEST
    }];

    [finalOp addDependency:sleepOp];

    [[FOSRESTConfig sharedInstance].cacheManager queueOperation:finalOp
                                        withCompletionOperation:nil
                                                  withGroupName:@"Test FOSSleepOperation"];

    WAIT_FOR_TEST_END
}

@end
