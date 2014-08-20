//
//  FOSRESTConfigTests.m
//  FOSFoundation
//
//  Created by David Hunt on 8/20/14.
//  Copyright (c) 2014 FOS Computer Services. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <XCTest/XCTest.h>

#import "FOSFoundationTests.h"
#import "FOSLoginManagerTests.h"
#import "FOSNetworkStatusMonitor_FOS_Internal.h"

@interface FOSRESTConfigTests : XCTestCase

@end

@implementation FOSRESTConfigTests

#pragma mark - Test Configuration Methods

SETUP_TEARDOWN_LOGIN(FOSRESTConfigOptionsNone | FOSRESTConfigAutomaticallySynchronize)

#pragma mark - Tests

- (void)testRecoverFromForcingOffline {
    FOSNetworkStatusMonitor *status = [FOSLoginManagerTests networkStatusMonitor];
    FOSRESTConfig *restConfig = [FOSRESTConfig sharedInstance];

    XCTAssertTrue(restConfig.networkStatus != FOSNetworkStatusNotReachable);

    status.forceOffline = YES;

    XCTAssertTrue(restConfig.networkStatus == FOSNetworkStatusNotReachable);

    status.forceOffline = NO;

    // iOS 8 Simulator -- This is currently broken as reachability says that updated status is offline *always*
    XCTAssertTrue(restConfig.networkStatus != FOSNetworkStatusNotReachable);
}

@end
