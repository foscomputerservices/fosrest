//
//  FOSSearchOperationTests.m
//  FOSFoundation
//
//  Created by David Hunt on 12/28/12.
//  Copyright (c) 2012 FOS Computer Services. All rights reserved.
//

#import "FOSSearchOperationTests.h"
#import "FOSFoundationTests.h"
#import "FOSFoundation.h"
#import "FOSLoginManagerTests.h"
#import "User.h"
#import "Widget.h"
#import "WidgetSearchOperation.h"

@implementation FOSSearchOperationTests {
    BOOL _searchComplete;
}

#pragma mark - Test Configuration Methods

SETUP_TEARDOWN_LOGIN(FOSRESTConfigOptionsNone | FOSRESTConfigAutomaticallySynchronize)

#pragma mark - Tests

- (void)testSearch {

    WidgetSearchOperation *searchOp = [[WidgetSearchOperation alloc] init];
    searchOp.name = @"TestWidget - Don't Delete";

    START_TEST

    // NOTE: If this test fails, it could simply be that the 'TestWidget - Don't Delete' row
    //       in the Widget table on parse.com has been accidentally removed.
    //       Here's the query: https://api.parse.com/1/classes/Widget?where={"name" : "TestWidget - Don't Delete"}
    //
    //       Simply manually add the row back in, if this is the case.
    [searchOp performSearchAndInform:^(NSSet *results, NSError *error) {
        XCTAssertNil(error, @"Error running search: %@", error.description);
        XCTAssertNotNil(results, @"Expected results");
        XCTAssertTrue([NSThread isMainThread], @"Wrong thread!");
        XCTAssertTrue(results.count == 1, @"Incorrect result count: %i", (int)results.count);

        id result = results.anyObject;

        XCTAssertTrue([result isKindOfClass:[Widget class]], @"Wrong type!");
        XCTAssertTrue([((Widget *)result).name isEqualToString:searchOp.name], @"Wrong name");

        END_TEST
    }];

    WAIT_FOR_TEST_END
}


/* NOTE:
 *
 * This test expects that the Widget table on parse.com contains at least one schema invalid
 * entry.
 */
- (void)testSaveIndividualResults {
    WidgetSearchOperation *searchOp = [[WidgetSearchOperation alloc] init];
    searchOp.uid = [FOSRESTConfig sharedInstance].loginManager.loggedInUserId;
    searchOp.saveIndividualResults = YES;

    START_TEST

    XCTAssertTrue(searchOp.saveIndividualResults, @"Not set to save individual results?");

    [searchOp performSearchAndInform:^(NSSet *results, NSError *error) {
        XCTAssertTrue([NSThread isMainThread], @"Wrong thread!");
        XCTAssertTrue(results.count > 0, @"Didn't get any results?");
        XCTAssertNil(error, @"Got an error: %@", error.description);

        END_TEST
    }];

    WAIT_FOR_TEST_END
}

- (void)testNotSaveIndividualResults {
    WidgetSearchOperation *searchOp = [[WidgetSearchOperation alloc] init];
    searchOp.uid = @"WAcVEoW9sL";

    searchOp.saveIndividualResults = NO;
    XCTAssertFalse(searchOp.saveIndividualResults, @"Set to save individual results?");

    START_TEST

    [searchOp performSearchAndInform:^(NSSet *results, NSError *error) {
        XCTAssertTrue([NSThread isMainThread], @"Wrong thread!");
        XCTAssertTrue(results.count == 0, @"Didn't expect to get any results?");
        XCTAssertNotNil(error, @"No error???");

        END_TEST
    }];

    WAIT_FOR_TEST_END
}

@end
