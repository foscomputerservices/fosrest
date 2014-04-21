//
//  FOSBackgroundOperationTests.m
//  FOSFoundation
//
//  Created by David Hunt on 12/8/13.
//  Copyright (c) 2013 FOS Computer Services. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "FOSFoundationTests.h"

@interface FOSBackgroundOperationTests : XCTestCase

@end

@implementation FOSBackgroundOperationTests

SETUP_TEARDOWN_NOLOGIN

- (void)testMainThreadRequest {
    START_TEST

    FOSBackgroundOperation *bgOp = [FOSBackgroundOperation backgroundOperationWithMainThreadRequest:^(BOOL cancelled, NSError *error) {
        XCTAssertFalse(cancelled, @"Op was cancelled???");
        XCTAssertNil(error, @"Op encountered an error??");

        XCTAssertTrue([NSThread isMainThread], @"Not Main thread???");

        END_TEST
    }];

    [[FOSRESTConfig sharedInstance].cacheManager queueOperation:bgOp
                                        withCompletionOperation:nil
                                                  withGroupName:@"Test backgroundOperationWithMainThreadRequest"];

    WAIT_FOR_TEST_END
}

@end
