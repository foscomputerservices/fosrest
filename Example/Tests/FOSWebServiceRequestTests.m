//
//  FOSWebServiceRequestTests.m
//  FOSREST
//
//  Created by David Hunt on 1/5/13.
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

#import "FOSWebServiceRequestTests.h"
#import "FOSRESTTests.h"
#import "FOSREST.h"

@implementation FOSWebServiceRequestTests

#pragma mark - Configuration

SETUP_TEARDOWN_NOLOGIN

#pragma mark - Success Tests

// TODO : Restore when determine how to access private headers
#ifdef later
- (void)testSuccessfulURLBinding {
    START_TEST

    FOSURLBinding *urlBinding = [self _userURLBinding];
    NSEntityDescription *entity = [FOSParseUser entityDescription];
    NSError *error = nil;

    NSURLRequest *urlRequest = [urlBinding urlRequestServerRecordOfType:entity
                                                             withJsonId:@"bMjY1bcxHP"
                                                           withDSLQuery:nil
                                                                  error:&error];

    XCTAssertNotNil(urlRequest, @"Null urlRequest???");

    FOSWebServiceRequest *request = [FOSWebServiceRequest requestWithURLRequest:urlRequest
                                                                  forURLBinding:urlBinding];
    __block FOSWebServiceRequest *blockRequest = request;

    request.completionBlock = ^{

        // If this fails, check for UID 'bMjY1bcxHP' in parse.com's user test table
        XCTAssertNil(blockRequest.error, @"Should have succeeded! Received error: %@", blockRequest.error.description);
        XCTAssertFalse(blockRequest.isCancelled, @"Cancelled?");
        XCTAssertFalse(blockRequest.isExecuting, @"Executing???");
        XCTAssertNotNil(blockRequest.jsonResult, @"No real data?");

        END_TEST
    };

    [[FOSRESTConfig sharedInstance].cacheManager queueOperation:request
                                        withCompletionOperation:nil
                                                  withGroupName:@"TEST: testSuccessfulGETCall"];

    WAIT_FOR_TEST_END
}

- (void)testErrorURLBinding {
    START_TEST

    FOSURLBinding *urlBinding = [self _userURLBinding];
    NSEntityDescription *entity = [FOSParseUser entityDescription];
    NSError *error = nil;

    NSURLRequest *urlRequest = [urlBinding urlRequestServerRecordOfType:entity
                                                             withJsonId:@"__badUID__"
                                                           withDSLQuery:nil
                                                                  error:&error];

    FOSWebServiceRequest *request = [FOSWebServiceRequest requestWithURLRequest:urlRequest
                                                                  forURLBinding:urlBinding];
    __block FOSWebServiceRequest *blockRequest = request;

    request.completionBlock = ^{
        XCTAssertNotNil(blockRequest.error, @"Should have failed!");
        XCTAssertFalse(blockRequest.isCancelled, @"Cancelled?");
        XCTAssertFalse(blockRequest.isExecuting, @"Executing???");
        XCTAssertNil(blockRequest.jsonResult, @"Real data?");

        END_TEST
    };

    [[FOSRESTConfig sharedInstance].cacheManager queueOperation:request
                                        withCompletionOperation:nil
                                                  withGroupName:@"TEST: testErrorGETCall"];

    WAIT_FOR_TEST_END
}

- (void)testOfflineCancellation {
    START_TEST

    FOSURLBinding *urlBinding = [self _userURLBinding];
    NSEntityDescription *entity = [FOSParseUser entityDescription];
    NSError *error = nil;

    NSURLRequest *urlRequest = [urlBinding urlRequestServerRecordOfType:entity
                                                             withJsonId:@"bMjY1bcxHP"
                                                           withDSLQuery:nil
                                                                  error:&error];

    FOSWebServiceRequest *request = [FOSWebServiceRequest requestWithURLRequest:urlRequest
                                                                  forURLBinding:urlBinding];
    __block FOSWebServiceRequest *blockRequest = request;

    request.completionBlock = ^{
        // We were offline, so it should be canceled, not an error
        XCTAssertNil(blockRequest.error, @"Should not have failed!");
        XCTAssertTrue(blockRequest.isCancelled, @"Not Cancelled?");
        XCTAssertFalse(blockRequest.isExecuting, @"Executing???");
        XCTAssertNil(blockRequest.jsonResult, @"Real data?");

        [FOSLoginManagerTests networkStatusMonitor].forceOffline = NO;

        END_TEST
    };

    [FOSLoginManagerTests networkStatusMonitor].forceOffline = YES;

    [[FOSRESTConfig sharedInstance].cacheManager queueOperation:request
                                        withCompletionOperation:nil
                                                  withGroupName:@"TEST: testErrorGETCall"];

    WAIT_FOR_TEST_END
}

#pragma mark - Will Process Handler Tests

- (void)testSuccessfulWillProcessHandler {
    START_TEST
    NSString *uid = @"_my_madeup_id";

    User *existingUser = [[User alloc] init];
    existingUser.objectId = uid;

    FOSURLBinding *urlBinding = [self _userURLBinding];
    NSEntityDescription *entity = [FOSParseUser entityDescription];
    NSError *error = nil;

    NSURLRequest *urlRequest = [urlBinding urlRequestServerRecordOfType:entity
                                                             withJsonId:uid
                                                           withDSLQuery:nil
                                                                  error:&error];

    FOSWebServiceRequest *request = [FOSWebServiceRequest requestWithURLRequest:urlRequest
                                                                  forURLBinding:urlBinding];
    request.willProcessHandler =  ^{
        return existingUser.objectID;
    };

    __block FOSWebServiceRequest *blockRequest = request;
    request.completionBlock = ^{
        XCTAssertNil(blockRequest.error, @"Should have succeeded!");
        XCTAssertFalse(blockRequest.isCancelled, @"Cancelled?");
        XCTAssertFalse(blockRequest.isExecuting, @"Executing???");
        XCTAssertNotNil(blockRequest.jsonResult, @"No real data?");

        XCTAssertEqualObjects(blockRequest.jsonResult,
                              existingUser.objectID,
                              @"Didn't get our object???");

        END_TEST
    };

    [[FOSRESTConfig sharedInstance].cacheManager queueOperation:request
                                        withCompletionOperation:nil
                                                  withGroupName:@"TEST: testSuccessfulWillProceessHandler"];

    WAIT_FOR_TEST_END
}
#endif

#pragma mark - Private Methods

- (FOSURLBinding *)_userURLBinding {
    FOSItemMatcher *entityMatcher = [FOSItemMatcher matcherMatchingAllItems];
    FOSConstantExpression *expr1 = [FOSConstantExpression constantExpressionWithValue:@"1/users/"];
    FOSVariableExpression *expr2 = [FOSVariableExpression variableExpressionWithIdentifier:@"CMOID"];
    NSArray *exprs = @[ expr1, expr2 ];

    id<FOSExpression> expr = [FOSConcatExpression concatExpressionWithExpressions:exprs];
    FOSURLBinding *urlBinding = [FOSURLBinding bindingForLifeCyclePhase:FOSLifecyclePhaseRetrieveServerRecord
                                                               endPoint:expr
                                                          requestFormat:FOSRequestFormatNoData
                                                       andEntityMatcher:entityMatcher];

    urlBinding.serviceAdapter = [FOSRESTConfig sharedInstance].restServiceAdapter;

    return urlBinding;
}

@end
