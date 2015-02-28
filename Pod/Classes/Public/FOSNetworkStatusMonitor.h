//
//  FOSNetworkStatusMonitor.h
//  FOSFoundation
//
//  Created by David Hunt on 3/11/13.
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

#import <Foundation/Foundation.h>
#import <SystemConfiguration/SystemConfiguration.h>

/*!
 * @typedef FOSNetworkStatus
 */
typedef NS_ENUM(NSUInteger, FOSNetworkStatus) {
    FOSNetworkStatusUnknown,
    FOSNetworkStatusNotReachable,
    FOSNetworkStatusReachableViaWiFi,
#if	TARGET_OS_IPHONE
    FOSNetworkStatusReachableViaWWAN,
#endif
};

#define kFOSNetworkStatusChangedNotification @"kFOSNetworkStatusChangedNotification"

@interface FOSNetworkStatusMonitor: NSObject

#pragma mark - Class methods

/*!
 * @method statusMonitorWithHostHostName:
 *
 * Use to check the network availabiity of a particular host name.
 */
+ (FOSNetworkStatusMonitor *)statusMonitorWithHostName:(NSString *)hostName;

/*!
 * @method statusMonitorForParse
 *
 * Use to check the network availability of parse.com.
 */
+ (FOSNetworkStatusMonitor *)statusMonitorForParse;

/*!
 * @method statusMonitorForInternetConnection
 *
 * Checks whether the default route is available.
 *
 * @discussion
 *
 * This method should be used by applications that do not connect to a particular host
 */
+ (FOSNetworkStatusMonitor *)statusMonitorForInternetConnection;

/*!
 * @method statusMonitorForLocalWiFi
 *
 * Checks whether a local wifi connection is available.
 */
+ (FOSNetworkStatusMonitor *)statusMonitorForLocalWiFi;

/*!
 * @method currentStatusForHostName:
 *
 * Returns the network status for the reachability of the given host name.
 *
 * @description
 *
 * This is a blocking request that may take a significant amount of time to complete
 * (see SCNetworkReachabilityGetFlags).
 *
 * For a non-blocking API, allocate an instance of FOSNetworkStatusMonitor and monitor
 * KVO notifications on networkStatus.
 */
+ (FOSNetworkStatus)currentStatusForHostName:(NSString *)hostName;

/*!
 * @method currentStatusForParse
 *
 * Returns the network status for the reachability of http://api.parse.com
 *
 * @description
 *
 * This is a blocking request that may take a significant amount of time to complete
 * (see SCNetworkReachabilityGetFlags).
 *
 * For a non-blocking API, allocate an instance of FOSNetworkStatusMonitor and monitor
 * KVO notifications on networkStatus.
 */
+ (FOSNetworkStatus)currentStatusForParse;

/*!
 * @method currentStatusForInternetConnection
 *
 * Returns the network status for the reachability of http://api.parse.com
 *
 * @description
 *
 * This is a blocking request that may take a significant amount of time to complete
 * (see SCNetworkReachabilityGetFlags).
 *
 * For a non-blocking API, allocate an instance of FOSNetworkStatusMonitor and monitor
 * KVO notifications on networkStatus.
 */
+ (FOSNetworkStatus)currentStatusForInternetConnection;

/*!
 * @method currentStatusForLocalWiFi
 *
 * Returns the network status for the reachability of the local WiFi network.
 *
 * @description
 *
 * This is a blocking request that may take a significant amount of time to complete
 * (see SCNetworkReachabilityGetFlags).
 *
 * For a non-blocking API, allocate an instance of FOSNetworkStatusMonitor and monitor
 * KVO notifications on networkStatus.
 */
+ (FOSNetworkStatus)currentStatusForLocalWiFi;

#pragma mark - Properties

/*!
 * @property networkStatus
 * 
 * Returns the current network status relative to the general availability of
 * the Internet.
 *
 * @discussion
 *
 * If isNotifierRunning == NO, this is a blocking request that may take a significant
 * amount of time to complete (see SCNetworkReachabilityGetFlags).
 *
 * If isNotifierRunning == YES, this is a non-blocking request that returns the last
 * known network status.  Monitor KVO notifications on this property for asynchronous
 * updates to this property.
 */
@property (nonatomic, readonly) FOSNetworkStatus networkStatus;

/*!
 * @property isNotifierRunning
 *
 * Returns YES after startNotifier has been called; NO if startNotifier has
 * not been called or stopNotifier has been called.
 *
 * This property supports Key-Value Observing.
 */
@property (nonatomic, readonly) BOOL isNotifierRunning;

#pragma mark - Public Methods

/*!
 * @method startNotifier
 *
 * Start listening for network status notifications on the current run loop.
 */
- (BOOL)startNotifier;

/*!
 * @method startNotifier
 *
 * Stop listening for network status notifications on the current run loop.
 */
- (void)stopNotifier;

@end
