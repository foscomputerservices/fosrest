//
//  FOSCMOReadOnlyStaticTableTests.m
//  FOSFoundation
//
//  Created by David Hunt on 11/6/13.
//  Copyright (c) 2013 FOS Computer Services. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "FOSCachedManagedObjectTests.h"
#import "FOSFoundationTests.h"
#import "FOSFoundation.h"
#import "NSObject+Tests.h"
#import "Note.h"
#import "TestCreate.h"
#import "User.h"
#import "Widget.h"
#import "Role.h"

@interface FOSCMOReadOnlyStaticTableTests : XCTestCase

@end

@implementation FOSCMOReadOnlyStaticTableTests

SETUP_TEARDOWN_LOGIN(FOSRESTConfigOptionsNone)

// NOTE: Sadly, if there are any breakpoints set in the debugger the debugger will
//       top on each exception and you'll have to manually click continue...
- (void)testCreateStaticObjectFails {
    XCTAssertThrowsSpecificNamed([[Role alloc] init], NSException, @"FOSFoundation",
                                 @"Should not be able to create static object instances!");
}

- (void)testCopyStaticObjectFails {
    NSArray *roles = [Role fetchAll];
    XCTAssertTrue(roles.count > 0, @"No roles???");

    Role *aRole = roles.lastObject;

    XCTAssertThrowsSpecificNamed([aRole copy], NSException, @"FOSFoundation",
                                 @"Should not be able to copy static object instances!");
}

@end
