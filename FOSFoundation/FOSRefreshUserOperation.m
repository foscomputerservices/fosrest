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
            FOSOperation *op = self._refreshUserRequest;
            if (op && self.error == nil) {
                [self addDependency:op];
            }
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

- (FOSOperation *)_refreshUserRequest {
    FOSOperation *result = nil;

    FOSJsonId loggedInUid = self.restConfig.loginManager.loggedInUserId;
    NSEntityDescription *entityDesc = [self.restConfig.userSubType entityDescription];

    FOSRetrieveCMOOperation *retrieveOp = [FOSRetrieveCMOOperation retrieveCMOForEntity:entityDesc
                                                                                 withId:loggedInUid];
    retrieveOp.allowFastTrack = NO;

    result = retrieveOp;

    return result;
}

@end
