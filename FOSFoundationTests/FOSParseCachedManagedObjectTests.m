//
//  FOSParseCachedManagedObjectTests.m
//  FOSFoundation
//
//  Created by David Hunt on 1/7/13.
//  Copyright (c) 2013 FOS Computer Services. All rights reserved.
//

#import "FOSParseCachedManagedObjectTests.h"
#import "FOSFoundationTests.h"
#import "NSObject+Tests.h"
#import "TestCreate.h"
#import "User.h"

@implementation FOSParseCachedManagedObjectTests

#pragma mark - Test Configuration Methods

SETUP_TEARDOWN_LOGIN(FOSRESTConfigOptionsNone | FOSRESTConfigAutomaticallySynchronize)

#pragma mark - Tests

- (void)testUpdateTransformableAttribute {
    START_TEST

    TestCreate *testCreate = [[TestCreate alloc] init];
    testCreate.name = @"Red Widgets";
    testCreate.color =
#if defined(TARGET_OS_IPHONE) || defined(TARGET_IPHONE_SIMULATOR)
    [UIColor redColor];
#else
    [NSColor redColor];
#endif

    // If the following line crashes, you probably regenerated User.[h|m]
    // Restore the following lines:
    //    // Work around for Apple bug
    //    // http://stackoverflow.com/questions/7385439/exception-thrown-in-nsorderedset-generated-accessors
    //    - (void)addWidgetsObject:(Widget *)value {
    //        NSMutableOrderedSet* tempSet = [self mutableOrderedSetValueForKey:@"widgets"];
    //        [tempSet addObject:value];
    //    }

    [self.loggedInUser addTestCreationsObject:testCreate];

    [[FOSRESTConfig sharedInstance].databaseManager saveChanges];

    [[FOSRESTConfig sharedInstance].cacheManager flushCaches:^(BOOL isCancelled, NSError *error) {
        XCTAssertNotNil(testCreate.objectId, @"No web service id.");
        XCTAssertTrue(testCreate.hasBeenUploadedToServer, @"Why not uploaded?");
        XCTAssertTrue(testCreate.propertiesModifiedSinceLastUpload.count == 0, @"Modified?");

        END_TEST
    }];

    WAIT_FOR_TEST_END
}
@end
