//
//  NSError_FOS.m
//  FOSFoundation
//
//  Created by David Hunt on 11/5/13.
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
#import "FOSFoundation.h"

@interface NSError_FOS : XCTestCase

@end

@implementation NSError_FOS

static NSString *TestDomainName = @"__DoMaIn___";
static NSString *TestMessage = @"_MeSsAgE___***)))";
static NSInteger TestErrorCode = 45;
static NSDictionary *TestUserInfo = nil;

#pragma mark - Setup

- (void)setUp {
    [super setUp];

    if (TestUserInfo == nil) {
        TestUserInfo = @{ @"Foo" : @"Bar" };
    }
}

#pragma mark - Class Method Tests

- (void)testExtension1 {
    NSError *e = [NSError errorWithDomain:TestDomainName andMessage:TestMessage];

    XCTAssertTrue([e.domain isEqualToString:TestDomainName], @"Invalid domain!");
    XCTAssertTrue([e.localizedDescription isEqualToString:TestMessage], @"Invalid message!");
}

- (void)testExtension2 {
    NSError *e = [NSError errorWithDomain:TestDomainName
                                errorCode:TestErrorCode
                               andMessage:TestMessage];

    XCTAssertTrue([e.domain isEqualToString:TestDomainName], @"Invalid domain!");
    XCTAssertEqual(e.code, TestErrorCode, @"Invalid error code!");
    XCTAssertTrue([e.localizedDescription isEqualToString:TestMessage], @"Invalid message!");
}

- (void)testExtension3 {
    NSError *e = [NSError errorWithDomain:TestDomainName
                                message:TestMessage
                              andUserInfo:TestUserInfo];

    XCTAssertTrue([e.domain isEqualToString:TestDomainName], @"Invalid domain!");
    XCTAssertTrue([e.localizedDescription isEqualToString:TestMessage], @"Invalid message!");
    [self _assertUserInfo:e.userInfo];
}

- (void)testExtension4 {
    NSError *e = [NSError errorWithDomain:TestDomainName
                                errorCode:TestErrorCode
                                  message:TestMessage
                              andUserInfo:TestUserInfo];

    XCTAssertTrue([e.domain isEqualToString:TestDomainName], @"Invalid domain!");
    XCTAssertEqual(e.code, TestErrorCode, @"Invalid error code!");
    XCTAssertTrue([e.localizedDescription isEqualToString:TestMessage], @"Invalid message!");
    [self _assertUserInfo:e.userInfo];
}

#pragma mark - Private Methods

- (void)_assertUserInfo:(NSDictionary *)userInfo {
    for (NSString *nextKey in TestUserInfo) {
        XCTAssertEqual(userInfo[nextKey], TestUserInfo[nextKey],
                       @"Invalid UserInfo value '%@' for Key '%@', expected '%@'.",
                       userInfo[nextKey], nextKey, TestUserInfo[nextKey]);
    }
}

@end
