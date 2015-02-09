//
//  FOSParseAnalyticsManagerTests.m
//  FOSFoundation
//
//  Created by Administrator on 9/15/13.
//  Copyright (c) 2013 FOS Computer Services. All rights reserved.
//

#import "FOSParseAnalyticsManagerTests.h"
#import <FOSFoundation/FOSRESTConfig.h>
#import "FOSFoundationTests.h"
#import "FOSLoginManagerTests.h"

@implementation FOSParseAnalyticsManagerTests

#pragma mark - Test Configuration Methods

SETUP_TEARDOWN_LOGIN(FOSRESTConfigAutomaticallySynchronize)

#pragma mark - Tests

- (void)testSendingEventWithEmptyData {
    START_TEST

    [[FOSRESTConfig sharedInstance] trackEvent:@"TestEvent" withData:nil];
    
    [[FOSRESTConfig sharedInstance].cacheManager flushCaches:^(BOOL isCancelled, NSError *error) {        
        END_TEST
    }];
    
    WAIT_FOR_TEST_END
}

- (void)testSendingEventWithData {
    START_TEST
    
    [[FOSRESTConfig sharedInstance] trackEvent:@"TestDataEvent" withData:@{ @"MyData" : @(25) }];
    
    [[FOSRESTConfig sharedInstance].cacheManager flushCaches:^(BOOL isCancelled, NSError *error) {
        END_TEST
    }];
    
    WAIT_FOR_TEST_END
}

@end
