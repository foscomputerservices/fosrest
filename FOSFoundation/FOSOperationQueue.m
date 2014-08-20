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
}

- (NSManagedObjectContext *)managedObjectContext {
    @synchronized(self) {
        if (_moc == nil) {
            _moc = [[FOSManagedObjectContext alloc] initWithConcurrencyType:NSConfinementConcurrencyType];
            _moc.cacheManager = self.restConfig.cacheManager;
            _moc.persistentStoreCoordinator = [FOSRESTConfig sharedInstance].storeCoordinator;
            _moc.mergePolicy =
                [[FOSMergePolicy alloc] initWithMergeType:NSMergeByPropertyStoreTrumpMergePolicyType];
            _moc.undoManager = nil;
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

- (void)markOperationAsCancelled:(FOSOperation *)cancelledOperation {
    if (_cancelledOps == nil) {
        _cancelledOps = [NSMutableSet set];
    }

    [_cancelledOps addObject:cancelledOperation];
}

- (void)clearCancelledOperations {
    _cancelledOps = nil;
}

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

@end
