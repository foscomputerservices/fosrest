//
//  FOSThreadSleepTests.m
//  FOSFoundation
//
//  Created by David Hunt on 12/8/13.
//  Copyright (c) 2013 FOS Computer Services. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "FOSFoundationTests.h"

@interface FOSThreadSleepTests : XCTestCase

@end

@implementation FOSThreadSleepTests

SETUP_TEARDOWN_NOLOGIN

- (void)testSimpleSleep {
    START_TEST

    NSDate *startNow = [NSDate date];
    NSTimeInterval sleepInterval = 3.0f;

    FOSThreadSleep *sleep = [FOSThreadSleep threadSleepWithSleepInterval:(NSTimeInterval)sleepInterval andCompletionHandler:^(BOOL cancelled, NSError *error) {
        NSDate *endNow = [NSDate date];

        XCTAssertFalse(cancelled, @"Cancelled???");
        XCTAssertNil(error, @"Error: %@???", error.description);

        XCTAssertTrue([endNow timeIntervalSinceDate:startNow] >= sleepInterval,
                      @"Sleep time is off???");

        END_TEST
    }];

    [sleep start];

    WAIT_FOR_TEST_END
}

@end
