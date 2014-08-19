//
//  FOSNetworkStatusMonitor.m
//  FOSFoundation
//
//  Created by David Hunt on 3/11/13.
//  Copyright (c) 2013 FOS Computer Services. All rights reserved.
//
//
// This code has been adapted from Apple's Reachability example code:
//
//    http://developer.apple.com/library/ios/#samplecode/Reachability/Introduction/Intro.html

#import "FOSNetworkStatusMonitor.h"
#import "FOSNetworkStatusMonitor_FOS_Internal.h"

#import <sys/socket.h>
#import <netinet/in.h>
#import <netinet6/in6.h>
#import <arpa/inet.h>
#import <ifaddrs.h>
#import <netdb.h>

#import <CoreFoundation/CoreFoundation.h>

#define kShouldPrintReachabilityFlags 1

static void _ReachabilityCallback(SCNetworkReachabilityRef target,
        SCNetworkReachabilityFlags flags,
        void *info);

@implementation FOSNetworkStatusMonitor {
    BOOL _localWiFiRef;
    SCNetworkReachabilityRef _reachabilityRef;
    BOOL _notifierRunning;
    FOSNetworkStatus _lastNetworkStatus;
    BOOL _usingLocalHost;
}

#pragma mark - Class Methods

+ (FOSNetworkStatusMonitor *)statusMonitorWithHostName:(NSString *)hostName {
    FOSNetworkStatusMonitor* result = nil;

    BOOL usingLocalHost = ([hostName.lowercaseString rangeOfString:@"localhost"].location == 0);

    SCNetworkReachabilityRef reachability =
        SCNetworkReachabilityCreateWithName(NULL, hostName.UTF8String);

    if (reachability != NULL) {
        result = [[self alloc] init];

        if (result != nil) {
            result->_reachabilityRef = reachability;
            result->_localWiFiRef = NO;
            result->_usingLocalHost = usingLocalHost;
        }
        else {
            CFRelease(reachability);
        }
    }

    return result;
}

+ (FOSNetworkStatusMonitor *)statusMonitorForParse {
    FOSNetworkStatusMonitor *result = [self statusMonitorWithHostName:@"api.parse.com"];

    return result;
}

+ (FOSNetworkStatusMonitor *)statusMonitorForInternetConnection {
    struct sockaddr_in zeroAddress;
    bzero(&zeroAddress, sizeof(zeroAddress));
    zeroAddress.sin_len = sizeof(zeroAddress);
    zeroAddress.sin_family = AF_INET;

    return [self _statusMonitorWithAddress:&zeroAddress];
}

+ (FOSNetworkStatusMonitor *)statusMonitorForLocalWiFi {
    struct sockaddr_in localWifiAddress;
    bzero(&localWifiAddress, sizeof(localWifiAddress));
    localWifiAddress.sin_len = sizeof(localWifiAddress);
    localWifiAddress.sin_family = AF_INET;

    // IN_LINKLOCALNETNUM is defined in <netinet/in.h> as 169.254.0.0
    localWifiAddress.sin_addr.s_addr = htonl(IN_LINKLOCALNETNUM);
    FOSNetworkStatusMonitor* result = [self _statusMonitorWithAddress:&localWifiAddress];
    if (result != nil) {
        result->_localWiFiRef = YES;
    }

    return result;
}

+ (FOSNetworkStatus)currentStatusForHostName:(NSString *)hostName {
    FOSNetworkStatusMonitor *statusMonitor = [self statusMonitorWithHostName:hostName];

    return statusMonitor.networkStatus;
}

+ (FOSNetworkStatus)currentStatusForParse {
    FOSNetworkStatusMonitor *statusMonitor = [self statusMonitorForParse];

    return statusMonitor.networkStatus;
}

+ (FOSNetworkStatus)currentStatusForInternetConnection {
    FOSNetworkStatusMonitor *statusMonitor = [self statusMonitorForInternetConnection];

    return statusMonitor.networkStatus;
}

+ (FOSNetworkStatus)currentStatusForLocalWiFi {
    FOSNetworkStatusMonitor *statusMonitor = [self statusMonitorForLocalWiFi];

    return statusMonitor.networkStatus;
}

#pragma mark - Properties

- (void)setForceOffline:(BOOL)forceOffline {
    if (forceOffline != _forceOffline) {
        [self willChangeValueForKey:@"forceOffline"];
        _forceOffline = forceOffline;
        [self didChangeValueForKey:@"forceOffline"];

        if (_notifierRunning) {
            SCNetworkReachabilityFlags flags = 0;

            if (!forceOffline) {
                SCNetworkReachabilityGetFlags(_reachabilityRef, &flags);
            }

            _ReachabilityCallback(NULL, flags, (__bridge void *)(self));
        }

        // Force refresh
        else if (forceOffline) {
            _ReachabilityCallback(NULL, 0, (__bridge void *)(self));
        }
    }
}

#pragma mark - Public Methods

- (FOSNetworkStatus)networkStatus {
    NSAssert(_reachabilityRef != NULL, @"networkStatus retrieved with NULL reachabilityRef");

    FOSNetworkStatus result = FOSNetworkStatusNotReachable;
    if (!self.isForcedOffline) {
        if (_usingLocalHost) {
            result = FOSNetworkStatusReachableViaWiFi;
        }
        else {
            SCNetworkReachabilityFlags flags;

            if (_notifierRunning) {
                result = _lastNetworkStatus;
            }
            else if (SCNetworkReachabilityGetFlags(_reachabilityRef, &flags)) {
                if(_localWiFiRef) {
                    result = [[self class] _localWiFiStatusForFlags:flags];
                }
                else {
                    result = [[self class] _networkStatusForFlags:flags];
                }
            }
        }
    }

    return result;
}

- (BOOL)isNotifierRunning {
    return  _notifierRunning;
}

- (BOOL)startNotifier {
    BOOL result = NO;
    SCNetworkReachabilityContext context = {0, (__bridge void *)(self), NULL, NULL, NULL};

    // TODO: Possibly remove after iOS 8 stabilizes.  Currently getting false negatives for
    // reachability on updates.
    NSString *model = [[UIDevice currentDevice] model];
    NSString *sysVer = [[UIDevice currentDevice] systemVersion];

    if (!([sysVer isEqualToString:@"8.0"] && [model isEqualToString:@"iPhone Simulator"])) {

        if (SCNetworkReachabilitySetCallback(_reachabilityRef, _ReachabilityCallback, &context)) {
            if (SCNetworkReachabilityScheduleWithRunLoop(_reachabilityRef,
                                                         CFRunLoopGetCurrent(),
                                                         kCFRunLoopDefaultMode)) {
                result = YES;

                [self willChangeValueForKey:@"isNotifierRunning"];
                _notifierRunning = YES;
                [self didChangeValueForKey:@"isNotifierRunning"];
            }
        }

    }

    return result;
}

- (void)stopNotifier {
    if (_reachabilityRef != NULL) {
        SCNetworkReachabilityUnscheduleFromRunLoop(_reachabilityRef,
                                                   CFRunLoopGetCurrent(),
                                                   kCFRunLoopDefaultMode);

        [self willChangeValueForKey:@"isNotifierRunning"];
        _notifierRunning = NO;
        [self didChangeValueForKey:@"isNotifierRunning"];
    }
}

#pragma mark - Memory Management

- (void) dealloc {
    [self stopNotifier];

    if (_reachabilityRef != NULL) {
        CFRelease(_reachabilityRef);
    }
}

#pragma mark - Private Methods/Functions

+ (FOSNetworkStatusMonitor *)_statusMonitorWithAddress:(const struct sockaddr_in *)hostAddress {
    SCNetworkReachabilityRef reachability =
        SCNetworkReachabilityCreateWithAddress(kCFAllocatorDefault,
                                               (const struct sockaddr *)hostAddress);
    FOSNetworkStatusMonitor *result = nil;

    if (reachability != NULL) {
        result = [[self alloc] init];
        if (result!= nil) {
            result->_reachabilityRef = reachability;
            result->_localWiFiRef = NO;
        }
    }
    return result;
}

static void _PrintReachabilityFlags(SCNetworkReachabilityFlags flags, const char* comment) {
#if kShouldPrintReachabilityFlags

    FOSLogDebug(
#if	TARGET_OS_IPHONE
        @"Reachability Flag Status: %c%c %c%c%c%c%c%c%c %s\n",
          (flags & kSCNetworkReachabilityFlagsIsWWAN)               ? 'W' : '-',
#else
        @"Reachability Flag Status: %c%c %c%c%c%c%c%c %s\n",
#endif
          (flags & kSCNetworkReachabilityFlagsReachable)            ? 'R' : '-',

          (flags & kSCNetworkReachabilityFlagsTransientConnection)  ? 't' : '-',
          (flags & kSCNetworkReachabilityFlagsConnectionRequired)   ? 'c' : '-',
          (flags & kSCNetworkReachabilityFlagsConnectionOnTraffic)  ? 'C' : '-',
          (flags & kSCNetworkReachabilityFlagsInterventionRequired) ? 'i' : '-',
          (flags & kSCNetworkReachabilityFlagsConnectionOnDemand)   ? 'D' : '-',
          (flags & kSCNetworkReachabilityFlagsIsLocalAddress)       ? 'l' : '-',
          (flags & kSCNetworkReachabilityFlagsIsDirect)             ? 'd' : '-',
          comment
          );
#endif
}

static void _ReachabilityCallback(SCNetworkReachabilityRef target,
                                  SCNetworkReachabilityFlags flags,
                                  void *info) {
#pragma unused (target)
    NSCAssert(info != NULL, @"info was NULL in ReachabilityCallback");
    NSCAssert([(__bridge NSObject *)info isKindOfClass: [FOSNetworkStatusMonitor class]],
              @"info was wrong class in ReachabilityCallback");

    // We're on the main RunLoop, so an NSAutoreleasePool is not necessary, but is added defensively
    // in case someone uses the object in a different thread.
    @autoreleasepool {
        FOSNetworkStatusMonitor *statusMonitor = (__bridge FOSNetworkStatusMonitor *)info;

        FOSNetworkStatus newStatus = FOSNetworkStatusNotReachable;

        if (!statusMonitor.isForcedOffline) {
            if (statusMonitor->_usingLocalHost) {
                newStatus = FOSNetworkStatusReachableViaWiFi;
            }
            else {
                if(statusMonitor->_localWiFiRef) {
                    newStatus = [[statusMonitor class] _localWiFiStatusForFlags:flags];
                }
                else {
                    newStatus = [[statusMonitor class] _networkStatusForFlags:flags];
                }
            }
        }

        if (newStatus != statusMonitor->_lastNetworkStatus) {

            [statusMonitor willChangeValueForKey:@"networkStatus"];
            statusMonitor->_lastNetworkStatus = newStatus;
            [statusMonitor didChangeValueForKey:@"networkStatus"];

            // Post a notification to notify the client that the network reachability changed.
            NSNotificationCenter *notificationCenter = [NSNotificationCenter defaultCenter];
            [notificationCenter postNotificationName:kFOSNetworkStatusChangedNotification
                                              object:statusMonitor];
        }
    }
}

+ (FOSNetworkStatus)_localWiFiStatusForFlags:(SCNetworkReachabilityFlags) flags {
    _PrintReachabilityFlags(flags, "localWiFiStatusForFlags");

    FOSNetworkStatus result = FOSNetworkStatusNotReachable;
    if((flags & kSCNetworkReachabilityFlagsReachable) &&
       (flags & kSCNetworkReachabilityFlagsIsDirect)) {
        result = FOSNetworkStatusReachableViaWiFi;
    }

    return result;
}

+ (FOSNetworkStatus)_networkStatusForFlags:(SCNetworkReachabilityFlags)flags {
    _PrintReachabilityFlags(flags, "networkStatusForFlags");

    if ((flags & kSCNetworkReachabilityFlagsReachable) == 0) {
        // if target host is not reachable
        return FOSNetworkStatusNotReachable;
    }

    FOSNetworkStatus result = FOSNetworkStatusNotReachable;

    if ((flags & kSCNetworkReachabilityFlagsConnectionRequired) == 0) {
        // if target host is reachable and no connection is required
        //  then we'll assume (for now) that your on Wi-Fi
        result = FOSNetworkStatusReachableViaWiFi;
    }

    if ((((flags & kSCNetworkReachabilityFlagsConnectionOnDemand) != 0) ||
         (flags & kSCNetworkReachabilityFlagsConnectionOnTraffic) != 0)) {
        // ... and the connection is on-demand (or on-traffic) if the
        //     calling application is using the CFSocketStream or higher APIs

        if ((flags & kSCNetworkReachabilityFlagsInterventionRequired) == 0) {
            // ... and no [user] intervention is needed
            result = FOSNetworkStatusReachableViaWiFi;
        }
    }

#if	TARGET_OS_IPHONE
    if ((flags & kSCNetworkReachabilityFlagsIsWWAN) == kSCNetworkReachabilityFlagsIsWWAN) {
        // ... but WWAN connections are OK if the calling application
        //     is using the CFNetwork (CFSocketStream?) APIs.
        result = FOSNetworkStatusReachableViaWWAN;
    }
#endif
    
    return result;
}

@end
