//
//  FOSOperationQueue.m
//  FOSFoundation
//
//  Created by David Hunt on 12/22/12.
//  Copyright (c) 2012 FOS Computer Services. All rights reserved.
//

#import "FOSOperationQueue.h"
#import "FOSMergePolicy.h"
#import "FOSOperation+FOS_Internal.h"
#import "FOSManagedObjectContext.h"

@implementation FOSOperationQueue {
    BOOL _allOpsCanceled;
    NSMutableSet *_cancelledOps;
    FOSManagedObjectContext *_moc;
}

#pragma mark - Class Methods

+ (instancetype)queueWithRestConfig:(FOSRESTConfig *)restConfig {
    return [[self alloc] initWithRestConfig:restConfig];
}

#pragma mark - Public Properties

- (NSManagedObjectContext *)managedObjectContext {
    @synchronized(self) {
        // Let's make sure that the storeCoord hasn't changed
        if (_moc != nil && _moc.persistentStoreCoordinator != self.restConfig.databaseManager.storeCoordinator) {
            NSAssert(!_moc.hasChanges, @"The StoreCoordinator has changed, but there are changes in our MOC???");
            [self resetMOC];
        }

        if (_moc == nil) {
            NSAssert(self.restConfig != nil, @"No restConfig???");

            _moc = [[FOSManagedObjectContext alloc] initWithConcurrencyType:NSConfinementConcurrencyType];
            _moc.cacheManager = self.restConfig.cacheManager;
            _moc.persistentStoreCoordinator = self.restConfig.databaseManager.storeCoordinator;
            _moc.mergePolicy =
                [[FOSMergePolicy alloc] initWithMergeType:NSMergeByPropertyStoreTrumpMergePolicyType];
        }
    }

    return _moc;
}

- (FOSOperation *)currentOperation {

    // If this becomes too burdensome, we can add a binding between this class
    // and FOSOperation during FOSOperation.main.
    FOSOperation *result = nil;

    for (FOSOperation *nextOp in self.operations) {
        if (nextOp.isExecuting) {
            result = nextOp;
            break;
        }
    }

    NSAssert(result != nil, @"No current op???");

    return result;
}

- (BOOL)hasCancelledOperations {
    return _cancelledOps.count > 0;
}

- (NSSet *)cancelledOperations {
    NSSet *result = _cancelledOps;

    return result;
}

#pragma mark - Initiailization Methods

- (id)init {
    NSAssert(_restConfig != nil, @"Must call initWithRestConfig:");

    return [super init];
}

- (id)initWithRestConfig:(FOSRESTConfig *)restConfig {
    NSParameterAssert(restConfig != nil);

    _restConfig = restConfig;

    return [self init];
}

#pragma mark - Public Methods

- (void)markOperationAsCancelled:(FOSOperation *)cancelledOperation {
    if (_cancelledOps == nil) {
        _cancelledOps = [NSMutableSet set];
    }

    [_cancelledOps addObject:cancelledOperation];
}

- (void)clearCancelledOperations {
    _cancelledOps = nil;
}

#pragma mark - Overridden Methods

- (void)addOperation:(NSOperation *)op {
    NSParameterAssert(op != nil);

    // The web service queues NSOperations, so we have to handle that case
    if ([op isKindOfClass:[FOSOperation class]]) {
        NSParameterAssert(!((FOSOperation *)op).isQueued);
        
        ((FOSOperation *)op).isQueued = YES;
        ((FOSOperation *)op).operationQueue = self;
    }

    [super addOperation:op];
}

- (void)addOperations:(NSArray *)ops waitUntilFinished:(BOOL)wait {
    for (FOSOperation *nextOp in ops) {
        NSParameterAssert([nextOp isKindOfClass:[FOSOperation class]]);
        NSParameterAssert(!nextOp.isQueued);

        nextOp.isQueued = YES;
        nextOp.operationQueue = self;
    }

    [super addOperations:ops waitUntilFinished:wait];
}

- (void)cancelAllOperations {

    // These are one-shot (non-reusable) queues
    if (!_allOpsCanceled) {
        _allOpsCanceled = YES;
        [super cancelAllOperations];
    }
}

// FOS_Internal Methods

- (void)resetMOC {
    _moc = nil;
}

@end
