//
//  FOSSendServerRecordOperationTests.m
//  FOSFoundation
//
//  Created by David Hunt on 4/10/14.
//  Copyright (c) 2014 FOS Computer Services. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "FOSFoundationTests.h"
#import "TestCreate.h"

@interface FOSSendServerRecordOperationTests : XCTestCase

@end

@implementation FOSSendServerRecordOperationTests

#pragma mark - Configuration

SETUP_TEARDOWN_NOLOGIN

#pragma mark - Tests

- (void)testSettingCMO {
    TestCreate *cmo = [[TestCreate alloc] init];

    FOSSendServerRecordOperation *op = [[FOSSendServerRecordOperation alloc] initWithCMO:cmo forLifecyclePhase:FOSLifecyclePhaseCreateServerRecord];

    XCTAssertNotNil(op.cmo, @"Nil?");
    XCTAssertTrue([op.cmo.objectID isEqual:cmo.objectID], @"Wrong CMO?");
    XCTAssertTrue(op.lifecyclePhase == FOSLifecyclePhaseCreateServerRecord, @"Wrong phase???");
}

@end
