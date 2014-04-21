//
//  FOSOperationTests.m
//  FOSFoundation
//
//  Created by David Hunt on 11/11/13.
//  Copyright (c) 2013 FOS Computer Services. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "FOSFoundationTests.h"

typedef void (^FOSOpKVOHandler)(NSString *keyPath, id object, NSDictionary *change, void *context);

@interface FOSOperationTests : XCTestCase

@end

@implementation FOSOperationTests {
    FOSOpKVOHandler _kvoHandler;
}

#pragma mark - Configuration

SETUP_TEARDOWN_NOLOGIN

#pragma mark - Tests

- (void)testCancelKVO {
    FOSOperation *op = [[FOSOperation alloc] init];

    __block BOOL kvoHandlerCalled = NO;
    __block NSString *capturedKeyPath = nil;
    __block id capturedObject = nil;
    __block NSDictionary *capturedChange = nil;
    __block void *capturedContext = nil;

    _kvoHandler = ^void (NSString *keyPath, id object, NSDictionary *change, void *context) {
        kvoHandlerCalled = YES;
        capturedKeyPath = keyPath;
        capturedObject = object;
        capturedChange = change;
        capturedContext = context;
    };
    [op addObserver:self forKeyPath:@"isCancelled" options:0 context:nil];

    [op cancel];

    [op removeObserver:self forKeyPath:@"isCancelled"];

    XCTAssertTrue(kvoHandlerCalled, @"Handler not called?");
    XCTAssertNotNil(capturedKeyPath, @"No keyPath?");
    XCTAssertTrue([capturedKeyPath isEqualToString:@"isCancelled"], @"Wrong keyPath: %@",
                  capturedKeyPath);
    XCTAssertNotNil(capturedObject, @"No object");
    XCTAssertTrue(capturedObject == op, @"Wrong object!");
    XCTAssertTrue(capturedContext == NULL, @"Non-NULL context???");
}

- (void)testCancelDeps {
    START_TEST

    FOSOperation *op = [[FOSOperation alloc] init];

    __block BOOL bgHandlerCalled = NO;
    __block BOOL capturedCancelled = NO;
    __block NSError *capturedError;

    FOSBackgroundOperation *cancelOp = [FOSBackgroundOperation backgroundOperationWithRequest:^(BOOL cancelled, NSError *error) {
        [op cancel];
    }];

    FOSBackgroundOperation *bgOp = [FOSBackgroundOperation backgroundOperationWithRequest:^(BOOL cancelled, NSError *error) {

        bgHandlerCalled = YES;
        capturedCancelled = cancelled;
        capturedError = error;

        END_TEST
    } callRequestIfCancelled:YES];

    [cancelOp addDependency:op];
    [bgOp addDependency:cancelOp];

    // Queue the operations
    [[FOSRESTConfig sharedInstance].cacheManager queueOperation:bgOp
                                        withCompletionOperation:nil
                                                  withGroupName:@"Testing Cancellation"];

    WAIT_FOR_TEST_END

    XCTAssertTrue(bgHandlerCalled, @"Handler not called???");
    XCTAssertTrue(capturedCancelled, @"Not cancelled");
    XCTAssertNil(capturedError, @"Error???");
}

#pragma mark - KVO Methods

- (void)observeValueForKeyPath:(NSString *)keyPath
                      ofObject:(id)object
                        change:(NSDictionary *)change
                       context:(void *)context {
    if (_kvoHandler) {
        _kvoHandler(keyPath, object, change, context);
    }
}

@end
