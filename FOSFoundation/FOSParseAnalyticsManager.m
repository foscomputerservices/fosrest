//
//  FOSParseAnalyticsManager.m
//  FOSFoundation
//
//  Created by Administrator on 9/15/13.
//  Copyright (c) 2013 FOS Computer Services. All rights reserved.
//

static NSString *FOSParseEventEndPoint = @"1/events";

#import "FOSParseAnalyticsManager.h"
#import "FOSParseCachedManagedObject+FOS_Internal.h"

@implementation FOSParseAnalyticsManager {
    BOOL _kvoRegistered;
    NSMutableArray *_offlineBuffer;
}

#pragma mark - Initialization Methods

- (id)init {
    if ((self = [super init]) != nil) {
        _offlineBuffer = [NSMutableArray arrayWithCapacity:10];
    }
    
    return self;
}

#pragma mark - FOSAnalytics Protocol Methods

- (void)trackApplicationLaunched:(NSString *)appVersion {
    [self _trackEvent:@"AppOpened" withData:@{ @"appVersion" : appVersion }];
}

- (void)trackEvent:(NSString *)eventName withData:(NSDictionary *)eventData {
    NSParameterAssert(eventName.length > 0);
    NSParameterAssert(![eventName isEqualToString:@"AppOpened"]);

    [self _trackEvent:eventName withData:eventData];
}

#pragma mark - KVO Methods

- (void)observeValueForKeyPath:(NSString *)keyPath
                      ofObject:(id)object
                        change:(NSDictionary *)change
                       context:(void *)context {

    if ([keyPath isEqualToString:@"networkStatus"]) {
        [self _flushQueuedEvents];
    }
}

#pragma mark - Memory Management

- (void)dealloc {
    if (_kvoRegistered) {
        [[FOSRESTConfig sharedInstance] removeObserver:self forKeyPath:@"networkStatus"];
    }
}

#pragma mark - Private Methods

- (void)_queueEvent:(NSString *)eventName withData:(NSDictionary *)eventData {
    @synchronized(_offlineBuffer) {
        if (!_kvoRegistered) {
            [[FOSRESTConfig sharedInstance] addObserver:self forKeyPath:@"networkStatus" options:0 context:nil];
            _kvoRegistered = YES;
        }

        NSDictionary *newEntry = @{
           @"eventName" : eventName,
           @"eventData" : eventData == nil ? [NSNull null] : eventData
        };
        
        [_offlineBuffer addObject:newEntry];
    }
}

- (void)_flushQueuedEvents {
    if ([FOSRESTConfig sharedInstance].networkStatus != FOSNetworkStatusNotReachable) {
        NSMutableArray *bufferCopy = nil;
        
        @synchronized(_offlineBuffer) {
            bufferCopy  = [_offlineBuffer mutableCopy];
            [_offlineBuffer removeAllObjects];
        }
        
        for (NSDictionary *nextQueuedEvent in bufferCopy) {
            NSString *eventName = nextQueuedEvent[@"eventName"];
            id data = nextQueuedEvent[@"eventData"];
            NSDictionary *eventData = (data == [NSNull null]) ? nil : (NSDictionary *)data;
            
            [self _trackEvent:eventName withData:eventData];
        }
    }
}

- (void)_trackEvent:(NSString *)eventName withData:(NSDictionary *)eventData {
    NSParameterAssert(eventName.length > 0);

    if ([FOSRESTConfig sharedInstance].networkStatus == FOSNetworkStatusNotReachable) {
        [self _queueEvent:eventName withData:eventData];
    }
    else {
        NSString *endPoint = [NSString stringWithFormat:@"%@/%@", FOSParseEventEndPoint, eventName];
        
        // Parse has a unique way of representing dates
        id<NSObject> parseJsonDate = [FOSParseCachedManagedObject parseJsonValueForDate:[NSDate date]];
        NSMutableDictionary *data = [@{ @"at" : parseJsonDate } mutableCopy];
        
        if (eventData.count > 0) {
            data[@"dimensions"] = eventData;
        }
        NSArray *fragments = @[ data ];
        
        FOSWebServiceRequest *request = [FOSWebServiceRequest requestWithRequestType:FOSRequestMethodPOST
                                                                            endPoint:endPoint
                                                                        uriFragments:fragments];
        
        // This is *not* guaranteed transport.  Items could be lost if the request times out.
        [[FOSRESTConfig sharedInstance].cacheManager queueOperation:request
                                            withCompletionOperation:nil
                                                      withGroupName:@"AnalyticsEvent"];
    }
}

@end
