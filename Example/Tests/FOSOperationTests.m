//
//  FOSOperationTests.m
//  FOSREST
//
//  Created by David Hunt on 11/11/13.
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
#import "FOSRest.h"

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
    START_TEST

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

    FOSBackgroundOperation *cancelItOp = [FOSBackgroundOperation backgroundOperationWithRequest:^(BOOL cancelled, NSError *error) {
        [op cancel];

        END_TEST
    }];

    [[FOSRESTConfig sharedInstance].cacheManager queueOperation:cancelItOp withCompletionOperation:op withGroupName:@"Cancel It"];

    WAIT_FOR_TEST_END

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

- (void)testQueueErrorOp1 {
    START_TEST

    FOSOperation *op = [[FOSOperation alloc] init];
    NSError *error = [NSError errorWithMessage:@"Epic Fail!"];
    [op setError:error];

    XCTAssertNotNil(op.error, @"Setting error didn't take!");

    __block BOOL bgHandlerCalled = NO;
    __block BOOL capturedCancelled = NO;
    __block NSError *capturedError;

    FOSBackgroundOperation *finalOp = [FOSBackgroundOperation backgroundOperationWithRequest:^(BOOL cancelled, NSError *error) {

        bgHandlerCalled = YES;
        capturedCancelled = cancelled;
        capturedError = error;

        END_TEST
    } callRequestIfCancelled:YES];

    [finalOp addDependency:op];

    // Queue the operations
    [[FOSRESTConfig sharedInstance].cacheManager queueOperation:finalOp
                                        withCompletionOperation:nil
                                                  withGroupName:@"Testing Queueing Pre-Errored Op"];

    WAIT_FOR_TEST_END

    XCTAssertTrue(bgHandlerCalled, @"Handler not called???");
    XCTAssertFalse(capturedCancelled, @"Cancelled??");
    XCTAssertNotNil(capturedError, @"No Error???");
}

- (void)testQueueErrorOp2 {
    START_TEST

    FOSOperation *op = [[FOSOperation alloc] init];
    NSError *error = [NSError errorWithMessage:@"Epic Fail!"];
    [op setError:error];

    XCTAssertNotNil(op.error, @"Setting error didn't take!");

    __block BOOL bgHandlerCalled = NO;
    __block BOOL capturedCancelled = NO;
    __block NSError *capturedError;

    FOSBackgroundOperation *finalOp = [FOSBackgroundOperation backgroundOperationWithRequest:^(BOOL cancelled, NSError *error) {

        bgHandlerCalled = YES;
        capturedCancelled = cancelled;
        capturedError = error;

        END_TEST
    } callRequestIfCancelled:YES];

    // Queue the operations
    [[FOSRESTConfig sharedInstance].cacheManager queueOperation:op
                                        withCompletionOperation:finalOp
                                                  withGroupName:@"Testing Queueing Pre-Errored Op"];

    WAIT_FOR_TEST_END

    XCTAssertTrue(bgHandlerCalled, @"Handler not called???");
    XCTAssertFalse(capturedCancelled, @"Cancelled??");
    XCTAssertNotNil(capturedError, @"No Error???");
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
