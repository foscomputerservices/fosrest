//
//  FOSRefreshUserOperation.m
//  FOSFoundation
//
//  Created by David Hunt on 1/1/13.
//  Copyright (c) 2013 FOS Computer Services. All rights reserved.
//

#import "FOSRefreshUserOperation.h"
#import "FOSCacheManager.h"

@implementation FOSRefreshUserOperation {
    NSError *_error;
}

+ (instancetype)refreshUserOperation {
    return [[self alloc] init];
}

- (id)init {
    if ((self = [super init]) != nil) {
        if (self.restConfig.loginManager.isLoggedIn) {
            [self addDependency:self._refreshUserRequest];
        }
        else {
            NSString *msg = NSLocalizedString(@"No user is currenlty logged in to refresh.", @"");

            _error = [NSError errorWithMessage:msg];
        }
    }

    return self;
}

#pragma mark - Overrides

- (NSError *)error {
    return _error;
}

- (void)main {
    [super main];

    if (!self.isCancelled) {
        FOSLogDebug(@"Refreshed user: %@", self.restConfig.loginManager.loggedInUserId);
    }
}

#pragma mark - Private methods

- (FOSBackgroundOperation *)_refreshUserRequest {
    FOSBackgroundOperation *result = nil;

    FOSJsonId loggedInUid = self.restConfig.loginManager.loggedInUserId;

    NSEntityDescription *entityDesc = [self.restConfig.userSubType entityDescription];

    id<FOSRESTServiceAdapter> adapter = self.restConfig.restServiceAdapter;
    FOSURLBinding *urlBinding = [adapter urlBindingForLifecyclePhase:FOSLifecyclePhaseRetrieveServerRecord
                                                      forLifecycleStyle:nil
                                                     forRelationship:nil
                                                       forEntity:entityDesc];

    NSError *localError = nil;
    NSURLRequest *urlRequest = [urlBinding urlRequestServerRecordOfType:entityDesc
                                                             withJsonId:loggedInUid
                                                           withDSLQuery:nil
                                                                  error:&localError];

    if (urlRequest != nil && localError == nil) {

        FOSWebServiceRequest *refreshRequest = [FOSWebServiceRequest requestWithURLRequest:urlRequest forURLBinding:urlBinding];

        __block FOSRefreshUserOperation *blockSelf = self;
        FOSBackgroundOperation *finalOp = [FOSBackgroundOperation backgroundOperationWithRequest:^(BOOL isCancelled, NSError *error) {
            if (refreshRequest.error == nil) {
                FOSRESTConfig *restConfig = blockSelf.restConfig;

                FOSUser *user = [restConfig.userSubType fetchWithId:loggedInUid];

                FOSURLBinding *userBinding =
                    [restConfig.restServiceAdapter urlBindingForLifecyclePhase:FOSLifecyclePhaseRetrieveServerRecord
                                                                forLifecycleStyle:nil
                                                               forRelationship:nil
                                                                 forEntity:user.entity];

                id<FOSTwoWayRecordBinding> binder = userBinding.cmoBinding;

                NSError *error = nil;
                if (![binder updateCMO:user
                              fromJSON:(NSDictionary *)refreshRequest.jsonResult
                     forLifecyclePhase:FOSLifecyclePhaseRetrieveServerRecord
                                 error:&error]) {
                    blockSelf->_error = error;
                }
            }
        }];

        [finalOp addDependency:refreshRequest];

        result = finalOp;
    }

    if (localError != nil) {
        _error = localError;
        result = nil;
    }

    return result;
};

@end
