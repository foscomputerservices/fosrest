//
//  FOSEnsureNetworkConnection.m
//  FOSFoundation
//
//  Created by David Hunt on 6/16/14.
//  Copyright (c) 2014 FOS Computer Services. All rights reserved.
//

#import "FOSEnsureNetworkConnection.h"
#import "FOSOperation+FOS_Internal.h"

@implementation FOSEnsureNetworkConnection {
    BOOL _cancelStarted;
}

#pragma mark - Overrides

- (BOOL)isReady {
    BOOL result = [super isReady];

    // Calling [self cancel] can cause infinite recusion if we don't block against subsequent
    // calls.  Also, we cannot cancel ourself until we've been queued.
    if (result &&
        !_cancelStarted &&
        self.operationQueue != nil &&
        self.restConfig.networkStatus == FOSNetworkStatusNotReachable) {
        _cancelStarted = YES;

        [self cancel];
    }

    return result;
}

@end
