//
//  FOSPushCacheChangesOperation.m
//  FOSFoundation
//
//  Created by David Hunt on 1/3/13.
//
//  The MIT License (MIT)
//
//  Copyright (c) 2015 FOS Services, LLC
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in all
//  copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
//  SOFTWARE.
//

#import <FOSPushCacheChangesOperation.h>
#import "FOSOperation+FOS_Internal.h"

@implementation FOSPushCacheChangesOperation

+ (FOSPushCacheChangesOperation *)pushCacheChangesOperation {
    return [[self alloc] init];
}

- (id)init {

    if ((self = [super init]) != nil) {
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
    if (!self.isCancelled && self.error == nil) {
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

    NSArray *allEntities = self.restConfig.databaseManager.storeCoordinator.managedObjectModel.entities;
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

        if (!user.isLocalOnly) {
            FOSOperation *pushOp = [user sendServerRecordWithLifecycleStyle:nil];

            [completePushOp addDependency:pushOp];
        }
    }
}

@end
