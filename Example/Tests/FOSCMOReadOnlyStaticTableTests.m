//
//  FOSCMOReadOnlyStaticTableTests.m
//  FOSREST
//
//  Created by David Hunt on 11/6/13.
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

#import <XCTest/XCTest.h>
#import "FOSCachedManagedObjectTests.h"
#import "FOSRESTTests.h"
#import "FOSREST.h"
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
//       stop on each exception and you'll have to manually click continue...
- (void)testCreateStaticObjectFails {
    XCTAssertThrowsSpecificNamed([[Role alloc] init], NSException, @"FOSREST",
                                 @"Should not be able to create static object instances!");
}

- (void)testCopyStaticObjectFails {
    NSArray *roles = [Role fetchAll];
    XCTAssertTrue(roles.count > 0, @"No roles???");

    Role *aRole = roles.lastObject;

    XCTAssertThrowsSpecificNamed([aRole copy], NSException, @"FOSREST",
                                 @"Should not be able to copy static object instances!");
}

@end
