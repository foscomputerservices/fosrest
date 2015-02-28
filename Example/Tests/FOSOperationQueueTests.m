//
//  FOSOperationQueueTests.m
//  FOSFoundation
//
//  Created by David Hunt on 2/1/14.
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
#import "FOSFoundationTests.h"
#import "FOSFoundation.h"
#import "TestCreate.h"
#import "User.h"

// TODO : Change FOSBackgroundRequest to return BOOL & error
@interface ErrorBackgroundOperation : FOSBackgroundOperation

@end

@implementation ErrorBackgroundOperation

- (NSError *)error {
    NSError *result = [NSError errorWithDomain:@"FOSTest" andMessage:@"Injected error"];

    return result;
}

@end

@interface FOSOperationQueueTests : XCTestCase

@end

@implementation FOSOperationQueueTests

#pragma mark - Configuration

SETUP_TEARDOWN_LOGIN(FOSRESTConfigOptionsNone)

#pragma mark - Tests

- (void)testRollback {
    START_TEST

    __block NSManagedObjectID *testID = nil;

    FOSBackgroundOperation *bgOp = [ErrorBackgroundOperation backgroundOperationWithRequest:^(BOOL cancelled, NSError *error) {

        TestCreate *test = [[TestCreate alloc] init];
        test.name = @"Delete me!!!";
        test.user = (User *)[FOSRESTConfig sharedInstance].loginManager.loggedInUser;

        NSManagedObjectContext *moc = test.managedObjectContext;

        NSError *localError = nil;
        XCTAssertTrue([moc obtainPermanentIDsForObjects:@[ test ] error:&localError],
                      @"Cannot obtain perm id: %@", localError.description);

        testID = test.objectID;
    }];

    FOSBackgroundOperation *checkOp = [FOSBackgroundOperation backgroundOperationWithRequest:^(BOOL cancelled, NSError *error) {
        XCTAssertFalse(cancelled, @"Cancelled??");
        XCTAssertNotNil(error, @"No error?");

        NSManagedObjectContext *moc = [[[FOSRESTConfig sharedInstance] databaseManager] currentMOC];

        NSError *localError = nil;
        NSManagedObject *tc = [moc existingObjectWithID:testID error:&localError];

        XCTAssertNil(tc, @"Should NOT have retrieved an instance!");
        XCTAssertNotNil(localError, @"Should have received an error!");

        END_TEST
    }];

    [[[FOSRESTConfig sharedInstance] cacheManager] queueOperation:bgOp
                                          withCompletionOperation:checkOp
                                                    withGroupName:@"Check Rollback"];

    WAIT_FOR_TEST_END
}

@end
