//
//  FOSLogoutOperation.m
//  FOSFoundation
//
//  Created by David Hunt on 1/2/13.
//  Copyright (c) 2013 FOS Computer Services. All rights reserved.
//

#import "FOSLogoutOperation.h"
#import "FOSCacheManager_Internal.h"
#import "FOSLoginManager_Internal.h"
#import "FOSFlushCachesOperation.h"

@implementation FOSLogoutOperation {
    NSError *_error;
}

#pragma mark - Class methods

+ (instancetype)logoutOperation {
    return [[self alloc] init];
}

- (id)init {
    if ((self = [super init]) != nil) {
        [self addDependency:self._logoutUserRequest];
    }

    return self;
}

#pragma mark - Overrides

- (NSError *)error {
    NSError *result = _error;

    if (result == nil) {
        result = [super error];
    }

    return result;
}

- (void)main {

    [super main];

    FOSLogInfo(@"Logged out");
}

#pragma mark - Private methods

- (FOSBackgroundOperation *)_logoutUserRequest {
    NSEntityDescription *entity = [self.restConfig.userSubType entityDescription];
    FOSWebServiceRequest *logoutRequest = nil;
    NSError *localError = nil;

    id<FOSRESTServiceAdapter> adapter = self.restAdapter;
    FOSURLBinding *urlBinding = [adapter urlBindingForLifecyclePhase:FOSLifecyclePhaseLogout
                                                      forLifecycleStyle:nil
                                                     forRelationship:nil
                                                           forEntity:entity];

    FOSUser *loggedInUser = self.restConfig.loginManager.loggedInUser;
    FOSJsonId loggedInUserId = loggedInUser.uid;

    if (urlBinding != nil) {
        NSDictionary *context = @{
                                  @"ENTITY" : loggedInUser.entity,
                                  @"CMOID" : loggedInUserId,
                                  @"USER_NAME" : loggedInUser.jsonUsername
                                };

        NSURLRequest *urlRequest = [urlBinding urlRequestForServerCommandWithContext:context
                                                                               error:&localError];

        if (localError == nil) {
            logoutRequest = [FOSWebServiceRequest requestWithURLRequest:urlRequest
                                                          forURLBinding:urlBinding];
        }
    }

    FOSBackgroundOperation *result = [FOSBackgroundOperation backgroundOperationWithRequest:^(BOOL isCancelled, NSError *error) {

        if (!isCancelled && error == nil) {
            self.restConfig.loginManager.loggedInUserId = nil;
            
            FOSLogInfo(@"Logged out user: %@", loggedInUserId);
        }
        else if (error != nil) {
            FOSLogError(@"Unable to complete logout due to error: %@", error.description);
        }
        else {
            FOSLogInfo(@"Logout cancelled.");
        }
    } callRequestIfCancelled:YES];

    if (localError == nil) {
        if (logoutRequest != nil) {
            [result addDependency:logoutRequest];
        }
    }
    else {
        _error = localError;
        result = nil;
    }

    return result;
}

@end
