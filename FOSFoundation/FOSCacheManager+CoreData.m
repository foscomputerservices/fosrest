//
//  FOSCacheManager+CoreData.m
//  FOSFoundation
//
//  Created by David Hunt on 6/14/14.
//  Copyright (c) 2014 FOS Computer Services. All rights reserved.
//

#import "FOSCacheManager+CoreData.h"
#import "FOSFoundation_Internal.h"

@implementation FOSCacheManager (CoreData)

- (void)registerMOC:(FOSManagedObjectContext *)moc {
    NSNotificationCenter *center = [NSNotificationCenter defaultCenter];

    [center addObserver:self
               selector:@selector(_modelUpdated:)
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
                NSException *e = [NSException exceptionWithName:@"FOSFoundation"
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
                    // TODO : This is parse specific
                    // 101 = object not found for delete, the record is no longer on the server

                    if (error.code == 101) {
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
- (void)_modelUpdated:(NSNotification *)notification {

    __block FOSCacheManager *blockSelf = self;

    // The queue to update is the opposite of the thread on which
    // we were called.  So, main thread, means push changes to server.
    if ([NSThread isMainThread]) {
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
        NSSet *deletedSet;
        deletedSet = [notification.userInfo objectForKey:NSDeletedObjectsKey];
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

                [_skipServerDeletionIds removeObject:delJsonId];
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

    // Non-main thread means update mainThreadMOC (and deliver any change notifications).
    else {
        FOSLogDebug(@"*** Database *** updated from BACKGROUND thread...");

        void (^syncNotifyRequest)() = ^ {

            blockSelf->_updatingMainThreadMOC = YES;

            // Bring over the changes
            [blockSelf->_restConfig.databaseManager.currentMOC mergeChangesFromContextDidSaveNotification:notification];

            blockSelf->_updatingMainThreadMOC = NO;

            FOSLogDebug(@"*** MAIN Thread *** merged changes from BACKGROUND ***");
        };
        
        
        // Switch to main thread and update its MOC & send notifications
        // Don't let this thread go until that has completed.
        dispatch_sync(dispatch_get_main_queue(), syncNotifyRequest);
    }
}

@end
