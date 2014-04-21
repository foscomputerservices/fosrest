//
//  FOSPullStaticTablesOperationTests.m
//  FOSFoundation
//
//  Created by David Hunt on 10/7/13.
//  Copyright (c) 2013 FOS Computer Services. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "FOSCachedManagedObjectTests.h"
#import "FOSFoundationTests.h"
#import "FOSFoundation.h"
#import "FOSLoginManagerTests.h"
#import "FOSPullStaticTablesOperation+FOS_Internal.h"
#import "FOSRefreshUserOperation.h"
#import "FOSRelationshipFault+FOS_Internal.h"
#import "FOSPullStaticTablesOperation.h"
#import "NSObject+Tests.h"
#import "Note.h"
#import "TestCreate.h"
#import "User.h"
#import "Widget.h"
#import "Role.h"

@interface FOSPullStaticTablesOperationTests : XCTestCase

@end

@implementation FOSPullStaticTablesOperationTests

SETUP_TEARDOWN_NOLOGIN

- (void)testPullStaticTables {
    START_TEST

    [self _clearRoleTable];

    [[FOSRESTConfig sharedInstance].databaseManager saveChanges];

    [[FOSRESTConfig sharedInstance].cacheManager flushCaches:^(BOOL cancelled, NSError *error) {
        XCTAssertTrue([Role fetchAllEntities].count == 0, @"Roles still remain???");

        FOSPullStaticTablesOperation *pullStaticTables =
        [[FOSPullStaticTablesOperation alloc] initResettingProcessedTables:YES];

        FOSBackgroundOperation *testOp = [FOSBackgroundOperation backgroundOperationWithRequest:^(BOOL cancelled, NSError *error) {
            XCTAssertFalse(cancelled, @"Cancelled???");
            XCTAssertNil(error, @"Error ???");

            XCTAssertTrue([Role fetchAllEntities].count >= 2, @"Expected at least two Roles");

            NSArray *expectedRoles = @[@"Technician", @"CEO"];
            NSPredicate *pred = [NSPredicate predicateWithFormat:@"role in %@", expectedRoles];

            XCTAssertTrue([Role fetchWithPredicate:pred].count == 2, @"Expected the following roles: %@",
                          expectedRoles);

            END_TEST
        }];

        [[FOSRESTConfig sharedInstance].cacheManager queueOperation:pullStaticTables
                                            withCompletionOperation:testOp
                                                      withGroupName:@"Pull static tables"];
    }];

    WAIT_FOR_TEST_END
}

- (void)testDeleteFromServerToClient_StaticTables {
    START_TEST

    FOSRESTConfig *restConfig = [FOSRESTConfig sharedInstance];
    FOSCacheManager *cacheMgr = restConfig.cacheManager;
    FOSDatabaseManager *dbMgr = restConfig.databaseManager;

    Role *testRole = [[Role alloc] init];
    testRole.role = @"Delete Me!";

    [dbMgr saveChanges];

    FOSOperation *pushOp = [testRole sendServerRecord];
    FOSBackgroundOperation *finalOp = [FOSBackgroundOperation backgroundOperationWithRequest:^(BOOL cancelled, NSError *error) {
        FOSJsonId roleJsonId = testRole.jsonIdValue;

        XCTAssertNotNil(roleJsonId, @"No jsonId!");

        FOSPullStaticTablesOperation *pullStaticTables =
            [[FOSPullStaticTablesOperation alloc] initResettingProcessedTables:YES];

        FOSBackgroundOperation *pullUpdatedTables = [FOSBackgroundOperation backgroundOperationWithRequest:^(BOOL cancelled, NSError *error) {

            XCTAssertNotNil([Role fetchWithId:roleJsonId], @"Missing Role!!");

            // Delete from the server
            // TODO : This is parse.com specific...generalize.
            NSString *endPoint = [NSString stringWithFormat:@"1/classes/Role/%@", testRole.jsonIdValue];
            FOSWebServiceRequest *deleteRequest =
            [FOSWebServiceRequest requestWithRequestType:FOSRequestMethodDELETE
                                                endPoint:endPoint];

            FOSBackgroundOperation *finishDelete = [FOSBackgroundOperation backgroundOperationWithRequest:^(BOOL cancelled, NSError *error) {
                FOSPullStaticTablesOperation *finalUpdateStaticTables =
                    [[FOSPullStaticTablesOperation alloc] initResettingProcessedTables:YES];

                FOSBackgroundOperation *finalTestOp = [FOSBackgroundOperation backgroundOperationWithRequest:^(BOOL cancelled, NSError *error) {

                    XCTAssertNil([Role fetchWithId:roleJsonId], @"Role still exists!");

                    END_TEST
                } callRequestIfCancelled:YES];

                [cacheMgr queueOperation:finalUpdateStaticTables
                 withCompletionOperation:finalTestOp
                           withGroupName:@"Final Update of Static Tables"];
            }];

            [cacheMgr queueOperation:deleteRequest
             withCompletionOperation:finishDelete
                       withGroupName:@"Manual Delete Role"];
        }];


        [cacheMgr queueOperation:pullStaticTables
         withCompletionOperation:pullUpdatedTables
                   withGroupName:@"Manual Update Static Tables"];
    } callRequestIfCancelled:YES];

    [cacheMgr queueOperation:pushOp
     withCompletionOperation:finalOp
               withGroupName:@"Save Record"];


    WAIT_FOR_TEST_END
}

- (void)testPullPartialStaticTables {
    START_TEST

    [self _clearRoleTable];

    [[FOSRESTConfig sharedInstance].cacheManager flushCaches:^(BOOL cancelled, NSError *error) {
        XCTAssertTrue([Role fetchAllEntities].count == 0, @"Roles still remain???");

        FOSPullStaticTablesOperation *pullStaticTables =
            [[FOSPullStaticTablesOperation alloc] initResettingProcessedTables:YES];

        FOSBackgroundOperation *testOp = [FOSBackgroundOperation backgroundOperationWithRequest:^(BOOL cancelled, NSError *error) {
            XCTAssertFalse(cancelled, @"Cancelled???");
            XCTAssertNil(error, @"Error ???");

            NSUInteger pulledRoleCount = [Role countOfEntities];
            XCTAssertTrue(pulledRoleCount >= 2, @"Expected at least two Roles");

            NSArray *expectedRoles = @[@"Technician", @"CEO"];
            NSPredicate *pred = [NSPredicate predicateWithFormat:@"role in %@", expectedRoles];

            XCTAssertTrue([Role countOfEntitiesWithPredicate:pred] == 2,
                          @"Expected the following roles: %@",
                          expectedRoles);

            NSManagedObjectContext *moc = [FOSRESTConfig sharedInstance].databaseManager.currentMOC;
            [FOSPullStaticTablesOperation _initStaticTablesList:YES
                                           managedObjectContext:moc];
            FOSPullStaticTablesOperation *partialPullStaticTables =
                [[FOSPullStaticTablesOperation alloc] initResettingProcessedTables:NO];

            FOSBackgroundOperation *testPartialPull = [FOSBackgroundOperation backgroundOperationWithRequest:^(BOOL cancelled, NSError *error) {

                XCTAssertFalse(cancelled, @"Cancelled???");
                XCTAssertNil(error, @"Error ???");

                XCTAssertEqual(pulledRoleCount, [Role countOfEntities], @"Count changed???");

                XCTAssertTrue([Role countOfEntitiesWithPredicate:pred] == 2,
                              @"Expected the following roles: %@",
                              expectedRoles);

                END_TEST
            } callRequestIfCancelled:YES];

            [[FOSRESTConfig sharedInstance].cacheManager queueOperation:partialPullStaticTables
                                                withCompletionOperation:testPartialPull
                                                          withGroupName:@"Partial pull static tables"];

        }];

        [[FOSRESTConfig sharedInstance].cacheManager queueOperation:pullStaticTables
                                            withCompletionOperation:testOp
                                                      withGroupName:@"Pull static tables"];
    }];
    
    WAIT_FOR_TEST_END
}

#pragma mark - Private Methods

- (void)_clearRoleTable {
    // Force clear out the Role Table
    id<NSFastEnumeration> roles = [Role fetchAllEntities];
    for (Role *nextRole in roles) {

        // Don't delete these from the server, just locally
        nextRole.skipServerDelete = YES;

        [nextRole.managedObjectContext deleteObject:nextRole];
    }

    [[FOSRESTConfig sharedInstance].databaseManager saveChanges];
}

@end
