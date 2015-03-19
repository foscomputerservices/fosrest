//
//  FOSNetworkStatusMonitorTests.m
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
#import "FOSREST.h"

@interface FOSNetworkStatusMonitor ()

/*!
 * @property forceOffline
 *
 * This is an internal property for testing online/offline mode.  By setting
 * this property to YES, it will cause the receiver to report back
 * FOSNetworkStatusNotReachable from the networkStatus property.  It will also
 * trigger the appropriate change in status notifications.
 *
 * @discussion
 *
 * Setting this property will reset forceOnline to NO.
 */
- (BOOL)forceOffline;
- (void)setForceOffline:(BOOL)forceOffline;

@end

@interface FOSNetworkStatusMonitorTests : XCTestCase

@end

typedef void (^_FOSNSMKVPHandler)(NSString *keyPath, id object, NSDictionary *change, void *context);
typedef void (^_FOSNSMNotificationHandler)(NSNotification *aNote);

@implementation FOSNetworkStatusMonitorTests {
    _FOSNSMKVPHandler _kvpHandler;
    _FOSNSMNotificationHandler _notificationHandler;
}

- (void)setUp {
    [super setUp];
    // Put setup code here; it will be run once, before the first test case.
}

- (void)tearDown {
    // Put teardown code here; it will be run once, after the last test case.
    [super tearDown];
}

#pragma mark - Test Manual Offline Support

- (void)testForcedOfflineSupport {

    FOSNetworkStatusMonitor *status = [FOSNetworkStatusMonitor statusMonitorForLocalWiFi];
    XCTAssertFalse(status.isForcedOffline, @"Haven't set forced offline yet!");
    XCTAssertTrue(status.startNotifier, @"Notifier didn't start???");

    status.forceOffline = YES;
    XCTAssertTrue(status.isForcedOffline, @"Setting forcedOffline didn't take!");
    XCTAssertEqual(status.networkStatus, FOSNetworkStatusNotReachable, @"Wrong network status.");
}

- (void)testRevertForcedOfflineSupport {

    FOSNetworkStatusMonitor *status = [FOSNetworkStatusMonitor statusMonitorForLocalWiFi];
    XCTAssertFalse(status.isForcedOffline, @"Haven't set forced offline yet!");
    XCTAssertTrue(status.startNotifier, @"Notifier didn't start???");

    status.forceOffline = YES;
    status.forceOffline = NO;
    XCTAssertFalse(status.isForcedOffline, @"Setting forcedOffline didn't take!");
    XCTAssertEqual(status.networkStatus, FOSNetworkStatusReachableViaWiFi, @"Wrong network status.");
}

#pragma mark - Initialization Tests

- (void)testInitParse {
    FOSNetworkStatusMonitor *status = [FOSNetworkStatusMonitor statusMonitorForParse];

    XCTAssertEqual(status.networkStatus, FOSNetworkStatusReachableViaWiFi, @"Wrong start status");
}

- (void)testInitInternetConnection {
    FOSNetworkStatusMonitor *status = [FOSNetworkStatusMonitor statusMonitorForInternetConnection];

    XCTAssertEqual(status.networkStatus, FOSNetworkStatusReachableViaWiFi, @"Wrong start status");
}

- (void)testInitLocalWiFi {
    FOSNetworkStatusMonitor *status = [FOSNetworkStatusMonitor statusMonitorForLocalWiFi];

    XCTAssertEqual(status.networkStatus, FOSNetworkStatusReachableViaWiFi, @"Wrong start status");
}

- (void)testInitHostName {
    FOSNetworkStatusMonitor *status =
        [FOSNetworkStatusMonitor statusMonitorWithHostName:@"api.parse.com"];

    XCTAssertEqual(status.networkStatus, FOSNetworkStatusReachableViaWiFi, @"Wrong start status");
}

#pragma mark - Current Status Tests

- (void)testCurrentStatusParse {
    FOSNetworkStatus networkStatus = [FOSNetworkStatusMonitor currentStatusForParse];

    XCTAssertEqual(networkStatus, FOSNetworkStatusReachableViaWiFi, @"Wrong start status");
}

- (void)testCurrentStatusInternetConnection {
    FOSNetworkStatus networkStatus = [FOSNetworkStatusMonitor currentStatusForInternetConnection];

    XCTAssertEqual(networkStatus, FOSNetworkStatusReachableViaWiFi, @"Wrong start status");
}

- (void)testCurrentStatusWiFi {
    FOSNetworkStatus networkStatus = [FOSNetworkStatusMonitor currentStatusForLocalWiFi];

    XCTAssertEqual(networkStatus, FOSNetworkStatusReachableViaWiFi, @"Wrong start status");
}

- (void)testCurrentStatusHostName {
    FOSNetworkStatus networkStatus =
        [FOSNetworkStatusMonitor currentStatusForHostName:@"api.parse.com"];

    XCTAssertEqual(networkStatus, FOSNetworkStatusReachableViaWiFi, @"Wrong start status");
}

#pragma mark - Callback Tests

- (void)testForceOfflineCallback {
    FOSNetworkStatusMonitor *status = [FOSNetworkStatusMonitor statusMonitorForLocalWiFi];
    XCTAssertTrue(status.startNotifier, @"Notifier didn't start???");

    // Setup handler
    __block BOOL handlerCalled = NO;
    __block NSString *capturedKeyPath = nil;
    __block id capturedObject = nil;
    __block FOSNetworkStatus capturedStatus = FOSNetworkStatusUnknown;

    [status addObserver:self forKeyPath:@"networkStatus" options:0 context:nil];
    _kvpHandler = ^void (NSString *keyPath, id object, NSDictionary *change, void *context) {
        handlerCalled = YES;
        capturedKeyPath = keyPath;
        capturedObject = object;

        capturedStatus = ((FOSNetworkStatusMonitor *)object).networkStatus;
    };

    // This should force offline and callback
    status.forceOffline = YES;
    [status removeObserver:self forKeyPath:@"networkStatus"];

    XCTAssertTrue(status.networkStatus == FOSNetworkStatusNotReachable, @"Wrong start status");
    XCTAssertTrue(handlerCalled, @"Handler not called?");
    XCTAssertTrue([capturedKeyPath isEqualToString:@"networkStatus"], @"Wrong KVP!");
    XCTAssertTrue([capturedObject isKindOfClass:[FOSNetworkStatusMonitor class]], @"Wrong class! Expected FOSNetworkStatusMonitor, got: '%@'", NSStringFromClass([capturedObject class]));
    XCTAssertEqual(capturedStatus, FOSNetworkStatusNotReachable, @"Wrong captured status. Expected %lu got '%lu'", (unsigned long)FOSNetworkStatusNotReachable, (unsigned long)capturedStatus);

    _kvpHandler = nil;
}

- (void)testForceOfflineNotification {
    FOSNetworkStatusMonitor *status = [FOSNetworkStatusMonitor statusMonitorForLocalWiFi];
    XCTAssertTrue(status.startNotifier, @"Notifier didn't start???");

    // Setup handler
    __block BOOL handlerCalled = NO;
    __block NSNotification *capturedNotification = nil;
    __block FOSNetworkStatus capturedStatus = FOSNetworkStatusUnknown;

    NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
    [center addObserver:self selector:@selector(_handleNotification:) name:kFOSNetworkStatusChangedNotification object:nil];

    [status addObserver:self forKeyPath:@"networkStatus" options:0 context:nil];
    _notificationHandler = ^void (NSNotification *aNote) {
        handlerCalled = YES;
        capturedNotification = aNote;

        capturedStatus = ((FOSNetworkStatusMonitor *)aNote.object).networkStatus;
    };

    // This should force offline and callback
    status.forceOffline = YES;
    [status removeObserver:self forKeyPath:@"networkStatus"];
    [center removeObserver:self];

    XCTAssertTrue(status.networkStatus == FOSNetworkStatusNotReachable, @"Wrong start status");
    XCTAssertTrue(handlerCalled, @"Handler not called?");
    XCTAssertTrue([capturedNotification.object isKindOfClass:[FOSNetworkStatusMonitor class]], @"Wrong class! Expected FOSNetworkStatusMonitor, got: '%@'", NSStringFromClass([capturedNotification.object class]));
    XCTAssertEqual(capturedStatus, FOSNetworkStatusNotReachable, @"Wrong captured status. Expected %lu got '%lu'", (unsigned long)FOSNetworkStatusNotReachable, (unsigned long)capturedStatus);

    _notificationHandler = nil;
}

- (void)testForceOnlineCallback {
    FOSNetworkStatusMonitor *status = [FOSNetworkStatusMonitor statusMonitorForLocalWiFi];
    XCTAssertTrue(status.startNotifier, @"Notifier didn't start???");
    status.forceOffline = YES;

    // Setup handler
    __block BOOL handlerCalled = NO;
    __block NSString *capturedKeyPath = nil;
    __block id capturedObject = nil;
    __block FOSNetworkStatus capturedStatus = FOSNetworkStatusUnknown;

    [status addObserver:self forKeyPath:@"networkStatus" options:0 context:nil];
    _kvpHandler = ^void (NSString *keyPath, id object, NSDictionary *change, void *context) {
        handlerCalled = YES;
        capturedKeyPath = keyPath;
        capturedObject = object;

        capturedStatus = ((FOSNetworkStatusMonitor *)object).networkStatus;
    };

    // This should force online and callback
    status.forceOffline = NO;
    [status removeObserver:self forKeyPath:@"networkStatus"];

    XCTAssertEqual(status.networkStatus, FOSNetworkStatusReachableViaWiFi, @"Wrong start status");
    XCTAssertTrue(handlerCalled, @"Handler not called?");
    XCTAssertTrue([capturedKeyPath isEqualToString:@"networkStatus"], @"Wrong KVP!");
    XCTAssertTrue([capturedObject isKindOfClass:[FOSNetworkStatusMonitor class]], @"Wrong class! Expected FOSNetworkStatusMonitor, got: '%@'", NSStringFromClass([capturedObject class]));
    XCTAssertEqual(capturedStatus, FOSNetworkStatusReachableViaWiFi, @"Wrong captured status.");

    _kvpHandler = nil;
}

- (void)testForceOnlineNotification {
    FOSNetworkStatusMonitor *status = [FOSNetworkStatusMonitor statusMonitorForLocalWiFi];
    XCTAssertTrue(status.startNotifier, @"Notifier didn't start???");
    status.forceOffline = YES;

    // Setup handler
    __block BOOL handlerCalled = NO;
    __block NSNotification *capturedNotification = nil;
    __block FOSNetworkStatus capturedStatus = FOSNetworkStatusUnknown;

    NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
    [center addObserver:self selector:@selector(_handleNotification:) name:kFOSNetworkStatusChangedNotification object:nil];

    [status addObserver:self forKeyPath:@"networkStatus" options:0 context:nil];
    _notificationHandler = ^void (NSNotification *aNote) {
        handlerCalled = YES;
        capturedNotification = aNote;

        capturedStatus = ((FOSNetworkStatusMonitor *)aNote.object).networkStatus;
    };

    // This should force offline and callback
    status.forceOffline = NO;
    [status removeObserver:self forKeyPath:@"networkStatus"];
    [center removeObserver:self];

    XCTAssertEqual(status.networkStatus, FOSNetworkStatusReachableViaWiFi, @"Wrong start status");
    XCTAssertTrue(handlerCalled, @"Handler not called?");
    XCTAssertTrue([capturedNotification.object isKindOfClass:[FOSNetworkStatusMonitor class]], @"Wrong class! Expected FOSNetworkStatusMonitor, got: '%@'", NSStringFromClass([capturedNotification.object class]));
    XCTAssertEqual(capturedStatus, FOSNetworkStatusReachableViaWiFi, @"Wrong captured status.");
    
    _notificationHandler = nil;
}

#pragma mark - Key-Value Callback

- (void)observeValueForKeyPath:(NSString *)keyPath
                      ofObject:(id)object
                        change:(NSDictionary *)change
                       context:(void *)context {

    if (_kvpHandler != nil) {
        _kvpHandler(keyPath, object, change, context);
    }
}

#pragma mark - Notification Callback
- (void)_handleNotification:(NSNotification *)aNote {
    if (_notificationHandler != nil) {
        _notificationHandler(aNote);
    }
}

@end
