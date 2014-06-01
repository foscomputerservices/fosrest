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
                FOSLogDebug(@"CREATED: Push op created...");
            }
            else {
                FOSLogDebug(@"SKIP: Skipping push as there's a pending push op...");
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
        FOSLogDebug(@"END: Pushing changes to server.");
    }
    else {
        @synchronized(self.restConfig) {
            self.restConfig.pendingPushOperation = nil;
        }

        if (self.isCancelled) {
            FOSLogInfo(@"CANCELED: Pushing changes to server.");
        }
        else {
            FOSLogError(@"ERROR: Pushing changes to server: %@", self.error.description);
        }
    }
}

#pragma mark - Private Methods

- (FOSOperation *)_pushChangesOp {
    FOSLogDebug(@"BEGIN: Pushing changes to server...");

    // Queue this after all of the updates are finished
    FOSOperation *completePushOp = [[FOSOperation alloc] init];

    [self _pushNonOwnedEntityChanges:completePushOp];
    [self _pushLoggedInUserChanges:completePushOp];

    return completePushOp;
}

- (void)_pushNonOwnedEntityChanges:(FOSOperation *)completePushOp {
    NSParameterAssert(completePushOp != nil);

    NSArray *allEntities = self.restConfig.storeCoordinator.managedObjectModel.entities;
    NSPredicate *pred = [NSPredicate predicateWithFormat:@"(jsonIgnoreAsStaticTableEntity == YES) || (%@ == YES && isStaticTableEntity == YES)",
                         self.restConfig.allowStaticTableModifications ? @YES : @NO];
    NSArray *nonOwnedEntities = [allEntities filteredArrayUsingPredicate:pred];

    for (NSEntityDescription *nonOwnedEntity in nonOwnedEntities) {
        Class nonOwnedClass = NSClassFromString(nonOwnedEntity.managedObjectClassName);
        NSPredicate *isDirtyPred = [FOSCacheManager isDirtyServerPredicate];
        NSArray *dirtyNonOwnedCMOs = [nonOwnedClass fetchWithPredicate:isDirtyPred];

        for (FOSCachedManagedObject *nextDirtyCMO in dirtyNonOwnedCMOs) {

            // Still need to check a few things in the instance as the predicate doesn't
            // cover any overridden functionality.
            if (!nextDirtyCMO.isLocalOnly && nextDirtyCMO.isDirty) {
                FOSOperation *pushOp = [nextDirtyCMO sendServerRecordWithLifecycleStyle:nil];

                [completePushOp addDependency:pushOp];
            }
        }
    }
}

- (void)_pushLoggedInUserChanges:(FOSOperation *)completePushOp {
    NSParameterAssert(completePushOp != nil);

    if (self.restConfig.loginManager.isLoggedIn) {
        FOSUser *user = self.restConfig.loginManager.loggedInUser;

        FOSOperation *pushOp = [user sendServerRecordWithLifecycleStyle:nil];
        NSAssert(![pushOp.flattenedDependencies containsObject:self.parentOperation],
                 @"Cycle in push dependencies???");

        [completePushOp addDependency:pushOp];
    }
}

@end
