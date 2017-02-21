//
//  FOSCacheManager+CoreData.m
//  FOSRest
//
//  Created by David Hunt on 6/14/14.
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

#import <FOSCacheManager+CoreData.h>
#import "FOSREST_Internal.h"

@implementation FOSCacheManager (CoreData)

- (void)registerMOC:(FOSManagedObjectContext *)moc {
    NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
    BOOL isMainThread = [NSThread isMainThread];

    SEL sel = isMainThread
        ? @selector(_pushFromMainQueue:)
        : @selector(_updateMainQueue:);

    [center addObserver:self
               selector:sel
                   name:NSManagedObjectContextDidSaveNotification
                 object:moc];
}

- (void)unregisterMOC:(FOSManagedObjectContext *)moc {
    NSNotificationCenter *center = [NSNotificationCenter defaultCenter];

    [center removeObserver:self
                      name:NSManagedObjectContextDidSaveNotification
                    object:moc];
}

- (BOOL)shouldSkipServerDeletionOfId:(FOSJsonId)jsonId {
    BOOL result = NO;

    if (_skipServerDeletionIds != nil) {
        result = [_skipServerDeletionIds containsObject:jsonId];
    }

    return result;
}

- (void)skipServerDeletetionForId:(FOSJsonId)jsonId {
    if (_skipServerDeletionIds == nil) {
        _skipServerDeletionIds = [NSMutableSet set];
    }

    [_skipServerDeletionIds addObject:jsonId];
}

- (void)processOutstandingDeleteRequests {
    NSArray *outstandingDeletions = [_restConfig.databaseManager fetchEntitiesNamed:@"FOSDeletedObject"];

    if (outstandingDeletions.count > 0) {

        __block FOSCacheManager *blockSelf = self;
        NSManagedObjectContext *moc = _restConfig.databaseManager.currentMOC;

        // Each deletion op must be processed individually so that individual errors don't
        // affect the entire group and thus cause them to be repeatedly deleted from the
        // server because something else failed.
        //
        // TODO : The entity hierarchy probably needs to be consulted for deletion order.
        //        Parse.com doesn't care, but other RDBMSs do.
        for (FOSDeletedObject *nextDelete in outstandingDeletions) {

            NSError *localError = nil;
            NSManagedObjectID *nextDeleteID = nextDelete.objectID;
            FOSJsonId deleteJsonId = nextDelete.deletedJsonId;
            NSString *deleteEntityName = nextDelete.deletedEntityName;

            NSEntityDescription *nextDeleteEntity =
                [NSEntityDescription entityForName:deleteEntityName
                            inManagedObjectContext:moc];

            id<FOSRESTServiceAdapter> adapter = _restConfig.restServiceAdapter;
            FOSURLBinding *urlBinding =
                [adapter urlBindingForLifecyclePhase:FOSLifecyclePhaseDestroyServerRecord
                                   forLifecycleStyle:nil
                                     forRelationship:nil
                                           forEntity:nextDeleteEntity];

            NSDictionary *context = @{
                                      @"CMOID" : deleteJsonId,
                                      @"ENTITY" : nextDeleteEntity
                                      };

            if (urlBinding == nil) {
                NSString *msgFmt = @"Missing URL_BINDING for %@ phase for entity %@.";

                // Not all entities might be able to be destoryed on the server, so if there's
                // no destroy, just log it and move on.
                FOSLogDebug(msgFmt,
                            [FOSURLBinding stringForLifecycle:FOSLifecyclePhaseDestroyServerRecord],
                            nextDeleteEntity.name);
            }

            NSURLRequest *urlRequest = nil;

            if (localError == nil) {
                urlRequest = [urlBinding urlRequestForServerCommandWithContext:context
                                                                         error:&localError];
            }

            if (localError != nil) {
                // This is an error in the specification, throw
                NSException *e = [NSException exceptionWithName:@"FOSREST"
                                                         reason:localError.description
                                                       userInfo:localError.userInfo];

                @throw e;
            }

            FOSOperation *request = nil;

            if (urlRequest != nil) {
                request = [FOSWebServiceRequest requestWithURLRequest:urlRequest
                                                        forURLBinding:urlBinding];
            }
            else {
                // Just a dummy to allow the whole process to complete
                request = [[FOSOperation alloc] init];
            }

            FOSBackgroundOperation *bgOp = [FOSBackgroundOperation backgroundOperationWithRecoverableRequest:^FOSRecoveryOption(BOOL cancelled, NSError *error) {

                FOSRecoveryOption result = FOSRecoveryOption_NoRecovery;
                BOOL completeDeletion = YES;

                if (cancelled) {
                    FOSLogInfo(@"CANCELED: While deleting server record: %@", error.description);
                    completeDeletion = NO;
                }
                else if (error != nil) {
                    // TODO : This seems reasonable, but possibly the adapter needs to be involved
                    if (error.code == 404) {
                        completeDeletion = YES;
                        result = FOSRecoveryOption_Recovered;
                    }
                    else {
                        FOSLogError(@"ERROR: While deleting server record: %@", error.description);
                    }
                }

                if (completeDeletion) {
                    FOSLogDebug(@"DELETING DELETE RECORD: %@ (%@)", deleteEntityName, deleteJsonId);

                    NSManagedObjectContext *moc = blockSelf->_restConfig.databaseManager.currentMOC;

                    FOSDeletedObject *delObj = (FOSDeletedObject *)[moc existingObjectWithID:nextDeleteID error:nil];

                    // We've completed this deletion on the server, so get rid of the record
                    if (delObj != nil) {
                        [moc deleteObject:delObj];
                    }
                }
                
                return result;
            }];
            
            // We want bgOp run before the save op, so make a dep relationship
            // and queue as a package
            [bgOp addDependency:request];
            
            [self queueOperation:bgOp
         withCompletionOperation:nil
                   withGroupName:@"Process DELETE requests"];
        }
    }
}

#pragma mark - Private Methods

// The only MOC that we maintain long-term is FOSDatabase's mainThreadMOC.
// So, this is the only MOC that we need to migrate changes into when
// changes are made to the database.
//
// However, if changes are noted coming from the main thread, then we
// need to trigger an operation to push those changes to the web server.
- (void)_pushFromMainQueue:(NSNotification *)notification {
    NSAssert([NSThread isMainThread], @"Wrong thread!");

    __block FOSCacheManager *blockSelf = self;

    FOSLogDebug(@"*** Database *** updated from MAIN thread...");

    // Only auto-push changes if we're configured to do so
    if (_restConfig.isAutomaticallySynchronizing &&
        _restConfig.networkStatus != FOSNetworkStatusNotReachable) {

        FOSOperation *op = [FOSPushCacheChangesOperation pushCacheChangesOperation];
        FOSBackgroundOperation *bgOp = [FOSBackgroundOperation backgroundOperationWithRequest:^(BOOL cancelled, NSError *error) {
            FOSLogDebug(@"*** Database *** finished pushing changes to server.");
        }];

        [self queueOperation:op
     withCompletionOperation:bgOp
               withGroupName:@"Saving changes from MAIN thread"];
    }

    // Reset pause auto sync
    self.pauseAutoSync = NO;

    // Process deletions
    NSSet *deletedSet = [notification.userInfo objectForKey:NSDeletedObjectsKey];
    NSArray *deletedObjects = [deletedSet allObjects];

    // For Deleted objects, we need to remove them from the server as well.
    // Instead of queueing requests here, we create FOSDeletedObject entries
    // that will be processed later.  This ensures that the objects get deleted
    // from the server in then event that the request isn't able to go through
    // right away.
    NSMutableArray *queuedDeletedObjects = [NSMutableArray arrayWithCapacity:deletedObjects.count];

    for (id nextDelete in deletedObjects) {
        if ([nextDelete isKindOfClass:[FOSCachedManagedObject class]]) {
            FOSCachedManagedObject *deletedCMO = (FOSCachedManagedObject *)nextDelete;
            FOSJsonId delJsonId = deletedCMO.jsonIdValue;

            if (deletedCMO.hasBeenUploadedToServer && !deletedCMO.skipServerDelete) {
                // We do *not* want to create objects in the main thread moc as the user
                // has full control to save/rollback/modify/etc the main thread moc.  So,
                // we store up the requests in an array and create a background operation
                // that will create them in a separate moc.
                [queuedDeletedObjects addObject:nextDelete];
            }

            if (delJsonId != nil) {
                [_skipServerDeletionIds removeObject:delJsonId];
            }
        }
    }

    if (queuedDeletedObjects.count > 0) {

        NSManagedObjectContext *moc = _restConfig.databaseManager.currentMOC;
        NSEntityDescription *entityDesc = [NSEntityDescription entityForName:@"FOSDeletedObject"
                                                      inManagedObjectContext:moc];

        for (FOSCachedManagedObject *cmo in queuedDeletedObjects) {
            FOSDeletedObject *newEntry = [[FOSDeletedObject alloc] initWithEntity:entityDesc
                                                   insertIntoManagedObjectContext:moc];

            newEntry.deletedJsonId = (NSString *)cmo.jsonIdValue.description;
            newEntry.deletedEntityName = cmo.entity.name;

            FOSLogDebug(@"MARKED FOR DELETION: %@ (%@)",
                        newEntry.deletedEntityName,
                        newEntry.deletedJsonId);
        }

        if (_restConfig.isAutomaticallySynchronizing) {
            FOSBackgroundOperation *processDeletionsOp = nil;

            processDeletionsOp = [FOSBackgroundOperation backgroundOperationWithRequest:^(BOOL cancelled, NSError *error) {
                [blockSelf processOutstandingDeleteRequests];
            }];

            [self queueOperation:processDeletionsOp
         withCompletionOperation:nil
                   withGroupName:@"Processing DELETE Records"];
        }
    }
    else {
        NSArray *outstandingDeletions = [_restConfig.databaseManager fetchEntitiesNamed:@"FOSDeletedObject"];

        if (outstandingDeletions.count && _restConfig.isAutomaticallySynchronizing) {
            FOSBackgroundOperation *processDeletionsOp = [FOSBackgroundOperation backgroundOperationWithRequest:^(BOOL cancelled, NSError *error) {
                if (!cancelled && error == nil) {
                    // We put this call here as save will have been called for the FOSDeletedObject
                    // entites that we might have created below.
                    [blockSelf processOutstandingDeleteRequests];
                }
            }];

            [self queueOperation:processDeletionsOp
         withCompletionOperation:nil
                   withGroupName:@"Processing DELETE Records"];
        }
    }
}

- (void)_updateMainQueue:(NSNotification *)notification {

    __block FOSCacheManager *blockSelf = self;
    NSManagedObjectContext *moc = [blockSelf->_restConfig.databaseManager mainThreadMOC];

    [moc performBlock:^{
        FOSLogPedantic(@"*** MAIN Thread *** merging changes from BACKGROUND ***");

        blockSelf->_updatingMainThreadMOC = YES;

        // Fault in all updated objects so that NSFetchedResultsController will
        // properly handle filter predicates:
        //
        // http://mikeabdullah.net/merging-saved-changes-betwe.html
        NSSet *updated = [notification.userInfo objectForKey:NSUpdatedObjectsKey];
        for (NSManagedObject *anObject in updated) {
            [moc existingObjectWithID:anObject.objectID error:NULL];
        }

        // Bring over the changes
        [moc mergeChangesFromContextDidSaveNotification:notification];
        
        blockSelf->_updatingMainThreadMOC = NO;

        FOSLogPedantic(@"*** MAIN Thread *** merged changes from BACKGROUND ***");
    }];
}

@end
