//
//  NSError_FOS.m
//  FOSFoundation
//
//  Created by David Hunt on 11/5/13.
//  Copyright (c) 2013 FOS Computer Services. All rights reserved.
//

#import <XCTest/XCTest.h>
@import FOSFoundation;

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
