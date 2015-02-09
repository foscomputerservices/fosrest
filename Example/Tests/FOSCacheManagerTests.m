//
//  FOSCacheManagerTests.m
//  FOSFoundation
//
//  Created by David Hunt on 1/3/13.
//  Copyright (c) 2013 FOS Computer Services. All rights reserved.
//

#import "FOSCacheManagerTests.h"
#import "FOSFoundationTests.h"
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
