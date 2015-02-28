//
//  FOSCachedManagedObjectReadOnlyTests.m
//  FOSFoundation
//
//  Created by David Hunt on 12/18/13.
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
