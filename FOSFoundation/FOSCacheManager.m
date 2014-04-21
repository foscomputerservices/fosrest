//
//  FOSCacheManager.m
//  FOSFoundation
//
//  Created by David Hunt on 12/22/12.
//  Copyright (c) 2012 FOS Computer Services. All rights reserved.
//

#import "FOSCacheManager.h"
#import "FOSCacheManager_Internal.h"
#import "FOSRESTConfig.h"
#import "FOSDatabaseManager.h"
#import "FOSWebService_Internal.h"
#import "FOSCachedManagedObject.h"
#import "FOSOperationQueue.h"
#import "FOSSleepOperation.h"
#import "FOSUser.h"
#import "FOSRetrieveCMOOperation.h"
#import "FOSRetrieveCMODataOperation.h"
#import "FOSRetrieveToManyRelationshipOperation.h"
#import "FOSRetrieveToOneRelationshipOperation.h"
#import "FOSPullStaticTablesOperation.h"
#import "FOSLoginOperation.h"
#import "FOSLogoutOperation.h"
#import "FOSRefreshUserOperation.h"
#import "FOSFlushCachesOperation.h"
#import "FOSPushAllCacheChangesOperation.h"
#import "FOSMergePolicy.h"
#import "FOSOperation+FOS_Internal.h"

@implementation FOSCacheManager {
    __weak FOSRESTConfig *_restConfig;
    id<FOSProcessServiceRequest> _serviceRequestProcessor;

    FOSOperationQueue *_beginOpQueue;
    NSOperationQueue *_fetchResolutionTimerQueue;
    NSMutableSet *_groupQueues;

    __block BOOL _pushSyncOutstanding;
}

#pragma mark - Class methods

// This portion of the predicate can be fully executed in the SQL server.
// HOWEVER, it *must* be accompanied by a check
+ (NSPredicate *)isDirtyServerPredicate {

    // Note: We no longer check isLocal in the database as the user might want to override
    //       this property and toggle it to toggle sending to the server.  Thus, the db value
    //       might be out of date with reality.
    return [NSPredicate predicateWithFormat:@"(updatedWithServerAt == NULL || lastModifiedAt > updatedWithServerAt)"];
}

+ (NSPredicate *)isNotDirtyServerPredicate {
    return [NSPredicate predicateWithFormat:@"(updatedWithServerAt != NULL && lastModifiedAt <= updatedWithServerAt)"];
}

#pragma mark - Public methods

- (id)initWithCacheConfig:(FOSRESTConfig *)restConfig {
    NSParameterAssert(restConfig != nil);
    NSParameterAssert(restConfig.storeCoordinator != nil);

    if ((self = [super init]) != nil) {

        _restConfig = restConfig;

        // Configure the queues
        _beginOpQueue = [[FOSOperationQueue alloc] init];
        _beginOpQueue.maxConcurrentOperationCount = 1;
        _beginOpQueue.name = @"FOSBeginOperation Queue";

        _fetchResolutionTimerQueue = [[NSOperationQueue alloc] init];
        _fetchResolutionTimerQueue.maxConcurrentOperationCount = 1;
        _fetchResolutionTimerQueue.name = @"Fetch Resolution Queue";

        NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
        
        [center addObserver:self
                   selector:@selector(_modelUpdated:)
                       name:NSManagedObjectContextDidSaveNotification
                     object:nil];
    }
    
    return self;
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [_beginOpQueue setSuspended:YES];
    for (FOSOperationQueue *nextQueue in _groupQueues) {
        [nextQueue setSuspended:YES];
    }
}

- (void)flushCaches:(FOSBackgroundRequest)completionHandler {

    __block FOSCacheManager *blockSelf = self;

    // It takes a goodly amount of time to create the FOSFlushCachesOperation, and we
    // really should do it against state in a separate (stable) NSManagedObjectContext from the
    // main queue.
    FOSBackgroundOperation *bgOp = [FOSBackgroundOperation backgroundOperationWithRequest:^(BOOL cancelled, NSError *error) {
        [blockSelf _processOutstandingDeleteRequests];
        
        FOSFlushCachesOperation *flushCompleteOp = [FOSFlushCachesOperation flushCacheOperationForCacheManager:self];
        FOSBackgroundOperation *completionOp = [FOSBackgroundOperation backgroundOperationWithRequest:^(BOOL isCancelled, NSError *compError) {
            if (completionHandler != nil) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    completionHandler(isCancelled, compError);
                });
            }
        } callRequestIfCancelled:YES];

        // Push the final op
        [self queueOperation:flushCompleteOp
     withCompletionOperation:completionOp
               withGroupName:@"Flush caches"];
    }];

    [self queueOperation:bgOp withCompletionOperation:nil withGroupName:@"Queue Flush Caches"];
}

- (void)queueOperation:(FOSOperation *)baseOperation withCompletionOperation:(FOSOperation *)finalOp
         withGroupName:(NSString *)groupName {
    NSParameterAssert(groupName.length > 0);

    [self _queueOperation:baseOperation withCompletionOperation:finalOp withGroupName:groupName];
}

- (void)requeueOperation:(FOSOperation *)operation {
    NSParameterAssert(operation.isQueued);
    [self _queueOperation:operation withCompletionOperation:nil withGroupName:nil];
}

- (void)cancelOutstandingPullOperations {
    @synchronized(_beginOpQueue) {
        for (FOSOperation *nextOp in _beginOpQueue.operations) {
            if (!nextOp.isExecuting && nextOp.isPullOperation) {
                [nextOp cancel];
            }
        }
    }
}

#pragma mark - Internal Methods

- (id<FOSProcessServiceRequest>)serviceRequestProcessor {
    return _serviceRequestProcessor;
}

#pragma mark - Private Methods

- (void)_queueOperation:(FOSOperation *)baseOperation
withCompletionOperation:(FOSOperation *)finalOp
          withGroupName:(NSString *)groupName {

    NSParameterAssert(baseOperation != nil);
    NSParameterAssert(!baseOperation.isCancelled);
    NSParameterAssert(finalOp == nil || !finalOp.isQueued);
    NSParameterAssert(finalOp == nil || ![baseOperation.flattenedDependencies containsObject:finalOp]);
    NSParameterAssert(finalOp == nil || ![finalOp.flattenedDependencies containsObject:baseOperation]);

    // Do we already have a begin op/save op?
    FOSBeginOperation *beginOp = nil;

    // Determine the operation queue to use (there's at least baseOperation in this list)
    // Also determine if there's a begin op in the queue
    BOOL forceNewBeginOp = (groupName != nil);

    // An operation queue to bundle all group ops except for the begin op
    FOSOperationQueue *groupOpQueue = nil;

    if (forceNewBeginOp) {
        NSParameterAssert(groupName.length > 0);
        beginOp = [[FOSBeginOperation alloc] init];
        beginOp.groupName = groupName;

        groupOpQueue = [[FOSOperationQueue alloc] init];
        groupOpQueue.maxConcurrentOperationCount = 1;
        groupOpQueue.name = [NSString stringWithFormat:@"Inner Queue: %@", groupName];

        if (_groupQueues == nil) {
            _groupQueues = [NSMutableSet setWithCapacity:25];
        }

        // Do a little house cleaning
        else {
            NSPredicate *pred = [NSPredicate predicateWithFormat:@"operationCount == 0"];
            for (FOSOperationQueue *emptyGroupQueue in [_groupQueues filteredSetUsingPredicate:pred]) {
                [_groupQueues removeObject:emptyGroupQueue];
            }
        }

        [_groupQueues addObject:groupOpQueue];

        NSAssert(beginOp.saveOperation != nil, @"No save operation???");

        beginOp.saveOperation.baseOperation = baseOperation;
    }
    else {
        beginOp = baseOperation.beginOperation;

        NSParameterAssert(groupName == nil);

        NSAssert(beginOp != nil,
                 @"We should have found a begin op since we're merging into an existing group.");

        // Retrieve the inner operation queue from the previously queued operation
        NSAssert(beginOp.saveOperation.isQueued, @"Save op not yet queued????");
        NSAssert(!beginOp.saveOperation.isFinished, @"Save op already finished???");
        NSAssert(beginOp.saveOperation.operationQueue != nil, @"Save op doesn't have a queue???");
        groupOpQueue = beginOp.saveOperation.operationQueue;
    }

    NSAssert(groupOpQueue != nil, @"No inner operation queue???");

    // FOSBeginOperations are dependent on the last save op, so as to completely
    // serialize the queue(s).  This removes the chances of a saving a partial object
    // graph while one set of operations is in the middle of building an object graph.
    //
    // Since we really don't want to overwhelm the network connection anyway and thus
    // we only process one operation at at time in this queue, this is probably
    // okay.  However, if, in the future we want to allow parallel requests to
    // the server, we'll need to revisit this.
    //
    // Additionally, if we build things in parallel, we'll have to use side-by-side
    // background MOCs and move saved Entities from one MOC to the other so that
    // we don't created duplicate entries in FOSFetchEntityOperation, when looking
    // to see if an existing object already exists.
    if (!beginOp.isQueued) {
        @synchronized(_beginOpQueue) {
            if (_beginOpQueue.operationCount > 0) {
                FOSBeginOperation *lastQueued = _beginOpQueue.operations.lastObject;

                NSAssert([lastQueued isKindOfClass:[FOSBeginOperation class]],
                         @"How'd that happen? Expected FOSBeginOperation, but got %@",
                         NSStringFromClass([lastQueued class]));
                NSAssert(lastQueued.isQueued, @"Queued, but not queued???");

                [beginOp addDependency:lastQueued.saveOperation];
            }

            [_beginOpQueue addOperation:beginOp];
        }
    }

    NSAssert(beginOp != nil, @"We should have a beginOp by now.");
    NSAssert(beginOp.saveOperation != nil, @"The beginOp should have a saveOp.");

    // Queue the non-queued dependent operations
    NSSet *allDepOps = baseOperation.flattenedDependencies;
    NSAssert(allDepOps.count >= 1, @"At least baseOperation should be in allDepOps.");
    NSAssert([allDepOps containsObject:baseOperation], @"At least baseOperation should be in allDepOps.");

    for (FOSOperation *nextOperation in allDepOps) {

        // We don't need to check 'isCancelled' as we've asserted that baseOperation isn't
        // cancelled, so then none of its deps are cancelled either.
        //
        // Of course, this is based on to assumptions:
        //   1) Operation processing isn't multi-threaded
        //   2) FOSOperation.isCancelled does a complete dependency traversal
        if (!nextOperation.isQueued) {

            // HACK! - Push in the web service here...could use the FOSRESTConfig now
            if ([nextOperation isKindOfClass:[FOSWebServiceRequest class]]) {
                ((FOSWebServiceRequest *)nextOperation).serviceRequestProcessor = self._serviceRequestProcessor;
            }

            if (![nextOperation isKindOfClass:[FOSBeginOperation class]] &&
                ![nextOperation isKindOfClass:[FOSSaveOperation class]]) {

                // All 1st level ops are dependent on the 'beginOp'.
                if (nextOperation.dependencies.count == 0) {
                    [nextOperation addDependency:beginOp];
                }

                // The save op is dependent on all of the queued ops (except for 'finalOp').
                [beginOp.saveOperation addDependency:nextOperation];

                // Queue the op on the 'inner' queue
                [groupOpQueue addOperation:nextOperation];

                // Bind to the begin op for easy retrieval later if this op is
                // requeued.
                nextOperation.beginOperation = beginOp;

                // All operations must be directly or indirectly dependent on an FOSBeginOperation,
                // so all operations must have dependencies.
                NSAssert(nextOperation.dependencies.count > 0,
                         @"All non-FOSBeginOperation instances must have dependencies!");
            }
        }
    }

    // Now that save's deps have been registered, queue the save op, if not already queued
    if (!beginOp.saveOperation.isQueued) {
        [groupOpQueue addOperation:beginOp.saveOperation];
    }

    NSAssert(beginOp.isQueued && beginOp.saveOperation.isQueued, @"Hmm...");

    // If they provided a finalOp, then wire up the dependencies and queue it
    // (it runs after the save operation has completed)
    if (finalOp != nil) {
        [finalOp addDependency:beginOp.saveOperation];
        [groupOpQueue addOperation:finalOp];
    }
}

- (id<FOSProcessServiceRequest>)_serviceRequestProcessor {
    if (_serviceRequestProcessor == nil) {
        Class processorClass = _restConfig.serviceRequestProcessorType;

        _serviceRequestProcessor = [[processorClass alloc] initWithCacheConfig:_restConfig];
    }

    return _serviceRequestProcessor;
}

- (void)_ensureWebServiceRequestIsValid:(FOSWebServiceRequest *)request {
    BOOL validRequest =
        (_restConfig.loginManager.isLoggedIn) ||
        [FOSWebServiceRequest isValidLoggedOutEndpoint:request.endPoint];

    if (!validRequest) {

        NSString *msg = NSLocalizedString(@"Invalid offline request attempt: {%@}. Only offline urls are allowed to be executed when the app is offline.  See FOSRESTConfig.validOfflineEndpoints for more information.",
                                          @"FOSInvalidOfflineRequest");

        [NSException raise:@"FOSInvalidOfflineRequest" format:msg, request.endPoint];
    }
}

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
        NSLog(@"*** Database *** updated from MAIN thread...");

        // Only auto-push changes if we're configured to do so
        if (_restConfig.isAutomaticallySynchronizing &&
            _restConfig.networkStatus != FOSNetworkStatusNotReachable) {

            FOSOperation *op = [FOSPushAllCacheChangesOperation pushAllChangesOperation];
            FOSBackgroundOperation *bgOp = [FOSBackgroundOperation backgroundOperationWithRequest:^(BOOL cancelled, NSError *error) {
                NSLog(@"*** Database *** finished pushing changes to server.");
            }];

            [self queueOperation:op
         withCompletionOperation:bgOp
                   withGroupName:@"Saving changes from MAIN thread"];
        }

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

                if (deletedCMO.hasBeenUploadedToServer && !deletedCMO.skipServerDeleteTree) {
                    // We do *not* want to create objects in the main thread moc as the user
                    // has full control to save/rollback/modify/etc the main thread moc.  So,
                    // we store up the requests in an array and create a background operation
                    // that will create them in a seperate moc.
                    [queuedDeletedObjects addObject:nextDelete];
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

                newEntry.deletedJsonId = (NSString *)cmo.jsonIdValue;
                newEntry.deletedEntityName = cmo.entity.name;

                NSLog(@"MARKED FOR DELETION: %@ (%@)",
                      newEntry.deletedEntityName,
                      newEntry.deletedJsonId);
            }

            if (_restConfig.isAutomaticallySynchronizing) {
                FOSBackgroundOperation *processDeletionsOp = nil;

                    processDeletionsOp = [FOSBackgroundOperation backgroundOperationWithRequest:^(BOOL cancelled, NSError *error) {
                        [blockSelf _processOutstandingDeleteRequests];
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
                        [blockSelf _processOutstandingDeleteRequests];
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
        NSLog(@"*** Database *** updated from BACKGROUND thread...");

        void (^syncNotifyRequest)() = ^ {

            blockSelf->_updatingMainThreadMOC = YES;

            // Bring over the changes
            [blockSelf->_restConfig.databaseManager.currentMOC mergeChangesFromContextDidSaveNotification:notification];

            blockSelf->_updatingMainThreadMOC = NO;

            NSLog(@"*** MAIN Thread *** merged changes from BACKGROUND ***");
        };


        // Switch to main thread and update its MOC & send notifications
        // Don't let this thread go until that has completed.
        dispatch_sync(dispatch_get_main_queue(), syncNotifyRequest);
    }
}

- (void)_processOutstandingDeleteRequests {
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

            NSManagedObjectID *nextDeleteID = nextDelete.objectID;
            FOSJsonId deleteJsonId = nextDelete.deletedJsonId;
            NSString *deleteEntityName = nextDelete.deletedEntityName;

            NSEntityDescription *nextDeleteEntity =
                [NSEntityDescription entityForName:deleteEntityName
                            inManagedObjectContext:moc];

            id<FOSRESTServiceAdapter> adapter = _restConfig.restServiceAdapter;
            FOSURLBinding *urlBinding =
                [adapter urlBindingForLifecyclePhase:FOSLifecyclePhaseDestroyServerRecord
                                     forRelationship:nil
                                           forEntity:nextDeleteEntity];

            NSDictionary *context = @{
                                      @"CMOID" : deleteJsonId,
                                      @"ENTITY" : nextDeleteEntity
                                    };
            NSError *localError = nil;

            NSURLRequest *urlRequest = [urlBinding urlRequestForServerCommandWithContext:context
                                                                                   error:&localError];

            if (localError != nil) {
                // This is an error in the specification, throw
                NSException *e = [NSException exceptionWithName:@"FOSFoundation"
                                                         reason:localError.description
                                                       userInfo:localError.userInfo];

                @throw e;
            }

            FOSWebServiceRequest *request = [FOSWebServiceRequest requestWithURLRequest:urlRequest
                                                                          forURLBinding:urlBinding];

            FOSBackgroundOperation *bgOp = [FOSBackgroundOperation backgroundOperationWithRecoverableRequest:^FOSRecorveryOption(BOOL cancelled, NSError *error) {

                FOSRecorveryOption result = FOSRecorveryOption_NoRecovery;
                BOOL completeDeletion = YES;

                if (cancelled) {
                    NSLog(@"CANCELED: While deleting server record: %@", error.description);
                    completeDeletion = NO;
                }
                else if (error != nil) {
                    // TODO : This is parse specific
                    // 101 = object not found for delete, the record is no longer on the server

                    if (error.code == 101) {
                        completeDeletion = YES;
                        result = FOSRecorveryOption_Recovered;
                    }
                    else {
                        NSLog(@"ERROR: While deleting server record: %@", error.description);
                    }
                }

                if (completeDeletion) {
                    NSLog(@"DELETING DELETE RECORD: %@ (%@)", deleteEntityName, deleteJsonId);

                    NSManagedObjectContext *moc = blockSelf->_restConfig.databaseManager.currentMOC;

                    FOSDeletedObject *delObj = (FOSDeletedObject *)[moc objectWithID:nextDeleteID];

                    // We've completed this deletion on the server, so get rid of the record
                    [moc deleteObject:delObj];
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

@end
