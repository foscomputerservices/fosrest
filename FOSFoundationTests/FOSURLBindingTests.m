//
//  FOSURLBindingTests.m
//  FOSFoundation
//
//  Created by David Hunt on 3/17/14.
//  Copyright (c) 2014 FOS Computer Services. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "FOSFoundationTests.h"
#import "TestCreate.h"
#import "Widget.h"

@interface FOSURLBindingTests : XCTestCase

@end

@implementation FOSURLBindingTests

SETUP_TEARDOWN_NOLOGIN

#pragma mark - Test Property Settings

- (void)testDefaultBaseURL {
    FOSURLBinding *urlBinding = [[FOSURLBinding alloc] init];

    XCTAssertNil(urlBinding.baseURL, @"Bad result");
}

- (void)testSettingBaseURL {
    FOSURLBinding *urlBinding = [[FOSURLBinding alloc] init];
    urlBinding.baseURL = [FOSRESTConfig sharedInstance].restServiceAdapter.defaultBaseURL;
    NSURL *expectedResult = [FOSRESTConfig sharedInstance].restServiceAdapter.defaultBaseURL;

    XCTAssertTrue([urlBinding.baseURL isEqual:expectedResult], @"Bad result");
}

- (void)testSettingRequestMethod {
    FOSURLBinding *urlBinding = [[FOSURLBinding alloc] init];
    urlBinding.requestMethod = FOSRequestMethodDELETE;
    FOSRequestMethod expectedResult = FOSRequestMethodDELETE;

    XCTAssertTrue(urlBinding.requestMethod == expectedResult, @"Bad result");
}

- (void)testSettingEndPointURL {
    FOSURLBinding *urlBinding = [[FOSURLBinding alloc] init];
    FOSConcatExpression *expectedResult = [[FOSConcatExpression alloc] init];
    urlBinding.endPointURLExpression = expectedResult;

    XCTAssertTrue([urlBinding.endPointURLExpression isEqual:expectedResult], @"Bad result");
}

- (void)testDefaultHeaderFields {
    FOSURLBinding *urlBinding = [[FOSURLBinding alloc] init];

    XCTAssertNil(urlBinding.headerFields, @"Bad result");
}

- (void)testSettingHeaderFields {
    FOSURLBinding *urlBinding = [[FOSURLBinding alloc] init];
    NSDictionary *expectedResult = @{ @"x-test" : @"x-result" };
    urlBinding.headerFields = expectedResult;

    XCTAssertTrue([urlBinding.headerFields isEqual:expectedResult], @"Bad result");
}

- (void)testSettingTimeoutInterval {
    FOSURLBinding *urlBinding = [[FOSURLBinding alloc] init];
    NSTimeInterval expectedResult = 33.33f;
    urlBinding.timeoutInterval = expectedResult;

    XCTAssertEqual(urlBinding.timeoutInterval, expectedResult, @"Bad result");
}

- (void)testSettingRequestFormat {
    FOSURLBinding *urlBinding = [[FOSURLBinding alloc] init];
    FOSRequestFormat expectedResult = FOSRequestFormatNoData;
    urlBinding.requestFormat = expectedResult;

    XCTAssertEqual(urlBinding.requestFormat, expectedResult, @"Bad result");
}

- (void)testSettingEntityDescription {
    FOSURLBinding *urlBinding = [[FOSURLBinding alloc] init];
    NSEntityDescription *entityDesc = [TestCreate entityDescription];
    id<FOSExpression> expr = [FOSConstantExpression constantExpressionWithValue:entityDesc];
    FOSItemMatcher *expectedResult = [FOSItemMatcher matcherMatchingItemExpression:expr];
    urlBinding.entityMatcher = expectedResult;

    XCTAssertTrue([urlBinding.entityMatcher isEqual:expectedResult], @"Bad result");
}

#pragma mark - Test Methods

- (void)testNilError_Success {
    FOSURLBinding *urlBinding = [[FOSURLBinding alloc] init];

    // Set endPointURLExpression
    NSString *expectedEndPoint = @"1/classes/MyClass";
    FOSConstantExpression *endPointURLExpr =
        [FOSConstantExpression constantExpressionWithValue:expectedEndPoint];
    urlBinding.endPointURLExpression = endPointURLExpr;

    // Set entityMatcher
    id<FOSExpression> expr = [FOSConstantExpression constantExpressionWithValue:@"TestCreate"];
    urlBinding.entityMatcher = [FOSItemMatcher matcherMatchingItemExpression:expr];

    // CMO
    TestCreate *cmo = [[TestCreate alloc] init];

    NSURLRequest *result = [urlBinding urlRequestForCMO:cmo error:nil];
    XCTAssertNotNil(result, @"Bad result");
}

- (void)testNilError_Failure {
    FOSURLBinding *urlBinding = [[FOSURLBinding alloc] init];

    // Set endPointURLExpression
    FOSConcatExpression *endPointURLExpression = [[FOSConcatExpression alloc] init];
    NSString *expectedEndPoint = @"1/classes/MyClass";
    endPointURLExpression.expressions = @[ expectedEndPoint ];
    urlBinding.endPointURLExpression = endPointURLExpression;

    // Set entityMatcher
    id<FOSExpression> expr = [FOSConstantExpression constantExpressionWithValue:[Widget entityDescription]];
    urlBinding.entityMatcher = [FOSItemMatcher matcherMatchingItemExpression:expr];

    // CMO
    TestCreate *cmo = [[TestCreate alloc] init];

    NSURLRequest *result = [urlBinding urlRequestForCMO:cmo error:nil];
    XCTAssertNil(result, @"Bad result");
}

- (void)testNonNilError_Failure {
    FOSURLBinding *urlBinding = [[FOSURLBinding alloc] init];

    // Set endPointURLExpression
    FOSConcatExpression *endPointURLExpression = [[FOSConcatExpression alloc] init];
    NSString *expectedEndPoint = @"1/classes/MyClass";
    endPointURLExpression.expressions = @[ expectedEndPoint ];
    urlBinding.endPointURLExpression = endPointURLExpression;

    // Set entityMatcher
    id<FOSExpression> expr = [FOSConstantExpression constantExpressionWithValue:[Widget entityDescription]];
    urlBinding.entityMatcher = [FOSItemMatcher matcherMatchingItemExpression:expr];

    // CMO
    TestCreate *cmo = [[TestCreate alloc] init];

    NSError *error = nil;
    NSURLRequest *result = [urlBinding urlRequestForCMO:cmo error:&error];
    XCTAssertNil(result, @"Bad result");
    XCTAssertNotNil(error, @"Bad error");
}

- (void)testDefaultBinding {
    FOSURLBinding *urlBinding = [[FOSURLBinding alloc] init];

    // Set endPointURLExpression
    NSString *expectedEndPoint = @"1/classes/MyClass";
    FOSConstantExpression *endPointURLExpression =
        [FOSConstantExpression constantExpressionWithValue:expectedEndPoint];
    urlBinding.endPointURLExpression = endPointURLExpression;

    // Set entityMatcher
    id<FOSExpression> expr = [FOSConstantExpression constantExpressionWithValue:@"TestCreate"];
    urlBinding.entityMatcher = [FOSItemMatcher matcherMatchingItemExpression:expr];

    // CMO
    TestCreate *cmo = [[TestCreate alloc] init];

    id<FOSRESTServiceAdapter> adapter = [FOSRESTConfig sharedInstance].restServiceAdapter;
    NSURL *baseURL = adapter.defaultBaseURL;
    NSURL *expectedURL = [baseURL URLByAppendingPathComponent:expectedEndPoint];
    NSString *expectedHTTPMethod = @"GET";
    NSMutableDictionary *expectedHeaderFields = [adapter.headerFields mutableCopy];
    expectedHeaderFields[@"Content-Type"] = @"application/json; charset=UTF-8";

    NSTimeInterval expectedTimeInterval = adapter.defaultTimeout;

    NSURLRequest *result = [urlBinding urlRequestForCMO:cmo error:nil];
    XCTAssertNotNil(result, @"Bad result");

    XCTAssertTrue([result.URL isEqual:expectedURL], @"Bad URL");
    XCTAssertTrue([result.HTTPMethod isEqualToString:expectedHTTPMethod], @"Bad HTTPMethod");
    XCTAssertTrue([result.allHTTPHeaderFields isEqual:expectedHeaderFields], @"Bad header fields");
    XCTAssertEqual(result.timeoutInterval, expectedTimeInterval, @"Bad timeoutInterval");
}

- (void)testBaseURLOverride {
    FOSURLBinding *urlBinding = [[FOSURLBinding alloc] init];

    // Set endPointURLExpression
    NSString *expectedEndPoint = @"1/classes/MyClass";
    FOSConstantExpression *endPointURLExpression =
        [FOSConstantExpression constantExpressionWithValue:expectedEndPoint];
    urlBinding.endPointURLExpression = endPointURLExpression;

    // Set entityMatcher
    id<FOSExpression> expr = [FOSConstantExpression constantExpressionWithValue:@"TestCreate"];
    urlBinding.entityMatcher = [FOSItemMatcher matcherMatchingItemExpression:expr];

    // CMO
    TestCreate *cmo = [[TestCreate alloc] init];

    id<FOSRESTServiceAdapter> adapter = [FOSRESTConfig sharedInstance].restServiceAdapter;
    NSURL *baseURL = [NSURL URLWithString:@"https://api.example.com"];
    NSURL *expectedURL = [baseURL URLByAppendingPathComponent:expectedEndPoint];
    NSString *expectedHTTPMethod = @"GET";
    NSMutableDictionary *expectedHeaderFields = [adapter.headerFields mutableCopy];
    expectedHeaderFields[@"Content-Type"] = @"application/json; charset=UTF-8";
    NSTimeInterval expectedTimeInterval = adapter.defaultTimeout;

    // Set overrides
    urlBinding.baseURL = baseURL;

    NSURLRequest *result = [urlBinding urlRequestForCMO:cmo error:nil];
    XCTAssertNotNil(result, @"Bad result");

    XCTAssertTrue([result.URL isEqual:expectedURL], @"Bad URL");
    XCTAssertTrue([result.HTTPMethod isEqualToString:expectedHTTPMethod], @"Bad HTTPMethod");
    XCTAssertTrue([result.allHTTPHeaderFields isEqual:expectedHeaderFields], @"Bad header fields");
    XCTAssertEqual(result.timeoutInterval, expectedTimeInterval, @"Bad timeoutInterval");
}

- (void)testRequestMethodOverride {
    FOSURLBinding *urlBinding = [[FOSURLBinding alloc] init];

    // Set endPointURLExpression
    NSString *expectedEndPoint = @"1/classes/MyClass";
    FOSConstantExpression *endPointURLExpression =
        [FOSConstantExpression constantExpressionWithValue:expectedEndPoint];
    urlBinding.endPointURLExpression = endPointURLExpression;

    // Set entityMatcher
    id<FOSExpression> expr = [FOSConstantExpression constantExpressionWithValue:@"TestCreate"];
    urlBinding.entityMatcher = [FOSItemMatcher matcherMatchingItemExpression:expr];

    // CMO
    TestCreate *cmo = [[TestCreate alloc] init];

    id<FOSRESTServiceAdapter> adapter = [FOSRESTConfig sharedInstance].restServiceAdapter;
    NSURL *baseURL = adapter.defaultBaseURL;
    NSURL *expectedURL = [baseURL URLByAppendingPathComponent:expectedEndPoint];
    NSString *expectedHTTPMethod = @"PUT";
    NSMutableDictionary *expectedHeaderFields = [adapter.headerFields mutableCopy];
    expectedHeaderFields[@"Content-Type"] = @"application/json; charset=UTF-8";
    NSTimeInterval expectedTimeInterval = adapter.defaultTimeout;

    // Set overrides
    urlBinding.requestMethod = FOSRequestMethodPUT;

    NSURLRequest *result = [urlBinding urlRequestForCMO:cmo error:nil];
    XCTAssertNotNil(result, @"Bad result");

    XCTAssertTrue([result.URL isEqual:expectedURL], @"Bad URL");
    XCTAssertTrue([result.HTTPMethod isEqualToString:expectedHTTPMethod], @"Bad HTTPMethod");
    XCTAssertTrue([result.allHTTPHeaderFields isEqual:expectedHeaderFields], @"Bad header fields");
    XCTAssertEqual(result.timeoutInterval, expectedTimeInterval, @"Bad timeoutInterval");
}

- (void)testAdditionalHeaderFields {
    FOSURLBinding *urlBinding = [[FOSURLBinding alloc] init];

    // Set endPointURLExpression
    NSString *expectedEndPoint = @"1/classes/MyClass";
    FOSConstantExpression *endPointURLExpression =
        [FOSConstantExpression constantExpressionWithValue:expectedEndPoint];
    urlBinding.endPointURLExpression = endPointURLExpression;

    // Set entityMatcher
    id<FOSExpression> expr = [FOSConstantExpression constantExpressionWithValue:@"TestCreate"];
    urlBinding.entityMatcher = [FOSItemMatcher matcherMatchingItemExpression:expr];

    // CMO
    TestCreate *cmo = [[TestCreate alloc] init];

    id<FOSRESTServiceAdapter> adapter = [FOSRESTConfig sharedInstance].restServiceAdapter;
    NSURL *baseURL = adapter.defaultBaseURL;
    NSURL *expectedURL = [baseURL URLByAppendingPathComponent:expectedEndPoint];
    NSString *expectedHTTPMethod = @"GET";
    NSMutableDictionary *expectedHeaderFields = [adapter.headerFields mutableCopy];
    expectedHeaderFields[@"Content-Type"] = @"application/json; charset=UTF-8";
    expectedHeaderFields[@"X-Test"] = @"My Test";
    NSTimeInterval expectedTimeInterval = adapter.defaultTimeout;

    // Set overrides
    urlBinding.headerFields = @{ @"X-Test" : @"My Test" };

    NSURLRequest *result = [urlBinding urlRequestForCMO:cmo error:nil];
    XCTAssertNotNil(result, @"Bad result");

    XCTAssertTrue([result.URL isEqual:expectedURL], @"Bad URL");
    XCTAssertTrue([result.HTTPMethod isEqualToString:expectedHTTPMethod], @"Bad HTTPMethod");
    XCTAssertTrue([result.allHTTPHeaderFields isEqual:expectedHeaderFields], @"Bad header fields");
    XCTAssertEqual(result.timeoutInterval, expectedTimeInterval, @"Bad timeoutInterval");
}

- (void)testOverrideHeaderFields {
    FOSURLBinding *urlBinding = [[FOSURLBinding alloc] init];

    // Set endPointURLExpression
    NSString *expectedEndPoint = @"1/classes/MyClass";
    FOSConstantExpression *endPointURLExpression =
        [FOSConstantExpression constantExpressionWithValue:expectedEndPoint];
    urlBinding.endPointURLExpression = endPointURLExpression;

    // Set entityMatcher
    id<FOSExpression> expr = [FOSConstantExpression constantExpressionWithValue:@"TestCreate"];
    urlBinding.entityMatcher = [FOSItemMatcher matcherMatchingItemExpression:expr];

    // CMO
    TestCreate *cmo = [[TestCreate alloc] init];

    id<FOSRESTServiceAdapter> adapter = [FOSRESTConfig sharedInstance].restServiceAdapter;
    NSDictionary *headerFields = adapter.headerFields;
    NSString *overrideKey = headerFields.allKeys[0];
    NSURL *baseURL = adapter.defaultBaseURL;
    NSURL *expectedURL = [baseURL URLByAppendingPathComponent:expectedEndPoint];
    NSString *expectedHTTPMethod = @"GET";
    NSMutableDictionary *expectedHeaderFields = [adapter.headerFields mutableCopy];
    expectedHeaderFields[@"Content-Type"] = @"application/json; charset=UTF-8";
    expectedHeaderFields[overrideKey] = @"My Test";
    NSTimeInterval expectedTimeInterval = adapter.defaultTimeout;

    // Set overrides
    urlBinding.headerFields = @{ overrideKey : @"My Test" };

    NSURLRequest *result = [urlBinding urlRequestForCMO:cmo error:nil];
    XCTAssertNotNil(result, @"Bad result");

    XCTAssertTrue([result.URL isEqual:expectedURL], @"Bad URL");
    XCTAssertTrue([result.HTTPMethod isEqualToString:expectedHTTPMethod], @"Bad HTTPMethod");
    XCTAssertTrue([result.allHTTPHeaderFields isEqual:expectedHeaderFields], @"Bad header fields");
    XCTAssertEqual(result.timeoutInterval, expectedTimeInterval, @"Bad timeoutInterval");
}

- (void)testOverrideHeaderFields_ContentType {
    FOSURLBinding *urlBinding = [[FOSURLBinding alloc] init];

    // Set endPointURLExpression
    NSString *expectedEndPoint = @"1/classes/MyClass";
    FOSConstantExpression *endPointURLExpression =
        [FOSConstantExpression constantExpressionWithValue:expectedEndPoint];
    urlBinding.endPointURLExpression = endPointURLExpression;

    // Set entityMatcher
    id<FOSExpression> expr = [FOSConstantExpression constantExpressionWithValue:@"TestCreate"];
    urlBinding.entityMatcher = [FOSItemMatcher matcherMatchingItemExpression:expr];

    // CMO
    TestCreate *cmo = [[TestCreate alloc] init];

    id<FOSRESTServiceAdapter> adapter = [FOSRESTConfig sharedInstance].restServiceAdapter;
    NSURL *baseURL = adapter.defaultBaseURL;
    NSURL *expectedURL = [baseURL URLByAppendingPathComponent:expectedEndPoint];
    NSString *expectedHTTPMethod = @"GET";
    NSMutableDictionary *expectedHeaderFields = [adapter.headerFields mutableCopy];
    expectedHeaderFields[@"Content-Type"] = @"My Test";
    NSTimeInterval expectedTimeInterval = adapter.defaultTimeout;

    // Set overrides
    urlBinding.headerFields = @{ @"Content-Type" : @"My Test" };

    NSURLRequest *result = [urlBinding urlRequestForCMO:cmo error:nil];
    XCTAssertNotNil(result, @"Bad result");

    XCTAssertTrue([result.URL isEqual:expectedURL], @"Bad URL");
    XCTAssertTrue([result.HTTPMethod isEqualToString:expectedHTTPMethod], @"Bad HTTPMethod");
    XCTAssertTrue([result.allHTTPHeaderFields isEqual:expectedHeaderFields], @"Bad header fields");
    XCTAssertEqual(result.timeoutInterval, expectedTimeInterval, @"Bad timeoutInterval");
}

- (void)testRequestFormatOverride_Webform {
    FOSURLBinding *urlBinding = [[FOSURLBinding alloc] init];

    // Set endPointURLExpression
    NSString *expectedEndPoint = @"1/classes/MyClass";
    FOSConstantExpression *endPointURLExpression =
        [FOSConstantExpression constantExpressionWithValue:expectedEndPoint];
    urlBinding.endPointURLExpression = endPointURLExpression;

    // Set entityMatcher
    id<FOSExpression> expr = [FOSConstantExpression constantExpressionWithValue:@"TestCreate"];
    urlBinding.entityMatcher = [FOSItemMatcher matcherMatchingItemExpression:expr];

    // CMO
    TestCreate *cmo = [[TestCreate alloc] init];

    id<FOSRESTServiceAdapter> adapter = [FOSRESTConfig sharedInstance].restServiceAdapter;
    NSURL *baseURL = adapter.defaultBaseURL;
    NSURL *expectedURL = [baseURL URLByAppendingPathComponent:expectedEndPoint];
    NSString *expectedHTTPMethod = @"GET";
    NSMutableDictionary *expectedHeaderFields = [adapter.headerFields mutableCopy];
    expectedHeaderFields[@"Content-Type"] = @"application/x-www-form-urlencoded; charset=UTF-8";
    NSTimeInterval expectedTimeInterval = adapter.defaultTimeout;

    // Set overrides
    urlBinding.requestFormat = FOSRequestFormatWebform;

    NSURLRequest *result = [urlBinding urlRequestForCMO:cmo error:nil];
    XCTAssertNotNil(result, @"Bad result");

    XCTAssertTrue([result.URL isEqual:expectedURL], @"Bad URL");
    XCTAssertTrue([result.HTTPMethod isEqualToString:expectedHTTPMethod], @"Bad HTTPMethod");
    XCTAssertTrue([result.allHTTPHeaderFields isEqual:expectedHeaderFields], @"Bad header fields");
    XCTAssertEqual(result.timeoutInterval, expectedTimeInterval, @"Bad timeoutInterval");
}

- (void)testRequestFormatOverride_NoData {
    FOSURLBinding *urlBinding = [[FOSURLBinding alloc] init];

    // Set endPointURLExpression
    NSString *expectedEndPoint = @"1/classes/MyClass";
    FOSConstantExpression *endPointURLExpression =
        [FOSConstantExpression constantExpressionWithValue:expectedEndPoint];
    urlBinding.endPointURLExpression = endPointURLExpression;

    // Set entityMatcher
    id<FOSExpression> expr = [FOSConstantExpression constantExpressionWithValue:@"TestCreate"];
    urlBinding.entityMatcher = [FOSItemMatcher matcherMatchingItemExpression:expr];

    // CMO
    TestCreate *cmo = [[TestCreate alloc] init];

    id<FOSRESTServiceAdapter> adapter = [FOSRESTConfig sharedInstance].restServiceAdapter;
    NSURL *baseURL = adapter.defaultBaseURL;
    NSURL *expectedURL = [baseURL URLByAppendingPathComponent:expectedEndPoint];
    NSString *expectedHTTPMethod = @"GET";
    NSMutableDictionary *expectedHeaderFields = [adapter.headerFields mutableCopy];
    NSTimeInterval expectedTimeInterval = adapter.defaultTimeout;

    // Set overrides
    urlBinding.requestFormat = FOSRequestFormatNoData;

    NSURLRequest *result = [urlBinding urlRequestForCMO:cmo error:nil];
    XCTAssertNotNil(result, @"Bad result");

    XCTAssertTrue([result.URL isEqual:expectedURL], @"Bad URL");
    XCTAssertTrue([result.HTTPMethod isEqualToString:expectedHTTPMethod], @"Bad HTTPMethod");
    XCTAssertTrue([result.allHTTPHeaderFields isEqual:expectedHeaderFields], @"Bad header fields");
    XCTAssertEqual(result.timeoutInterval, expectedTimeInterval, @"Bad timeoutInterval");
}

@end
