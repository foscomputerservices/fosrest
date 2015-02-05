//
//  FOSRetrieveLoginDataOperation.m
//  FOSFoundation
//
//  Created by David Hunt on 5/28/14.
//  Copyright (c) 2014 FOS Computer Services. All rights reserved.
//

#import "FOSWebServiceRequest+FOS_Internal.h"
#import "FOSFoundation_Internal.h"

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

- (void)setOriginalJsonResult:(id<NSObject>)jsonResult
                postProcessor:(FOSRequestPostProcessor)postProcessor {

    __block FOSRetrieveLoginDataOperation *blockSelf = self;

    NSAssert(self.loginUser != nil, @"loginUser must be set!");

    [super setOriginalJsonResult:jsonResult postProcessor:^(id<NSObject> originalJson, id<NSObject> unwrappedJson) {
        if (postProcessor != nil) {
            postProcessor(originalJson, unwrappedJson);
        }

        // NOTE:
        //
        // We need to capture user authentication information after we've authenticated
        // with the server, but before the FOSRetrieveCMOOperation is run as the latter
        // will potential recurse required deps, which may cause further server requests
        // that need to be authenticated.  So we drop in an op to slide the fetched,
        // but not saved, user instance into the login manager.
        //
        // It's a bit tricky, but we've kinda got a chicken & egg scenario here.
        //
        // A specific example is that the adapter binding might have HEADER_FIELDS
        // specifications that retrieve properties off of the logged in user.  We
        // cannot save the user yet, as not all required deps have been realized.
        // However, in order to realize those deps, we need the user surfaced to the
        // adapter bindings so that subsequent server requests can be made.

        NSError *localError = nil;

        id<FOSRESTServiceAdapter> adapter = blockSelf.restAdapter;
        FOSURLBinding *urlBindig =
            [adapter urlBindingForLifecyclePhase:FOSLifecyclePhaseLogin
                                  forLifecycleStyle:nil
                                 forRelationship:nil
                                       forEntity:blockSelf.loginUser.entity];
        FOSCMOBinding *cmoBinding = urlBindig.cmoBinding;

        [cmoBinding updateCMO:blockSelf.loginUser
                     fromJSON:unwrappedJson
            forLifecyclePhase:FOSLifecyclePhaseLogin
                        error:&localError];

        if (localError != nil) {
            [blockSelf willChangeValueForKey:@"error"];
            blockSelf->_error = localError;
            [blockSelf didChangeValueForKey:@"error"];
        }
    }];
}

@end
