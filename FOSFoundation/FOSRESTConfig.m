//
//  FOSRESTConfig.m
//  FOSFoundation
//
//  Created by David Hunt on 12/25/12.
//  Copyright (c) 2012 FOS Computer Services. All rights reserved.
//

#import "FOSRESTConfig.h"
#import "FOSLoginManager.h"
#import "FOSUser.h"
#import "FOSParseAnalyticsManager.h"
#import "FOSWebService_Internal.h"

__strong FOSRESTConfig *__sharedInstance = nil;

@implementation FOSRESTConfig {
    NSSet *_validOfflineEndPoints;
    FOSNetworkStatusMonitor *_statusMonitor;
    FOSNetworkStatus _networkStatus;
    BOOL _networkStatusKVORegistered;
    FOSRESTConfigOptions _configOptions;
    id<FOSAnalytics> _analyticsManager;
    NSMutableDictionary *_entityModelCache;
}

#pragma mark - Property Overrides

- (NSDictionary *)headerFields {
    NSDictionary *result = nil;

    if ([self.restServiceAdapter respondsToSelector:@selector(headerFields)]) {
        result = self.restServiceAdapter.headerFields;
    }

    return result;
}

- (NSTimeInterval)defaultTimeout {
    return self.restServiceAdapter.defaultTimeout;
}

- (NSSet *)validOfflineEndPoints {
    if (_validOfflineEndPoints == nil) {
        self.validOfflineEndPoints = nil;
    }

    return _validOfflineEndPoints;
}

- (void)setValidOfflineEndPoints:(NSSet *)validOfflineEndpoints {
    NSMutableSet *endPoints = [validOfflineEndpoints mutableCopy];
    if (endPoints == nil) {
        endPoints = [NSMutableSet setWithCapacity:3];
    }

    _validOfflineEndPoints = endPoints;
}

- (BOOL)isFaultingEnabled {
    return ((_configOptions & FOSRESTConfigAllowFaulting) == FOSRESTConfigAllowFaulting);
}

- (BOOL)isAutomaticallySynchronizing {
    return ((_configOptions & FOSRESTConfigAutomaticallySynchronize) == FOSRESTConfigAutomaticallySynchronize);
}

- (BOOL)userNamesAreCaseSensitive {
    return ((_configOptions & FOSRESTConfigCaseSensitiveUserNames) == FOSRESTConfigCaseSensitiveUserNames);
}

- (BOOL)allowStaticTableModifications {
    return ((_configOptions & FOSRESTConfigAllowStaticTableModifications) == FOSRESTConfigAllowStaticTableModifications);
}

- (FOSNetworkStatus)networkStatus {
    return _networkStatus;
}

- (NSMutableDictionary *)modelCacheForModelKey:(NSString *)modelKey {
    NSMutableDictionary *result = nil;

    if (_entityModelCache == nil) {
        _entityModelCache = [NSMutableDictionary dictionaryWithCapacity:100];
    }

    result = _entityModelCache[modelKey];

    if (result == nil) {
        result = [NSMutableDictionary dictionaryWithCapacity:25];

        _entityModelCache[modelKey] = result;
    }

    return result;
}

- (Class)serviceRequestProcessorType {
    Class result = (_configOptions & FOSRESTConfigUseOfflineFiles) == FOSRESTConfigUseOfflineFiles
        ? [FOSParseFileService class]
        : [FOSWebService class];

    return result;
}

#pragma mark - Class Methods

+ (void)configWithApplicationVersion:(NSString *)appVersion
                             options:(FOSRESTConfigOptions)options
                         userSubType:(Class)userSubType
                    storeCoordinator:(NSPersistentStoreCoordinator *)storeCoordinator
                  restServiceAdapter:(id<FOSRESTServiceAdapter>)restServiceAdapter {
    NSParameterAssert(appVersion != nil);
    NSParameterAssert(userSubType != nil);
    NSParameterAssert(storeCoordinator != nil);
    NSParameterAssert(restServiceAdapter != nil);

    if (![userSubType isSubclassOfClass:[FOSUser class]]) {
        NSString *msg = NSLocalizedString(@"Bad userSubType '%@'.  userSubType must be a sub type of 'FOSUser'.",
                                          @"FOSBadUserSubType");

        [NSException raise:@"FOSBadUserSubType" format:msg, NSStringFromClass(userSubType)];
    }

    @synchronized(self) {
        if (__sharedInstance != nil) {
            NSString *msg = NSLocalizedString(@"Reconfiguration of FOSRESTConfig is not currently supported.", @"FOSCannotReconfigure");

            [NSException raise:@"FOSCannotReconfigure" format:@"%@", msg];
        }

        __sharedInstance = [[FOSRESTConfig alloc] _initWithOptions:(FOSRESTConfigOptions)options
                                                       userSubType:userSubType
                                                  storeCoordinator:storeCoordinator
                                                restServiceAdapter:restServiceAdapter];
    }
    
    if ([restServiceAdapter respondsToSelector:@selector(analyticsManager)] &&
        [restServiceAdapter.analyticsManager respondsToSelector:@selector(trackApplicationLaunched:)]) {
        [restServiceAdapter.analyticsManager trackApplicationLaunched:appVersion];
    }
}

+ (instancetype)sharedInstance {
    @synchronized(self) {
        if (__sharedInstance == nil) {
            NSString *msg = NSLocalizedString(@"FOSRESTConfig's config method must be called before a sharedInstance may be obtained.", @"");

            @throw [NSException exceptionWithName:@"FOSNotInitialized" reason:msg userInfo:nil];
        }

        return __sharedInstance;
    }
}

+ (void)resetSharedInstance {
    @synchronized(self) {
        __sharedInstance = nil;
    }
}

#pragma mark - KVO methods

- (void)observeValueForKeyPath:(NSString *)keyPath
                      ofObject:(id)object
                        change:(NSDictionary *)change
                       context:(void *)context {

    if (_networkStatus != _statusMonitor.networkStatus) {
        [self willChangeValueForKey:@"networkStatus"];
        _networkStatus = _statusMonitor.networkStatus;
        [self didChangeValueForKey:@"networkStatus"];

        // If we came back online and we're to auto sync, push
        // any delayed changes.
        if ((_networkStatus != FOSNetworkStatusNotReachable) &&
            (_configOptions & FOSRESTConfigAutomaticallySynchronize)) {
            [self.cacheManager flushCaches:nil];
        }
    }
}

#pragma mark - Memory Management methods

- (void)dealloc {
    if (_networkStatusKVORegistered) {
        [_statusMonitor removeObserver:self forKeyPath:@"networkStatus"];
    }
}

#pragma mark - FOSAnalytics Protocol Methods

- (void)trackEvent:(NSString *)eventName withData:(NSDictionary *)eventData {
    [_analyticsManager trackEvent:eventName withData:eventData];
}

#pragma mark - Private Methods

- (id)_initWithOptions:(FOSRESTConfigOptions)options
           userSubType:(Class)userSubType
      storeCoordinator:(NSPersistentStoreCoordinator *)storeCoordinator
    restServiceAdapter:(id<FOSRESTServiceAdapter>)restServiceAdapter {

    NSParameterAssert(userSubType != nil);
    NSParameterAssert(storeCoordinator != nil);
    NSParameterAssert(restServiceAdapter != nil);

    if ((self = [super init]) != nil) {
        // Store provided arguments
        _configOptions = options;
        _userSubType = userSubType;
        _storeCoordinator = storeCoordinator;
        _restServiceAdapter = restServiceAdapter;
        _statusMonitor = restServiceAdapter.networkStatusMonitor;

        if ([restServiceAdapter respondsToSelector:@selector(analyticsManager)]) {
            _analyticsManager = restServiceAdapter.analyticsManager;
        }

        // Create managers
        _databaseManager = [[FOSDatabaseManager alloc] initWithCacheConfig:self];
        _cacheManager = [[FOSCacheManager alloc] initWithCacheConfig:self];
        _loginManager = [[FOSLoginManager alloc] initWithCacheConfig:self];

        // Set initial network status.  This does seem to block in the simulator
        // sometimes, but we must have a stable status to begin with.  Otherwise
        // the login process may fail before the KVO callback is invoked as the KVO
        // callback is scheduled on the run loop and if control doesn't reach the
        // runloop before login, then all will fail.  (This happens during unit testing,
        // for example).
        _networkStatus = _statusMonitor.networkStatus;

        // Start listening for network status changes
        [_statusMonitor addObserver:self forKeyPath:@"networkStatus" options:0 context:nil];
        _networkStatusKVORegistered = YES;
        [_statusMonitor startNotifier];
    }

    return self;
}

// The 'EndPoints' that we are configured with are actually URI fragments
// and we don't want the substitution points to be included in the
// comparisons.
- (NSString *)_retrieveEndPoint:(NSString *)uriAndFragment {
    NSParameterAssert(uriAndFragment != nil);

    NSString *result = uriAndFragment;

    NSRange stopRange = [uriAndFragment rangeOfString:@"?"];
    if (stopRange.location == NSNotFound) {
        stopRange = [uriAndFragment rangeOfString:@"%"];
    }

    if (stopRange.location != NSNotFound) {
        result = [uriAndFragment substringToIndex:stopRange.location];
    }

    return result;
}

@end
