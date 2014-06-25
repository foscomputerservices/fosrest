//
//  FOSCachedManagedObjectTests.m
//  FOSFoundation
//
//  Created by David Hunt on 12/28/12.
//  Copyright (c) 2012 FOS Computer Services. All rights reserved.
//

#import "FOSCachedManagedObjectTests.h"
#import "FOSFoundationTests.h"
#import "FOSFoundation.h"
#import "FOSLoginManagerTests.h"
#import "FOSPullStaticTablesOperation.h"
#import "FOSRefreshUserOperation.h"
#import "FOSRelationshipFault+FOS_Internal.h"
#import "FOSNetworkStatusMonitor_FOS_Internal.h"
#import "NSObject+Tests.h"
#import "Note.h"
#import "TestCreate.h"
#import "User.h"
#import "Widget.h"
#import "WidgetInfo.h"
#import "WidgetSearchOperation.h"
#import "Role.h"
#import "TestToMany+VBM.h"
#import "TestToManyDestMax.h"
#import "TestToManyDestMin.h"
#import "TestToManySearchOperation.h"

typedef void (^EmptyHandler)();

@implementation FOSCachedManagedObjectTests

#pragma mark - Test Configuration Methods

- (void)setUp {
    START_TEST

    [super setUp];

    [FOSLoginManagerTests setupStandardWebServiceConfigAndLogInWithOptions:FOSRESTConfigAllowStaticTableModifications /*| FOSRESTConfigAutomaticallySynchronize*/ andCallback:^{

        // Start the tests off by making sure that all TestCreate instances have been deleted.
        // NOTE: This is a bit of a chicken and egg issue as we're using the delete functionality
        //       to ensure that the start of the tests is in a stable state.
        User *localUser = (User *)([FOSRESTConfig sharedInstance].loginManager.loggedInUser);
        BOOL deleted = NO;
        id<NSFastEnumeration> creationsToDelete = [localUser.testCreations copy];
        for (TestCreate *nextTestCreate in creationsToDelete) {

            nextTestCreate.user = nil;
            [localUser removeTestCreationsObject:nextTestCreate];

            [nextTestCreate.managedObjectContext deleteObject:nextTestCreate];

            deleted = YES;
        }

        [[[FOSRESTConfig sharedInstance] databaseManager] saveChanges];

        if (deleted) {
            [[FOSRESTConfig sharedInstance].cacheManager flushCaches:^(BOOL cancelled, NSError *error) {
                END_TEST
            }];
        }
        else {
            END_TEST
        }
    }];

    WAIT_FOR_TEST_END
}

TEARDOWN_LOGIN

#pragma mark - Fetch Tests

- (void)testFetchWithId {
    START_TEST

    NSString *testWidgetId = @"8S6wb8n79J";
    User *loggedInUser = self.loggedInUser;
//    __block FOSCachedManagedObjectTests *blockSelf = self;

    // Fire fault
    NSOrderedSet *widgets = loggedInUser.widgets;
    BOOL found = NO;
    for (Widget *nextWidget in widgets) {
        if ([nextWidget.objectId isEqualToString:testWidgetId]) {
            found = YES;
            break;
        }
    }

    if (found) {
        Widget *widget = [Widget fetchWithId:testWidgetId];
        XCTAssertNotNil(widget, @"Unable to retrieve a widget");

        END_TEST
    }

    // Wait for fault to finish filling
    else {
        XCTAssertTrue(NO, @"Faulting not implemented!");

//        [loggedInUser addObserver:self forKeyPath:@"widgets" options:0 context:(void *)^{
//
//            [blockSelf.loggedInUser removeObserver:blockSelf forKeyPath:@"widgets"];
//
//            // NOTE: If this test fails, it could simply be that the widget object 'widget1' was
//            //       accidentally removed (or re-created) on parse.com.  Check that this id
//            //       matches a row in the Widget table on parse.com.
//            Widget *widget = [Widget fetchWithId:testWidgetId];
//            XCTAssertNotNil(widget, @"Unable to retrieve a widget");

            END_TEST
//        }];
    }
    
    WAIT_FOR_TEST_END
}

#pragma mark - Create Tests

- (void)testCreate {
    START_TEST

    TestCreate *testCreate = [[TestCreate alloc] init];
    XCTAssertTrue(testCreate.isFaultObject, @"Instances are faults by default.");

    testCreate.name = @"New Name";
    XCTAssertFalse(testCreate.isFaultObject, @"A property has been set, it's no longer a fault.");

    testCreate.user = self.loggedInUser;
    [self.loggedInUser addTestCreationsObject:testCreate];

    [[FOSRESTConfig sharedInstance].databaseManager saveChanges];

    [[FOSRESTConfig sharedInstance].cacheManager flushCaches:^(BOOL isCancelled, NSError *error) {
        XCTAssertTrue([NSThread isMainThread], @"Wrong thread!");
        XCTAssertFalse(isCancelled, @"Operation cancelled???");
        XCTAssertNil(error, @"Error received: %@", error.description);
        XCTAssertNotNil(testCreate.objectId, @"No web service id.");
        XCTAssertTrue(testCreate.hasBeenUploadedToServer, @"Why not uploaded?");
        XCTAssertTrue(testCreate.propertiesModifiedSinceLastUpload.count == 0, @"Modified?");

        END_TEST
    }];

    WAIT_FOR_TEST_END
}

- (void)testNewCreate {
    START_TEST

    TestCreate *testCreate = [[TestCreate alloc] init];
    XCTAssertTrue(testCreate.isFaultObject, @"Instances are faults by default.");

    testCreate.name = @"New Name";
    XCTAssertFalse(testCreate.isFaultObject, @"A property has been set, it's no longer a fault.");

    testCreate.user = self.loggedInUser;
    [self.loggedInUser addTestCreationsObject:testCreate];

    // TODO : For now we must save the record for things to work in the createOp.  That is,
    //        the createOp will use the objectID to locate the entity after execution and
    //        opQueue MOCs will not be able to locate the instance unless it's saved.
    [[FOSRESTConfig sharedInstance].databaseManager saveChanges];

    FOSSendServerRecordOperation *createOp = [testCreate sendServerRecordWithLifecycleStyle:nil];

    XCTAssertTrue([createOp isKindOfClass:[FOSCreateServerRecordOperation class]], @"Wrong type!");

    FOSBackgroundOperation *finalOp = [FOSBackgroundOperation backgroundOperationWithMainThreadRequest:^(BOOL cancelled, NSError *error) {
        XCTAssertTrue([NSThread isMainThread], @"Wrong thread!");
        XCTAssertFalse(cancelled, @"Operation cancelled???");
        XCTAssertNil(error, @"Error received: %@", error.description);
        XCTAssertNotNil(testCreate.objectId, @"No web service id.");
        XCTAssertTrue(testCreate.hasBeenUploadedToServer, @"Why not uploaded?");
        XCTAssertTrue(testCreate.propertiesModifiedSinceLastUpload.count == 0, @"Modified?");
        XCTAssertFalse(testCreate.isDirty, @"Why is this entity dirty?");

        END_TEST
    }];

    [[FOSRESTConfig sharedInstance].cacheManager queueOperation:createOp
                                        withCompletionOperation:finalOp
                                                  withGroupName:@"Test create"];

    WAIT_FOR_TEST_END
}

- (void)testNewCreateWithOwnedToManyRel {
    START_TEST

    TestCreate *testCreate = [[TestCreate alloc] init];
    XCTAssertTrue(testCreate.isFaultObject, @"Instances are faults by default.");

    testCreate.name = @"New Name";
    XCTAssertFalse(testCreate.isFaultObject, @"A property has been set, it's no longer a fault.");

    testCreate.user = self.loggedInUser;
    [self.loggedInUser addTestCreationsObject:testCreate];

    Note *note = [[Note alloc] init];
    note.note = @"Test Note";
    note.testCreate = testCreate;

    // TODO : For now we must save the record for things to work in the createOp.  That is,
    //        the createOp will use the objectID to locate the entity after execution and
    //        opQueue MOCs will not be able to locate the instance unless it's saved.
    //
    // http://fosmain.foscomputerservices.com:8080/browse/FF-4
    [[FOSRESTConfig sharedInstance].databaseManager saveChanges];

    FOSSendServerRecordOperation *createOp = [testCreate sendServerRecordWithLifecycleStyle:nil];

    XCTAssertTrue([createOp isKindOfClass:[FOSCreateServerRecordOperation class]], @"Wrong type!");

    FOSBackgroundOperation *finalOp = [FOSBackgroundOperation backgroundOperationWithMainThreadRequest:^(BOOL cancelled, NSError *error) {
        XCTAssertTrue([NSThread isMainThread], @"Wrong thread!");
        XCTAssertFalse(cancelled, @"Operation cancelled???");
        XCTAssertNil(error, @"Error received: %@", error.description);

        // Was the TestCreate Object saved?
        XCTAssertNotNil(testCreate.objectId, @"No web service id?");
        XCTAssertTrue(testCreate.hasBeenUploadedToServer, @"Why not uploaded?");
        XCTAssertTrue(testCreate.propertiesModifiedSinceLastUpload.count == 0, @"Modified?");
        XCTAssertFalse(testCreate.isDirty, @"Why is this entity dirty?");

        // Was the Note Object saved?
        XCTAssertNotNil(note.objectId, @"No web service id?");
        XCTAssertTrue(note.hasBeenUploadedToServer, @"Why not uploaded?");
        XCTAssertTrue(note.propertiesModifiedSinceLastUpload.count == 0, @"Modified?");
        XCTAssertFalse(note.isDirty, @"Why is this entity dirty?");

        END_TEST
    }];

    [[FOSRESTConfig sharedInstance].cacheManager queueOperation:createOp
                                        withCompletionOperation:finalOp
                                                  withGroupName:@"Test create"];
    
    WAIT_FOR_TEST_END
}

- (void)testNewCreateWithToOneRel {
    START_TEST

    Widget *newWidget = [[Widget alloc] init];
    newWidget.name = @"New Name";
    newWidget.widgetInfo = [WidgetInfo fetchAll].lastObject;
    newWidget.user = self.loggedInUser;

    // TODO : For now we must save the record for things to work in the createOp.  That is,
    //        the createOp will use the objectID to locate the entity after execution and
    //        opQueue MOCs will not be able to locate the instance unless it's saved.
    [[FOSRESTConfig sharedInstance].databaseManager saveChanges];

    FOSSendServerRecordOperation *createOp = [newWidget sendServerRecordWithLifecycleStyle:nil];

    XCTAssertTrue([createOp isKindOfClass:[FOSCreateServerRecordOperation class]], @"Wrong type!");

    FOSBackgroundOperation *finalOp = [FOSBackgroundOperation backgroundOperationWithMainThreadRequest:^(BOOL cancelled, NSError *error) {
        XCTAssertTrue([NSThread isMainThread], @"Wrong thread!");
        XCTAssertFalse(cancelled, @"Operation cancelled???");
        XCTAssertNil(error, @"Error received: %@", error.description);

        // Was the TestCreate Object saved?
        XCTAssertNotNil(newWidget.objectId, @"No web service id?");
        XCTAssertTrue(newWidget.hasBeenUploadedToServer, @"Why not uploaded?");
        XCTAssertTrue(newWidget.propertiesModifiedSinceLastUpload.count == 0, @"Modified?");
        XCTAssertFalse(newWidget.isDirty, @"Why is this entity dirty?");

        END_TEST
    }];

    [[FOSRESTConfig sharedInstance].cacheManager queueOperation:createOp
                                        withCompletionOperation:finalOp
                                                  withGroupName:@"Test create"];
    
    WAIT_FOR_TEST_END
}

- (void)testAtomicCreate {
    START_TEST

    NSDictionary *json = @{
        @"name" : @"New Name",
        @"user" : @{ @"__type" : @"Pointer",
                    @"className" : @"_User",
                    @"objectId" : self.loggedInUser.jsonIdValue }
    };

    FOSRetrieveCMOOperation *createOp = [TestCreate createAndRetrieveServerRecordWithJSON:json];

    FOSBackgroundOperation *finishOp = [FOSBackgroundOperation backgroundOperationWithRequest:^(BOOL cancelled, NSError *error) {

        XCTAssertFalse(cancelled, @"Cancelled???");
        XCTAssertNil(error, @"Error received: %@", error.description);

        // This check is needed as createOp will have an objectID that points to an invalid
        // database record.  This cannot be solved as subsequent operations can be run after
        // FOSCreateObjectOperation that might fail and FOSCreateObjectOperation doesn't
        // know that they failed, only that it succeeded.
        if (!cancelled && error == nil) {
            NSManagedObject *obj = createOp.managedObject;

            XCTAssertEqual(obj.managedObjectContext, [FOSRESTConfig sharedInstance].databaseManager.currentMOC,
                          @"Wrong MOC!");

            XCTAssertTrue([obj isKindOfClass:[TestCreate class]], @"Created wrong type: %@",
                          NSStringFromClass([obj class]));

            TestCreate *testCreate = (TestCreate *)obj;

            XCTAssertTrue(testCreate.hasBeenUploadedToServer, @"Why not uploaded?");
            XCTAssertTrue(testCreate.propertiesModifiedSinceLastUpload.count == 0, @"Modified?");
            XCTAssertTrue([testCreate.name isEqualToString:json[@"name"]], @"Wrong name: %@", testCreate.name);
            XCTAssertTrue([(NSString *)testCreate.user.jsonIdValue
                           isEqualToString:(NSString *)self.loggedInUser.jsonIdValue], @"Wrong user!");
        }

        END_TEST
    }];

    [[FOSRESTConfig sharedInstance].cacheManager queueOperation:createOp
                                        withCompletionOperation:finishOp
                                                  withGroupName:@"TestCreate"];

    WAIT_FOR_TEST_END
}

- (void)testAtomicCreateOffline {
    START_TEST

    NSDictionary *json = @{
                           @"name" : @"New Name",
                           @"user" : @{ @"__type" : @"Pointer",
                                        @"className" : @"_User",
                                        @"objectId" : self.loggedInUser.jsonIdValue }
                           };

    FOSRetrieveCMOOperation *createOp = [TestCreate createAndRetrieveServerRecordWithJSON:json];

    FOSBackgroundOperation *finishOp = [FOSBackgroundOperation backgroundOperationWithRequest:^(BOOL cancelled, NSError *error) {

        XCTAssertTrue(cancelled, @"Not cancelled???");
        XCTAssertNil(error, @"Error received: %@", error.description);

        [FOSLoginManagerTests networkStatusMonitor].forceOffline = NO;

        END_TEST
    } callRequestIfCancelled:YES];

    // Set offline
    [FOSLoginManagerTests networkStatusMonitor].forceOffline = YES;

    [[FOSRESTConfig sharedInstance].cacheManager queueOperation:createOp
                                        withCompletionOperation:finishOp
                                                  withGroupName:@"TestCreate"];
    
    WAIT_FOR_TEST_END
}

#ifdef later
- (void)testAtomicCreateFailure {
    START_TEST

    // There's a required relationship to 'user', which will cause a validation save failure
    NSDictionary *json = @{
                           @"name" : @"New Name",
                           };

    FOSFetchEntityOperation *createOp = [TestCreate atomicCreateWithJSON:json];

    FOSBackgroundOperation *finishOp = [FOSBackgroundOperation backgroundOperationWithRequest:^(BOOL cancelled, NSError *error) {

        XCTAssertFalse(cancelled, @"Cancelled???");
        XCTAssertNotNil(error, @"Received no error??");

        END_TEST
    }];

    [[FOSRESTConfig sharedInstance].cacheManager queueOperation:createOp
                                        withCompletionOperation:finishOp
                                                  withGroupName:@"TestCreate"];
    
    WAIT_FOR_TEST_END
}
#endif

#pragma mark - Relationship Tests

- (void)testSetUserToOneRelationship {
    START_TEST

    NSPredicate *pred = [NSPredicate predicateWithFormat:@"role = 'CEO'"];
    NSArray *roles = [Role fetchWithPredicate:pred];
    XCTAssertTrue(roles.count == 1, @"Is the default data missing?");

    Role *ceoRole = roles.lastObject;

    [[FOSRESTConfig sharedInstance].databaseManager saveChanges];

    [[FOSRESTConfig sharedInstance].cacheManager flushCaches:^(BOOL cancelled, NSError *error) {

        self.loggedInUser.role = ceoRole;
        [ceoRole addUsersObject:self.loggedInUser];

        [[FOSRESTConfig sharedInstance].databaseManager saveChanges];

        [[FOSRESTConfig sharedInstance].cacheManager flushCaches:^(BOOL cancelled, NSError *error) {

            XCTAssertFalse(cancelled, @"Cancelled???");
            XCTAssertNil(error, @"Error: %@", error.description);

            [[FOSRESTConfig sharedInstance].loginManager logout:^(BOOL succeeded, NSError *error) {

                [FOSLoginManagerTests setupStandardWebServiceConfigAndLogInWithOptions:FOSRESTConfigOptionsNone andCallback:^{

                    XCTAssertTrue([NSThread isMainThread], @"Wrong thread!!!");
                    XCTAssertNotNil(self.loggedInUser.role, @"No role???");
                    XCTAssertEqual(ceoRole.jsonIdValue, self.loggedInUser.role.jsonIdValue,
                                   @"Incorrect role assigned!");

                    END_TEST
                }];
            }];
        }];
    }];

    WAIT_FOR_TEST_END
}

- (void)testToMany_Success {
    START_TEST

    TestToManySearchOperation *searchOp = [[TestToManySearchOperation alloc] init];
    searchOp.uid = [FOSRESTConfig sharedInstance].loginManager.loggedInUserId;
    searchOp.testType = kTestToMany_JustRight;

    [searchOp performSearchAndInform:^(NSSet *results, NSError *error) {
        XCTAssertTrue(results.count == 1, @"Didn't find a result?");

        TestToMany *toMany = results.anyObject;
        XCTAssertTrue(toMany.toManyMax.count == 2, @"Wrong count?");
        XCTAssertTrue(toMany.toManyMin.count == 1, @"Wrong count?");
        XCTAssertNil(error, @"Received an error: %@", error.description);

        END_TEST
    }];

    WAIT_FOR_TEST_END
}

- (void)testToManyDestMin_Failure {
    START_TEST

    TestToManySearchOperation *searchOp = [[TestToManySearchOperation alloc] init];
    searchOp.uid = [FOSRESTConfig sharedInstance].loginManager.loggedInUserId;
    searchOp.testType = kTestToMany_TooFew;

    [searchOp performSearchAndInform:^(NSSet *results, NSError *error) {
        XCTAssertTrue(results.count == 0, @"Found results???");
        XCTAssertNotNil(error, @"Expected an error.");

        END_TEST
    }];

    WAIT_FOR_TEST_END
}

- (void)testToManyDestMax_Failure {
    START_TEST

    TestToManySearchOperation *searchOp = [[TestToManySearchOperation alloc] init];
    searchOp.uid = [FOSRESTConfig sharedInstance].loginManager.loggedInUserId;
    searchOp.testType = kTestToMany_TooMany;

    [searchOp performSearchAndInform:^(NSSet *results, NSError *error) {
        XCTAssertTrue(results.count == 0, @"Found results???");
        XCTAssertNotNil(error, @"Expected an error.");

        END_TEST
    }];

    WAIT_FOR_TEST_END
}

#pragma mark - Update Tests

- (void)testUpdate {
    START_TEST

    TestCreate *testCreate = [[TestCreate alloc] init];
    testCreate.name = @"New Name";
    testCreate.user = self.loggedInUser;
    [self.loggedInUser addTestCreationsObject:testCreate];

    [[FOSRESTConfig sharedInstance].databaseManager saveChanges];

    [[FOSRESTConfig sharedInstance].cacheManager flushCaches:^(BOOL isCancelled, NSError *error) {
        testCreate.name = @"Updated Name";

        [[FOSRESTConfig sharedInstance].databaseManager saveChanges];

        XCTAssertTrue(testCreate.hasModifiedProperties, @"No modified props???");

        [[FOSRESTConfig sharedInstance].cacheManager flushCaches:^(BOOL isCancelled, NSError *error) {
            XCTAssertTrue([NSThread isMainThread], @"Wrong thread!");
            XCTAssertNotNil(testCreate.objectId, @"No web service id.");
            XCTAssertTrue(testCreate.hasBeenUploadedToServer, @"Why not uploaded?");
            XCTAssertTrue(testCreate.propertiesModifiedSinceLastUpload.count == 0,
                         @"Properties not uploaded: %@", testCreate.propertiesModifiedSinceLastUpload);
            XCTAssertFalse(testCreate.isDirty, @"Why is this entity dirty?");

            END_TEST
        }];
    }];

    WAIT_FOR_TEST_END
}

- (void)testNewUpdate {
    START_TEST

    TestCreate *testCreate = [[TestCreate alloc] init];
    testCreate.name = @"New Name";
    testCreate.user = self.loggedInUser;
    [self.loggedInUser addTestCreationsObject:testCreate];

    [[FOSRESTConfig sharedInstance].databaseManager saveChanges];

    [[FOSRESTConfig sharedInstance].cacheManager flushCaches:^(BOOL isCancelled, NSError *error) {
        testCreate.name = @"Updated Name";
        NSString *firstObjectId = testCreate.objectId;

        [[FOSRESTConfig sharedInstance].databaseManager saveChanges];

        XCTAssertTrue(testCreate.hasModifiedProperties, @"No modified props???");

        FOSSendServerRecordOperation *createOp = [testCreate sendServerRecordWithLifecycleStyle:nil];

        XCTAssertTrue([createOp isKindOfClass:[FOSUpdateServerRecordOperation class]], @"Wrong type!");

        FOSBackgroundOperation *finalOp = [FOSBackgroundOperation backgroundOperationWithMainThreadRequest:^(BOOL cancelled, NSError *error) {
            XCTAssertTrue([NSThread isMainThread], @"Wrong thread!");
            XCTAssertNotNil(testCreate.objectId, @"No web service id.");
            XCTAssertEqualObjects(testCreate.objectId, firstObjectId, @"objectId changed???");
            XCTAssertTrue(testCreate.hasBeenUploadedToServer, @"Why not uploaded?");
            XCTAssertTrue(testCreate.propertiesModifiedSinceLastUpload.count == 0,
                          @"Properties not uploaded: %@", testCreate.propertiesModifiedSinceLastUpload);
            XCTAssertFalse(testCreate.isDirty, @"Why is this entity dirty?");

            END_TEST
        }];

        [[FOSRESTConfig sharedInstance].cacheManager queueOperation:createOp
                                            withCompletionOperation:finalOp
                                                      withGroupName:@"Test create"];

    }];
    
    WAIT_FOR_TEST_END
}

#pragma mark - Delete Tests

- (void)testDeleteFromClientToServer {
    START_TEST

    TestCreate *testCreate = [[TestCreate alloc] init];
    testCreate.name = @"Delete Me!";
    testCreate.user = self.loggedInUser;
    [self.loggedInUser addTestCreationsObject:testCreate];

    [[FOSRESTConfig sharedInstance].databaseManager saveChanges];

    [[FOSRESTConfig sharedInstance].cacheManager flushCaches:^(BOOL isCancelled, NSError *error) {
        NSPredicate *pred = [NSPredicate predicateWithFormat:@"name = %@", testCreate.name];
        NSArray *delObjs = [TestCreate fetchWithPredicate:pred];
        FOSJsonId testJsonId = nil;

        for (TestCreate *nextDel in delObjs) {
            // We'll test that at least the last was was deleted from the server
            testJsonId = nextDel.jsonIdValue;
            [nextDel.managedObjectContext deleteObject:nextDel];
        }

        [[FOSRESTConfig sharedInstance].databaseManager saveChanges];

        [[FOSRESTConfig sharedInstance].cacheManager flushCaches:^(BOOL isCancelled, NSError *error) {
            XCTAssertTrue([NSThread isMainThread], @"Wrong thread!");

            [[FOSRESTConfig sharedInstance].cacheManager flushCaches:^(BOOL isCancelled, NSError *error) {
                XCTAssertTrue([NSThread isMainThread], @"Wrong thread!");

                // All local objs should be gone
                NSArray *remainingDels = [TestCreate fetchWithPredicate:pred];
                XCTAssertTrue(remainingDels.count == 0, @"%lu deleted TestCreate records remain??",
                              (unsigned long)remainingDels.count);

                // TODO : This is parse.com specific...generalize.
                NSString *endPoint = [NSString stringWithFormat:@"1/classes/TestCreate/%@", testJsonId];
                FOSWebServiceRequest *request = [FOSWebServiceRequest requestWithRequestType:FOSRequestMethodGET
                                                                                    endPoint:endPoint];

                FOSBackgroundOperation *finalOp = [FOSBackgroundOperation backgroundOperationWithRequest:^(BOOL cancelled, NSError *error) {

                    XCTAssertFalse(cancelled, @"Cancelled??");
                    // It should fail as it doesn't exist!
                    XCTAssertNotNil(error, @"No error???");
                    XCTAssertNil(request.jsonResult[@"objectId"],
                                 @"Object still exists on the server!! %@", request.jsonResult);

                    END_TEST
                } callRequestIfCancelled:YES];

                [[FOSRESTConfig sharedInstance].cacheManager queueOperation:request
                                                    withCompletionOperation:finalOp
                                                              withGroupName:@"Test Record Deleted"];

            }];
        }];
    }];
    
    WAIT_FOR_TEST_END
}

- (void)testDeleteFromClientToServer_AlreadyDeleted {
    START_TEST

    TestCreate *testCreate = [[TestCreate alloc] init];
    testCreate.name = @"Delete Me!";
    testCreate.user = self.loggedInUser;
    [self.loggedInUser addTestCreationsObject:testCreate];

    [[FOSRESTConfig sharedInstance].databaseManager saveChanges];

    [[FOSRESTConfig sharedInstance].cacheManager flushCaches:^(BOOL cancelled, NSError *error) {
        XCTAssertTrue([NSThread isMainThread], @"Wrong thread!");
        XCTAssertFalse(cancelled, @"Cancelled???");
        XCTAssertNil(error, @"Received an error??? %@", error.description);

        // Delete from the server
        // TODO : This is parse.com specific...generalize.
        NSString *endPoint = [NSString stringWithFormat:@"1/classes/TestCreate/%@", testCreate.jsonIdValue];
        FOSWebServiceRequest *request = [FOSWebServiceRequest requestWithRequestType:FOSRequestMethodDELETE
                                                                            endPoint:endPoint];
        [[FOSRESTConfig sharedInstance].cacheManager queueOperation:request
                                            withCompletionOperation:nil
                                                      withGroupName:@"Force delete TestCreate"];

        // Now try to delete the object from the server with the standard mechanism.  It should
        // 'succeed' in that the error returned back from the server should be regarded
        // as the object being deleted and the local instance removed as well.
        [[FOSRESTConfig sharedInstance].cacheManager flushCaches:^(BOOL isCancelled, NSError *error) {
            XCTAssertTrue([NSThread isMainThread], @"Wrong thread!");
            XCTAssertFalse(isCancelled, @"Cancelled???");
            XCTAssertNil(error, @"Received an error??? %@", error.description);

            NSPredicate *pred = [NSPredicate predicateWithFormat:@"name = %@", testCreate.name];
            NSArray *delObjs = [TestCreate fetchWithPredicate:pred];

            for (TestCreate *nextDel in delObjs) {
                [nextDel.managedObjectContext deleteObject:nextDel];
            }

            [[FOSRESTConfig sharedInstance].databaseManager saveChanges];

            [[FOSRESTConfig sharedInstance].cacheManager flushCaches:^(BOOL isCancelled, NSError *error) {

                XCTAssertTrue([NSThread isMainThread], @"Wrong thread!");
                XCTAssertFalse(isCancelled, @"Cancelled???");
                XCTAssertNil(error, @"Received an error??? %@", error.description);

                [[FOSRESTConfig sharedInstance].cacheManager flushCaches:^(BOOL isCancelled, NSError *error) {
                    XCTAssertTrue([NSThread isMainThread], @"Wrong thread!");
                    XCTAssertFalse(isCancelled, @"Cancelled???");
                    XCTAssertNil(error, @"Received an error??? %@", error.description);

                    // All local objs should be gone
                    NSArray *remainingDels = [TestCreate fetchWithPredicate:pred];
                    XCTAssertTrue(remainingDels.count == 0, @"%lu deleted TestCreate records remain??",
                                  (unsigned long)remainingDels.count);

                    // TODO : Need a search op to test that it was deleted on the server

                    END_TEST
                }];
            }];
        }];
    }];
    
    WAIT_FOR_TEST_END
}

- (void)testDeleteFromServerToClient_ToOne {
    START_TEST

    // Create the stand alone role and push it to the server
    Role *testRole = [[Role alloc] init];
    testRole.role = @"Delete Me!";

    [[FOSRESTConfig sharedInstance].databaseManager saveChanges];

    [[FOSRESTConfig sharedInstance].cacheManager flushCaches:^(BOOL isCancelled, NSError *error) {
        XCTAssertTrue([NSThread isMainThread], @"Wrong thread!");

        // TODO : This causes willAccessValueForKey: to be called.  This shouldn't matter,
        //        however, in the to-one processing it attempts to pull the data for
        //        the current relationship value, if any.  If a left over (dead) value is
        //        there, then the relationship will be cleared *after* we've set it here!
        //
        self.loggedInUser.role = testRole;
        [testRole addUsersObject:self.loggedInUser];

        [[FOSRESTConfig sharedInstance].databaseManager saveChanges];

        XCTAssertNotNil(self.loggedInUser.role, @"Role should be set!");
        XCTAssertEqual(self.loggedInUser.role.jsonIdValue, testRole.jsonIdValue, @"Wrong role!");

        [[FOSRESTConfig sharedInstance].cacheManager flushCaches:^(BOOL isCancelled, NSError *error) {

            XCTAssertTrue([NSThread isMainThread], @"Wrong thread!");

            // TODO : Because of the TODO above, these checks don't always work
            /*
            XCTAssertNotNil(self.loggedInUser.role, @"Role should be set!");
            XCTAssertEqual(self.loggedInUser.role.jsonIdValue, testRole.jsonIdValue, @"Wrong role!");
             */

            // Delete from the server
            // TODO : This is parse.com specific...generalize.
            NSString *endPoint = [NSString stringWithFormat:@"1/classes/Role/%@", testRole.jsonIdValue];
            FOSWebServiceRequest *request = [FOSWebServiceRequest requestWithRequestType:FOSRequestMethodDELETE
                                                                                endPoint:endPoint];

            FOSBackgroundOperation *finalTestOp = [FOSBackgroundOperation backgroundOperationWithRequest:^(BOOL cancelled, NSError *error) {

                dispatch_async(dispatch_get_main_queue(), ^{
                    // When we log back in, the relationship should be nil
                    [[FOSRESTConfig sharedInstance].loginManager logout:^(BOOL succeeded, NSError *error) {

                        [FOSLoginManagerTests setupStandardWebServiceConfigAndLogInWithOptions:FOSRESTConfigOptionsNone andCallback:^{

                            XCTAssertTrue([NSThread isMainThread], @"Wrong thread!");

                            // All local objs should be gone
                            XCTAssertNil(self.loggedInUser.role, @"User should no longer have a role.");
                            
                            END_TEST
                        }];
                    }];
                });
            }];

            [[FOSRESTConfig sharedInstance].cacheManager queueOperation:request
                                                withCompletionOperation:finalTestOp
                                                          withGroupName:@"Manual Delete Role"];
        }];
    }];
    
    WAIT_FOR_TEST_END
}

- (void)testDeleteFromServerToClient_ToMany_SingleItem {
    START_TEST

    TestCreate *testCreate = [[TestCreate alloc] init];
    testCreate.name = @"Delete Me!";
    testCreate.user = self.loggedInUser;
    [self.loggedInUser addTestCreationsObject:testCreate];

    [[FOSRESTConfig sharedInstance].databaseManager saveChanges];

    [[FOSRESTConfig sharedInstance].cacheManager flushCaches:^(BOOL isCancelled, NSError *error) {

        // Delete from the server
        // TODO : This is parse.com specific...generalize.
        NSString *endPoint = [NSString stringWithFormat:@"1/classes/TestCreate/%@", testCreate.jsonIdValue];
        FOSWebServiceRequest *request = [FOSWebServiceRequest requestWithRequestType:FOSRequestMethodDELETE
                                                                            endPoint:endPoint];

        FOSRetrieveCMOOperation *fetchEntity = [User retrieveCMOForJsonId:self.loggedInUser.jsonIdValue];
        fetchEntity.allowFastTrack = NO;
        [fetchEntity addDependency:request];

        FOSBackgroundOperation *finalTestOp = [FOSBackgroundOperation backgroundOperationWithRequest:^(BOOL cancelled, NSError *error) {

            // TODO : This is parse.com specific...generalize.
            NSPredicate *pred = [NSPredicate predicateWithFormat:@"objectId = %@", testCreate.jsonIdValue];

            // All local objs should be gone
            NSArray *remainingDels = [TestCreate fetchWithPredicate:pred];
            XCTAssertTrue(remainingDels.count == 0, @"%lu deleted TestCreate records remain??",
                          (unsigned long)remainingDels.count);
            XCTAssertTrue(self.loggedInUser.testCreations.count == 0, @"Incorrect testCreations count. Expected 0, got: %lu", (unsigned long)self.loggedInUser.testCreations.count);

            END_TEST
        }];

        [[FOSRESTConfig sharedInstance].cacheManager queueOperation:fetchEntity
                                            withCompletionOperation:finalTestOp
                                                      withGroupName:@"Manual Delete TestCreate"];
    }];
    
    WAIT_FOR_TEST_END
}

- (void)testDeleteFromServerToClient_ToMany_SingleItemOfMultiple {
    START_TEST

    TestCreate *testCreate1 = [[TestCreate alloc] init];
    testCreate1.name = @"Delete Me!";
    testCreate1.user = self.loggedInUser;
    [self.loggedInUser addTestCreationsObject:testCreate1];

    TestCreate *testCreate2 = [[TestCreate alloc] init];
    testCreate2.name = @"Keep Me!";
    testCreate2.user = self.loggedInUser;
    [self.loggedInUser addTestCreationsObject:testCreate2];

    [[FOSRESTConfig sharedInstance].databaseManager saveChanges];

    [[FOSRESTConfig sharedInstance].cacheManager flushCaches:^(BOOL isCancelled, NSError *error) {

        // Delete from the server
        // TODO : This is parse.com specific...generalize.
        NSString *endPoint = [NSString stringWithFormat:@"1/classes/TestCreate/%@", testCreate1.jsonIdValue];
        FOSWebServiceRequest *request = [FOSWebServiceRequest requestWithRequestType:FOSRequestMethodDELETE
                                                                            endPoint:endPoint];

        FOSRetrieveCMOOperation *fetchEntity = [User retrieveCMOForJsonId:self.loggedInUser.jsonIdValue];
        fetchEntity.allowFastTrack = NO;
        [fetchEntity addDependency:request];

        FOSBackgroundOperation *finalTestOp = [FOSBackgroundOperation backgroundOperationWithRequest:^(BOOL cancelled, NSError *error) {

            // TODO : This is parse.com specific...generalize.
            NSPredicate *pred = [NSPredicate predicateWithFormat:@"objectId = %@", testCreate1.jsonIdValue];

            // testCreate1 should be gone
            NSArray *remainingDels = [TestCreate fetchWithPredicate:pred];
            XCTAssertTrue(remainingDels.count == 0, @"%lu deleted TestCreate records remain??",
                          (unsigned long)remainingDels.count);

            // TODO : This is parse.com specific...generalize.
            NSPredicate *pred2 = [NSPredicate predicateWithFormat:@"objectId = %@", testCreate2.jsonIdValue];

            // testCreate2 should remain!!
            NSArray *remainingDels2 = [TestCreate fetchWithPredicate:pred2];
            XCTAssertTrue(remainingDels2.count == 1, @"%lu deleted TestCreate records remain??",
                          (unsigned long)remainingDels2.count);
            XCTAssertTrue(self.loggedInUser.testCreations.count == 1, @"Incorrect testCreations count. Expected 1, got: %lu", (unsigned long)self.loggedInUser.testCreations.count);
            XCTAssertTrue([(NSString *)[self.loggedInUser.testCreations.anyObject jsonIdValue] isEqualToString:(NSString *)testCreate2.jsonIdValue], @"Incorrect remaining TestCreate item.");

            // Clean things up
            // Delete from the server
            // TODO : This is parse.com specific...generalize.
            NSString *endPoint = [NSString stringWithFormat:@"1/classes/TestCreate/%@", testCreate2.jsonIdValue];
            FOSWebServiceRequest *cleanUpRequest = [FOSWebServiceRequest requestWithRequestType:FOSRequestMethodDELETE
                                                                                endPoint:endPoint];

            FOSBackgroundOperation *endTestOp = [FOSBackgroundOperation backgroundOperationWithRequest:^(BOOL cancelled, NSError *error) {
                END_TEST
            }];

            [[FOSRESTConfig sharedInstance].cacheManager queueOperation:cleanUpRequest
                                                withCompletionOperation:endTestOp
                                                          withGroupName:@"Clean up for Delete Test"];

        }];

        [[FOSRESTConfig sharedInstance].cacheManager queueOperation:fetchEntity
                                            withCompletionOperation:finalTestOp
                                                      withGroupName:@"Manual Delete TestCreate"];
    }];
    
    WAIT_FOR_TEST_END
}

#pragma mark - Conflicting Sync Tests

- (void)testClientServerValueConflict {

    START_TEST

    Widget *newWidget = [[Widget alloc] init];

    NSString *widgetName1 = @"Test Conflict";
    newWidget.name = widgetName1;
    newWidget.widgetInfo = [WidgetInfo fetchAll].lastObject;
    newWidget.user = self.loggedInUser;

    [[FOSRESTConfig sharedInstance].databaseManager saveChanges];

    // Send the widget to the server
    [[FOSRESTConfig sharedInstance].cacheManager flushCaches:^(BOOL cancelled, NSError *error) {

        // Make local changes to the widget
        NSString *widgetName2 = @"Update Conflict";
        newWidget.name = widgetName2;

        [[FOSRESTConfig sharedInstance].databaseManager saveChanges];

        // Now pull the widget back down from the server (before syncing our local changes)
        WidgetSearchOperation *searchOp = [[WidgetSearchOperation alloc] init];
        searchOp.name = widgetName1;

        [searchOp performSearchAndInform:^(NSSet *results, NSError *error) {

            Widget *conflictWidget = results.anyObject;

            XCTAssertNotNil(conflictWidget, @"No widget??");

            // If an error occurs here, check parse.com to make sure that there are no
            // left overs that need to be deleted.
            // TODO : Force the server table clear before running this test
            XCTAssertTrue([conflictWidget.name isEqualToString:widgetName2],
                          @"Got widget name %@, expected %@.",
                          conflictWidget.name,
                          widgetName2);

            END_TEST
        }];
    }];

    WAIT_FOR_TEST_END
}

#pragma mark - KVO Methods

// TODO : Add a test where the model object name is not the same as the web object name

- (void)observeValueForKeyPath:(NSString *)keyPath
                      ofObject:(id)object
                        change:(NSDictionary *)change
                       context:(void *)context {

    EmptyHandler handler = (__bridge EmptyHandler)context;

    dispatch_async(dispatch_get_main_queue(), ^{
        handler();
    });
}

#ifdef later_enable_faults
- (void)testToManyRelationshipFault {
    START_TEST

    __block Widget *testWidget = nil;
    __block BOOL foundNote = NO;
    __block EmptyHandler handler2 = nil;
    __block FOSCachedManagedObjectTests *blockSelf = self;

    EmptyHandler handler1 = ^{
        [blockSelf.loggedInUser removeObserver:blockSelf forKeyPath:@"widgets"];

        NSPredicate *widgetPred = [NSPredicate predicateWithFormat:@"name == %@", @"TestWidget"];
        NSArray *widgets = [self.loggedInUser.widgets.array filteredArrayUsingPredicate:widgetPred];
        XCTAssertTrue(widgets.count == 1, @"TestWidget probably deleted from Parse.com, please restore.");
        testWidget = widgets.lastObject;

        XCTAssertTrue(testWidget.faultedRelationships.count == 1, @"No faults?");
        FOSRelationshipFault *fault = testWidget.faultedRelationships.anyObject;

        XCTAssertTrue([fault.relationshipName isEqualToString:@"notes"],
                     @"Incorrect relationship faulted.");

        handler2 = ^{
            XCTAssertNotNil(testWidget, @"???");

            NSPredicate *notePred = [NSPredicate predicateWithFormat:@"note == %@", @"Test Note"];
            NSSet *notes = [testWidget.notes filteredSetUsingPredicate:notePred];
            foundNote = (notes.count == 1);

            if (foundNote) {
                [testWidget removeObserver:blockSelf forKeyPath:@"notes"];

                XCTAssertTrue(foundNote, @"Didn't find the note 'Test Note'???");

                END_TEST
            }
        };

        [testWidget addObserver:self forKeyPath:@"notes" options:0 context:(void *)handler2];

        // This call also faults the relationship
        XCTAssertTrue(testWidget.notes.count == 0, @"Already have notes???");
    };

    [self.loggedInUser addObserver:self forKeyPath:@"widgets" options:0 context:(void *)handler1];

    // Fire the fault
    NSOrderedSet *set = self.loggedInUser.widgets;
    if (set.count > 0) {
        handler1();
    }

    WAIT_FOR_TEST_END

    XCTAssertTrue(foundNote, @"Didn't find the note.");
}
#endif

#pragma mark - Refresh Relationship Tests

- (void)testRefreshToOneRelationship {
    START_TEST

    User *loggedInUser = self.loggedInUser;
    NSInteger testCreateInitialCount = loggedInUser.testCreations.count;

    NSString *endPoint = @"1/classes/TestCreate";

    NSDictionary *json = @{
                           @"name" : @"test refresh",
                           @"user" : @{
                                   @"__type" : @"Pointer",
                                   @"className" : @"_User",
                               @"objectId" : loggedInUser.jsonIdValue
                            }
                         };

    NSArray *frags = @[ json ];
    FOSWebServiceRequest *createTestRecord =
        [FOSWebServiceRequest requestWithRequestType:FOSRequestMethodPOST
                                            endPoint:endPoint
                                        uriFragments:frags];

    endPoint = [NSString stringWithFormat:@"1/classes/_User/%@", self.loggedInUser.jsonIdValue];
    json = @{ @"testCreationsChildCount_" : @(-1) };
    frags = @[ json ];
    FOSWebServiceRequest *updateUserRecord =
        [FOSWebServiceRequest requestWithRequestType:FOSRequestMethodPUT
                                            endPoint:endPoint
                                        uriFragments:frags];

    [updateUserRecord addDependency:createTestRecord];

    FOSBackgroundOperation *bgOp = [FOSBackgroundOperation backgroundOperationWithMainThreadRequest:^(BOOL cancelled, NSError *error) {
        XCTAssertFalse(cancelled, @"Cancelled???");
        XCTAssertEqual(error.code, 201, @"Error: %@", error.description);

        [loggedInUser refreshRelationshipNamed:@"testCreations" dslQuery:nil mergeResults:NO handler:^(BOOL cancelled, NSError *error) {
            XCTAssertFalse(cancelled, @"Cancelled???");
            XCTAssertNil(error, @"Error: %@", error.description);

            XCTAssertTrue(self.loggedInUser.testCreations.count > testCreateInitialCount,
                          @"No new records???");

            END_TEST
        }];
    }];

    [[FOSRESTConfig sharedInstance].cacheManager queueOperation:updateUserRecord
                                        withCompletionOperation:bgOp
                                                  withGroupName:@"TestCreate"];

    WAIT_FOR_TEST_END
}

#pragma mark - Entity Retrieval methods

- (void)testRetrieveFastTrack {
    START_TEST

    NSString *testWidgetId = @"8S6wb8n79J";
    Widget *widget = [Widget fetchWithId:testWidgetId];

    XCTAssertNotNil(widget, @"Missing widget??");

    FOSRetrieveCMOOperation *retrieveOp =
        [FOSRetrieveCMOOperation retrieveCMOForEntity:[Widget entityDescription]
                                               withId:testWidgetId];
    XCTAssertTrue(retrieveOp.allowFastTrack, @"allowFastTrack should be YES by default");

    FOSBackgroundOperation *finalOp = [FOSBackgroundOperation backgroundOperationWithRequest:^(BOOL cancelled, NSError *error) {
        XCTAssertFalse(cancelled, @"Cancelled???");
        XCTAssertNil(error, @"Error: %@", error.description);

        XCTAssertNotNil(retrieveOp.managedObject, @"Missing cmo???");
        XCTAssertTrue([retrieveOp.managedObject.jsonIdValue isEqual:testWidgetId], @"Bad JSONID?");

        END_TEST

    } callRequestIfCancelled:YES];

    [[FOSRESTConfig sharedInstance].cacheManager queueOperation:retrieveOp
                                        withCompletionOperation:finalOp
                                                  withGroupName:@"Test Fast Track"];

    WAIT_FOR_TEST_END
}

@end
