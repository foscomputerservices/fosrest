//
//  FOSSleepOperationTests.m
//  FOSFoundation
//
//  Created by David Hunt on 12/8/13.
//  Copyright (c) 2013 FOS Computer Services. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "FOSFoundationTests.h"

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
