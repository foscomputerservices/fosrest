//
//  FOSCMOWriteableStaticTableTests.m
//  FOSFoundation
//
//  Created by David Hunt on 11/6/13.
//  Copyright (c) 2013 FOS Computer Services. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "FOSCachedManagedObjectTests.h"
#import "FOSFoundationTests.h"
#import "FOSFoundation.h"
#import "FOSLoginManagerTests.h"
#import "FOSPullStaticTablesOperation.h"
#import "FOSRefreshUserOperation.h"
#import "NSObject+Tests.h"
#import "Note.h"
#import "TestCreate.h"
#import "User.h"
#import "Widget.h"
#import "Role.h"

@interface FOSCMOWriteableStaticTableTests : XCTestCase

@end

@implementation FOSCMOWriteableStaticTableTests

SETUP_TEARDOWN_LOGIN(FOSRESTConfigAllowStaticTableModifications)

- (void)testCreateStaticObject {
    XCTAssertNoThrowSpecificNamed([[Role alloc] init], NSException, @"FOSFoundation",
                                  @"Should not be able to create static object instances!");
}

- (void)testCopyStaticObject {
    NSArray *roles = [Role fetchAll];
    XCTAssertTrue(roles.count > 0, @"No roles???");

    Role *aRole = roles.lastObject;

    XCTAssertNoThrowSpecificNamed([aRole copy], NSException, @"FOSFoundation",
                                  @"Should not be able to copy static object instances!");
}

@end
