//
//  FOSPushCacheChangesOperation.m
//  FOSFoundation
//
//  Created by David Hunt on 1/3/13.
//  Copyright (c) 2013 FOS Computer Services. All rights reserved.
//

#import "FOSPushCacheChangesOperation.h"
#import "FOSPushAllCacheChangesOperation.h"
#import "FOSOperation+FOS_Internal.h"

@implementation FOSPushCacheChangesOperation

+ (FOSPushCacheChangesOperation *)pushCacheChangesOperationWithParentOperation:(FOSPushAllCacheChangesOperation *)parentOperation {
    return [[self alloc] initWithParentOperation:parentOperation];
}

- (id)initWithParentOperation:(FOSPushAllCacheChangesOperation *)parentOperation {
    NSParameterAssert(parentOperation != nil);

    if ((self = [super init]) != nil) {
        _parentOperation = parentOperation;

        @synchronized(self.restConfig) {
            if (self.restConfig.pendingPushOperation == nil) {
                self.restConfig.pendingPushOperation = [self _pushChangesOp];
                NSLog(@"CREATED: Push op created...");
            }
            else {
                NSLog(@"SKIP: Skipping push as there's a pending push op...");
            }

            [self addDependency:self.restConfig.pendingPushOperation];
        }
    }

    return self;
}

#pragma mark - Overrides

- (void)main {
    [super main];

    // *LOOP* until all changes are done.
    if (!self.isCancelled && self.error == nil && self.parentOperation != nil) {
        @synchronized(self.restConfig) {
            self.restConfig.pendingPushOperation = nil;
        }
        NSLog(@"END: Pushing changes to server.");
    }
    else {
        @synchronized(self.restConfig) {
            self.restConfig.pendingPushOperation = nil;
        }

        if (self.isCancelled) {
            NSLog(@"CANCELED: Pushing changes to server.");
        }
        else {
            NSLog(@"ERROR: Pushing changes to server: %@", self.error.description);
        }
    }
}

#pragma mark - Private Methods

- (FOSOperation *)_pushChangesOp {
    NSLog(@"BEGIN: Pushing changes to server...");

    // Queue this after all of the updates are finished
    FOSBackgroundOperation *completePushOp = [FOSBackgroundOperation backgroundOperationWithRequest:^(BOOL isCancelled, NSError *error) {
    } callRequestIfCancelled:YES];

    FOSRESTConfig *restConfig = [FOSRESTConfig sharedInstance];
    if (restConfig.loginManager.isLoggedIn) {
        FOSUser *user = restConfig.loginManager.loggedInUser;

        FOSOperation *pushOp = [user sendServerRecord];
        NSAssert(![pushOp.flattenedDependencies containsObject:self.parentOperation],
                 @"Cycle in push dependencies???");

        [completePushOp addDependency:pushOp];
    }

    return completePushOp;
}

@end
