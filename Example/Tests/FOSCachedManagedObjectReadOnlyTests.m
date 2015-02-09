//
//  FOSCachedManagedObjectReadOnlyTests.m
//  FOSFoundation
//
//  Created by David Hunt on 12/18/13.
//  Copyright (c) 2013 FOS Computer Services. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "FOSFoundationTests.h"
#import "Widget.h"
#import "WidgetInfo.h"
#import "User.h"
#import "NSObject+Tests.h"

@interface FOSCachedManagedObjectReadOnlyTests : XCTestCase

@end

@implementation FOSCachedManagedObjectReadOnlyTests

SETUP_TEARDOWN_LOGIN(FOSRESTConfigOptionsNone)

#pragma mark - Dependencies on Read-Only (non-uploadable)s

- (void)testUploadWithRefToNonUploadable {
    START_TEST

    Widget *newWidget = [[Widget alloc] init];

    NSString *widgetName1 = @"Test Non-Upload Deps";
    newWidget.name = widgetName1;
    newWidget.widgetInfo = [WidgetInfo fetchAll].lastObject;
    newWidget.user = self.loggedInUser;

    [[[FOSRESTConfig sharedInstance] databaseManager] saveChanges];

    NSManagedObjectID *widgetID = newWidget.objectID;

    // Send the widget to the server
    [[FOSRESTConfig sharedInstance].cacheManager flushCaches:^(BOOL cancelled, NSError *error) {

        NSManagedObjectContext *moc = [[[FOSRESTConfig sharedInstance] databaseManager] currentMOC];

        Widget *uploadedWidget = (Widget *)[moc objectWithID:widgetID];

        XCTAssertTrue(uploadedWidget.hasBeenUploadedToServer, @"Not uploaded???");
        XCTAssertNotNil(uploadedWidget.jsonIdValue, @"No jsonIdValue???");

        END_TEST
    }];
    
    WAIT_FOR_TEST_END
}

@end
