//
//  FOSRESTConfigTests.m
//  FOSREST
//
//  Created by David Hunt on 8/20/14.
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

#import <UIKit/UIKit.h>
#import <XCTest/XCTest.h>

#import "FOSRESTTests.h"
#import "FOSLoginManagerTests.h"

@interface FOSRESTConfigTests : XCTestCase

@end

@implementation FOSRESTConfigTests

#pragma mark - Test Configuration Methods

SETUP_TEARDOWN_LOGIN(FOSRESTConfigOptionsNone | FOSRESTConfigAutomaticallySynchronize)

#pragma mark - Tests

- (void)testRecoverFromForcingOffline {
    FOSRESTConfig *restConfig = [FOSRESTConfig sharedInstance];

    XCTAssertTrue(restConfig.networkStatus != FOSNetworkStatusNotReachable);

    // TODO : Restore when determine how to access private headers
    //    status.forceOffline = YES;

    XCTAssertTrue(restConfig.networkStatus == FOSNetworkStatusNotReachable);

    // TODO : Restore when determine how to access private headers
    //    status.forceOffline = NO;

    // iOS 8 Simulator -- This is currently broken as reachability says that updated status is offline *always*
    XCTAssertTrue(restConfig.networkStatus != FOSNetworkStatusNotReachable);
}

@end
