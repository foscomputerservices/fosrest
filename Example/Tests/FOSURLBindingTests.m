//
//  FOSURLBindingTests.m
//  FOSREST
//
//  Created by David Hunt on 3/17/14.
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
#import "FOSRESTTests.h"
#import "FOSREST.h"
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

// TODO : Restore when determine how to access private headers

#ifdef later
- (void)testSettingEntityDescription {
    FOSURLBinding *urlBinding = [[FOSURLBinding alloc] init];
    NSEntityDescription *entityDesc = [TestCreate entityDescription];
    id<FOSExpression> expr = [FOSConstantExpression constantExpressionWithValue:entityDesc];
    FOSItemMatcher *expectedResult = [FOSItemMatcher matcherMatchingItemExpression:expr];
    urlBinding.entityMatcher = expectedResult;

    XCTAssertTrue([urlBinding.entityMatcher isEqual:expectedResult], @"Bad result");
}
#endif

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

// TODO : Restore when determine how to access private headers
#ifdef later
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
#endif

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
    expectedHeaderFields[@"Accept"] = @"application/json";
    expectedHeaderFields[@"Content-Type"] = @"application/json; charset=UTF-8";

    urlBinding.serviceAdapter = adapter;

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
    expectedHeaderFields[@"Accept"] = @"application/json";
    expectedHeaderFields[@"Content-Type"] = @"application/json; charset=UTF-8";
    NSTimeInterval expectedTimeInterval = adapter.defaultTimeout;

    // Set overrides
    urlBinding.baseURL = baseURL;
    urlBinding.serviceAdapter = adapter;


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
    expectedHeaderFields[@"Accept"] = @"application/json";
    expectedHeaderFields[@"Content-Type"] = @"application/json; charset=UTF-8";
    NSTimeInterval expectedTimeInterval = adapter.defaultTimeout;

    // Set overrides
    urlBinding.requestMethod = FOSRequestMethodPUT;
    urlBinding.serviceAdapter = adapter;

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
    expectedHeaderFields[@"Accept"] = @"application/json";
    expectedHeaderFields[@"Content-Type"] = @"application/json; charset=UTF-8";
    expectedHeaderFields[@"X-Test"] = @"My Test";
    NSTimeInterval expectedTimeInterval = adapter.defaultTimeout;

    // Set overrides
    urlBinding.headerFields = @{ @"X-Test" : @"My Test" };
    urlBinding.serviceAdapter = adapter;

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
    expectedHeaderFields[@"Accept"] = @"application/json";
    expectedHeaderFields[@"Content-Type"] = @"application/json; charset=UTF-8";
    expectedHeaderFields[overrideKey] = @"My Test";
    NSTimeInterval expectedTimeInterval = adapter.defaultTimeout;

    // Set overrides
    urlBinding.headerFields = @{ overrideKey : @"My Test" };
    urlBinding.serviceAdapter = adapter;

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
    expectedHeaderFields[@"Accept"] = @"application/json";
    expectedHeaderFields[@"Content-Type"] = @"My Test";
    NSTimeInterval expectedTimeInterval = adapter.defaultTimeout;

    // Set overrides
    urlBinding.headerFields = @{ @"Content-Type" : @"My Test" };
    urlBinding.serviceAdapter = adapter;

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
    expectedHeaderFields[@"Accept"] = @"application/json";
    expectedHeaderFields[@"Content-Type"] = @"application/x-www-form-urlencoded; charset=UTF-8";
    NSTimeInterval expectedTimeInterval = adapter.defaultTimeout;

    // Set overrides
    urlBinding.requestFormat = FOSRequestFormatWebform;
    urlBinding.serviceAdapter = adapter;

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
    expectedHeaderFields[@"Accept"] = @"application/json";
    NSTimeInterval expectedTimeInterval = adapter.defaultTimeout;

    // Set overrides
    urlBinding.requestFormat = FOSRequestFormatNoData;
    urlBinding.serviceAdapter = adapter;

    NSURLRequest *result = [urlBinding urlRequestForCMO:cmo error:nil];
    XCTAssertNotNil(result, @"Bad result");

    XCTAssertTrue([result.URL isEqual:expectedURL], @"Bad URL");
    XCTAssertTrue([result.HTTPMethod isEqualToString:expectedHTTPMethod], @"Bad HTTPMethod");
    XCTAssertTrue([result.allHTTPHeaderFields isEqual:expectedHeaderFields], @"Bad header fields");
    XCTAssertEqual(result.timeoutInterval, expectedTimeInterval, @"Bad timeoutInterval");
}

@end
