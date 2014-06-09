//
//  FOSWebServiceRequestTests.m
//  FOSFoundation
//
//  Created by David Hunt on 1/5/13.
//  Copyright (c) 2013 FOS Computer Services. All rights reserved.
//

#import "FOSWebServiceRequestTests.h"
#import "FOSFoundationTests.h"
#import "FOSNetworkStatusMonitor_FOS_Internal.h"

@implementation FOSWebServiceRequestTests

#pragma mark - Configuration

SETUP_TEARDOWN_NOLOGIN

#pragma mark - Success Tests

- (void)testSuccessfulURLBinding {
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

        // If this fails, check for UID 'bMjY1bcxHP' in parse.com's user test table
        XCTAssertNil(blockRequest.error, @"Should have succeeded!");
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
    return urlBinding;
}

@end
