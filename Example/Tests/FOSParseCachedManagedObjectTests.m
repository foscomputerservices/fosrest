//
//  FOSParseCachedManagedObjectTests.m
//  FOSREST
//
//  Created by David Hunt on 1/7/13.
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

#import "FOSParseCachedManagedObjectTests.h"
#import <FOSREST/FOSDatabaseManager.h>
#import "FOSRESTTests.h"
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
