//
//  FOSOperationQueueTests.m
//  FOSFoundation
//
//  Created by David Hunt on 2/1/14.
//  Copyright (c) 2014 FOS Computer Services. All rights reserved.
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
