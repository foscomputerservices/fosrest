//
//  FOSCacheManager.m
//  FOSFoundation
//
//  Created by David Hunt on 12/22/12.
//  Copyright (c) 2012 FOS Computer Services. All rights reserved.
//

#import "FOSCacheManager.h"
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
#import "FOSCacheManager+CoreData.h"

@implementation FOSCacheManager {
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

#pragma mark - Properties

- (BOOL)updatingMainThreadMOC {
    return _updatingMainThreadMOC;
}

#pragma mark - Public methods

- (id)initWithCacheConfig:(FOSRESTConfig *)restConfig {
    NSParameterAssert(restConfig != nil);
    NSParameterAssert(restConfig.storeCoordinator != nil);

    if ((self = [super init]) != nil) {

        _restConfig = restConfig;

        // Configure the queues
        _beginOpQueue = [[FOSOperationQueue alloc] init];
        _beginOpQueue.restConfig = _restConfig;
        _beginOpQueue.maxConcurrentOperationCount = 1;
        _beginOpQueue.name = @"FOSBeginOperation Queue";

        _fetchResolutionTimerQueue = [[NSOperationQueue alloc] init];
        _fetchResolutionTimerQueue.maxConcurrentOperationCount = 1;
        _fetchResolutionTimerQueue.name = @"Fetch Resolution Queue";
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
        [blockSelf processOutstandingDeleteRequests];
        
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

- (void)reQueueOperation:(FOSOperation *)operation {
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

    // There are dependencies between multiple ops in multiple queues that are managed
    // by this method (e.g. FOSBeginOp in one queue and the FOSSaveOp in another queue).
    //
    // For now we need to lock this method to ensure that the queueing is done in the
    // proper sequence.
    //
    // One symptom is that if this locking isn't done, then the FOSSaveOperation will
    // assert that's it's not been queued when it should already have been queued
    // (see 'Save op not yet queued????' assert below).
    //
    // TODO : Deep review to see if we can queue the dependent ops (including the save op)
    //        before we queue the begin op so that we can remove this locking.
    @synchronized(self) {

        NSParameterAssert(baseOperation != nil);
        NSParameterAssert(!baseOperation.isCancelled);
        NSParameterAssert(baseOperation.isQueued || groupName != nil);
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
            groupOpQueue.restConfig = _restConfig;
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

@end
