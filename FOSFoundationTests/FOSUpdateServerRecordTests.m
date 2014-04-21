//
//  FOSUpdateServerRecordTests.m
//  FOSFoundation
//
//  Created by David Hunt on 4/10/14.
//  Copyright (c) 2014 FOS Computer Services. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "FOSFoundationTests.h"
#import "TestCreate.h"

@interface FOSUpdateServerRecordTests : XCTestCase

@end

@implementation FOSUpdateServerRecordTests

#pragma mark - Configuration

SETUP_TEARDOWN_NOLOGIN

#pragma mark - Tests

- (void)testSettingCMO {
    TestCreate *cmo = [[TestCreate alloc] init];

    FOSUpdateServerRecordOperation *op = [FOSUpdateServerRecordOperation updateOperationForCMO:cmo];

    XCTAssertNotNil(op.cmo, @"Nil?");
    XCTAssertTrue([op.cmo.objectID isEqual:cmo.objectID], @"Wrong CMO?");
}

@end
