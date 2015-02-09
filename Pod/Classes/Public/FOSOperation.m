//
//  FOSOperation.m
//  FOSFoundation
//
//  Created by David Hunt on 12/22/12.
//  Copyright (c) 2012 FOS Computer Services. All rights reserved.
//

#import <FOSOperation.h>
#import "FOSOperation+FOS_Internal.h"

@interface FOSOperation()

@property (nonatomic, assign) NSUInteger finishedDependentOperations;

@end

@implementation FOSOperation {
    BOOL _registeredFinishedDependentOperations;
    BOOL _registeredIsFinished;
    BOOL _cancelled;
    NSError *_dependentError;
}

- (FOSBeginOperation *)beginOperation {
    FOSBeginOperation *result = nil;

    // Find the 'begin' operation that contains the MOC
    for (FOSOperation *depOp in self.dependencies) {
        result = depOp.beginOperation;
        if (result != nil) {
            break;
        }
    }

    return result;
}

- (NSString *)groupName {
    return self.beginOperation.groupName;
}

- (NSManagedObjectContext *)managedObjectContext {
    NSManagedObjectContext *result = nil;

    if ([NSThread isMainThread]) {
        result = [FOSRESTConfig sharedInstance].databaseManager.currentMOC;
    }

    // Cannot use dbm.currentMOC here as that impl uses us to find the moc for other queues!
    else {
        @synchronized(self) {
            FOSOperationQueue *opQueue = (FOSOperationQueue *)[FOSOperationQueue currentQueue];

            NSAssert([opQueue isKindOfClass:[FOSOperationQueue class]],
                     @"How'd we get an operation queue of type %@ named %@??",
                     NSStringFromClass([opQueue class]),
                     opQueue.name);

            result =  opQueue.managedObjectContext;
        }
    }

    return result;
}

#define new
#ifdef old
- (NSError *)error {
    NSError *result = _error;

    if (result == nil) {
        @autoreleasepool {
            for (NSOperation *depOp in self.dependencies) {
                if ([depOp isKindOfClass:[FOSOperation class]]) {
                    result = ((FOSOperation *)depOp).error;
                }

                // Stop when we reach the top of our tree
                if ([depOp isKindOfClass:[FOSBeginOperation class]]) {
                    break;
                }

                if (result != nil) {
                    break;
                }
            }
        }
    }

    return result;
}
#endif

#ifdef new
- (NSError *)error {
    NSError *result = _error;

    if (result == nil && !_ignoreDependentErrors) {
        // Have any of our depdencies recorded errors?
        result = _dependentError;

        // Once we're finished, make one more pass up the tree and record
        // the error status.  Remembering the finished pass allows us
        // to quickly return nil once we've verified that our dependencies
        // had no errors.
        BOOL localFinished = self.isFinished;
        if (result == nil && (!localFinished || !_finishedErrorPass)) {
            @autoreleasepool {

                // Determine if any of our dependencies (or their deps) have errors
                for (NSOperation *depOp in self.dependencies) {
                    if ([depOp isKindOfClass:[FOSOperation class]]) {
                        _dependentError = ((FOSOperation *)depOp).error;
                    }

                    // Stop when we reach the top of our tree
                    if ([depOp isKindOfClass:[FOSBeginOperation class]]) {
                        break;
                    }

                    if (_dependentError != nil) {
                        break;
                    }
                }

                // Remember this is our final pass, if we're finished
                _finishedErrorPass = localFinished;

                result = _dependentError;
            }
        }
    }
    
    return result;
}
#endif

- (BOOL)isCancelled {
    BOOL result = _cancelled;

    if (!result && self.operationQueue.hasCancelledOperations) {
        @autoreleasepool {
            for (NSOperation *depOp in self.dependencies) {
                result = depOp.isCancelled;

                if (result) {
                    break;
                }

                // Stop when we reach the top of our tree
                if ([depOp isKindOfClass:[FOSBeginOperation class]]) {
                    break;
                }
            }
        }
    }

    return result;
}

- (BOOL)isPullOperation {
    return NO;
}

- (FOSRESTConfig *)restConfig {
    return [FOSRESTConfig sharedInstance];
}

- (id<FOSRESTServiceAdapter>)restAdapter {
    return self.restConfig.restServiceAdapter;
}

- (NSUInteger)totalDependentOperations {
    NSUInteger result = 1;

    for (FOSOperation *nextDep in self.dependencies) {
        result += nextDep.totalDependentOperations;
    }

    return result;
}

#pragma mark - KVO Methods

- (void)observeValueForKeyPath:(NSString *)keyPath
                      ofObject:(id)object
                        change:(NSDictionary *)change
                       context:(void *)context {

    if ([keyPath isEqualToString:@"finishedDependentOperations"] ||
        [keyPath isEqualToString:@"isFinished"]) {
        [self _updateFinishedOpCount];
    }
}

#pragma mark - Memory Management

- (void)dealloc {
    if (_registeredFinishedDependentOperations) {
        for (FOSOperation *depOp in self.dependencies) {
            [depOp removeObserver:self forKeyPath:@"finishedDependentOperations"];
        }
    }
    if (_registeredIsFinished) {
        [self removeObserver:self forKeyPath:@"isFinished"];
    }
}

#pragma mark - Overrides

- (void)addObserver:(NSObject *)observer
         forKeyPath:(NSString *)keyPath
            options:(NSKeyValueObservingOptions)options
            context:(void *)context {
    [super addObserver:observer forKeyPath:keyPath options:options context:context];

    if ([keyPath isEqualToString:@"finishedDependentOperations"] && !_registeredFinishedDependentOperations) {
        _finishedDependentOperations = [self calcFinishedOps];

        for (FOSOperation *depOp in self.dependencies) {
            [depOp addObserver:self forKeyPath:@"finishedDependentOperations" options:0 context:nil];
        }

        _registeredFinishedDependentOperations = YES;
    }
}

- (void)cancel {
    [super cancel];

    if (!_cancelled) {
        _cancelled = YES;

        NSAssert(self.operationQueue != nil, @"No operation queue yet???");
        [self.operationQueue markOperationAsCancelled:self];
    }
}

- (void)main {

    // Subclasses will fill in & *must* call super
    _mainCalled = YES;

    // If we're non-concurrent, the operation is completed as soon as
    // main is executed.  If we're concurrent, then we need to wait.
    if (!self.isConcurrent) {
        [self _updateFinishedOpCount];
    }
    else {
        [self addObserver:self forKeyPath:@"isFinished" options:0 context:0];
        _registeredIsFinished = YES;
    }
}

- (void)addDependency:(NSOperation *)op {
    NSParameterAssert(op != nil);
    NSParameterAssert([op isKindOfClass:[FOSOperation class]]);

    // NO CYCLES!!!
#ifndef NS_BLOCK_ASSERTIONS
    NSString *msg = @"A cycle was found in the dependcy graph.  Generally this happens because of queueing additional dependencies against an already queued item.  Doing so is fine, but it is necessary to add the dependencies against the original operation and then requeue the *original* operation.  This allows the FOSBeginOperation associated with the original operation to be located and all to be queued correctly.";

    NSAssert(![((FOSOperation *)op).flattenedDependencies containsObject:self], msg);
#endif

    if (op != nil) {
        [super addDependency:op];

        if (_registeredFinishedDependentOperations) {
            [op addObserver:self forKeyPath:@"finishedDependentOperations" options:0 context:nil];
        }
    }
}

- (void)removeDependency:(NSOperation *)op {

    if (_registeredFinishedDependentOperations) {
        [op removeObserver:self forKeyPath:@"finishedDependentOperations"];
    }

    [super removeDependency:op];
}

#pragma mark - Private Methods

- (void)_updateFinishedOpCount {

    NSUInteger newFinishedCount = [self calcFinishedOps];
    if (newFinishedCount != _finishedDependentOperations) {
        self.finishedDependentOperations = newFinishedCount;
    }
}

@end
