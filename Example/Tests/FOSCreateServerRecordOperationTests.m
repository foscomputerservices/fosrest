//
//  FOSCreateServerRecordOperationTests.m
//  FOSFoundation
//
//  Created by David Hunt on 4/10/14.
//  Copyright (c) 2014 FOS Computer Services. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "FOSFoundationTests.h"
#import "TestCreate.h"

@interface FOSCreateServerRecordOperationTests : XCTestCase

@end

@implementation FOSCreateServerRecordOperationTests

#pragma mark - Configuration

SETUP_TEARDOWN_NOLOGIN

#pragma mark - Tests

- (void)testSettingCMO {
    TestCreate *cmo = [[TestCreate alloc] init];

    FOSCreateServerRecordOperation *op = [FOSCreateServerRecordOperation createOperationForCMO:cmo
                                                                            withLifecycleStyle:nil];

    XCTAssertNotNil(op.cmo, @"Nil?");
    XCTAssertTrue([op.cmo.objectID isEqual:cmo.objectID], @"Wrong CMO?");
}

@end
