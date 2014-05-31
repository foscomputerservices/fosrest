//
//  FOSRetrieveLoginDataOperation.m
//  FOSFoundation
//
//  Created by David Hunt on 5/28/14.
//  Copyright (c) 2014 FOS Computer Services. All rights reserved.
//

#import "FOSWebServiceRequest+FOS_Internal.h"
#import "FOSRetrieveLoginDataOperation.h"

@implementation FOSRetrieveLoginDataOperation {
    NSError *_error;
}

#pragma mark - Overrides

- (NSError *)error {
    NSError *result = _error;

    if (result == nil) {
        result = [super error];
    }

    return  result;
}

- (void)setOriginalJsonResult:(id<NSObject>)jsonResult {
    [super setOriginalJsonResult:jsonResult];

    // NOTE:
    //
    // We need to capture user authentication information after we've authenticated
    // with the server, but before the FOSRetrieveCMOOperation is run as the latter
    // will potentiall recurse required deps, which may cause futher server requests
    // that need to be authenticated.  So we drop in an op to slide the fetched,
    // but not saved, user instance into the login manager.
    //
    // It's a bit tricky, but we've kinda got a chicken & egg scenario here.
    //
    // A specific example is that the adapterbinding might have HEADER_FIELDS
    // specifications that retrieve properties off of the logged in user.  We
    // cannot save the user yet, as not all required deps have been realized.
    // However, in order to realize those deps, we need the user surfaced to the
    // adapterbindings so that subsequent server requests can be made.

    NSError *localError = nil;

    NSAssert(self.loginUser != nil, @"loginUser must be set!");

    id<FOSRESTServiceAdapter> adapter = self.restAdapter;
    FOSURLBinding *urlBindig =
        [adapter urlBindingForLifecyclePhase:FOSLifecyclePhaseLogin
                              forLifecycleStyle:nil
                             forRelationship:nil
                                   forEntity:self.loginUser.entity];
    FOSCMOBinding *cmoBinding = urlBindig.cmoBinding;

    [cmoBinding updateCMO:self.loginUser
                 fromJSON:self.jsonResult
        forLifecyclePhase:FOSLifecyclePhaseLogin
                    error:&localError];

    if (localError != nil) {
        [self willChangeValueForKey:@"error"];
        _error = localError;
        [self didChangeValueForKey:@"error"];
    }
}

@end
