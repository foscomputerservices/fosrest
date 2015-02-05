//
//  FOSBeginOperation.m
//  FOSFoundation
//
//  Created by David Hunt on 12/22/12.
//  Copyright (c) 2012 FOS Computer Services. All rights reserved.
//

#import "FOSBeginOperation.h"
#import "FOSFoundation_Internal.h"

@implementation FOSBeginOperation {
    NSString *_groupName;
}

#pragma mark - Initialization

- (id)init {
    if ((self = [super init]) != nil) {
        _saveOperation = [[FOSSaveOperation alloc] init];
    }

    return self;
}

#pragma mark - Overrides

- (void)addObserver:(NSObject *)observer
         forKeyPath:(NSString *)keyPath
            options:(NSKeyValueObservingOptions)options
            context:(void *)context {

    // We don't want to the 'finishedDependentOperations' to our dependencies,
    // so stop that here.  This is because FOSBeginOperation is dependent on
    // previous save operations, but that's a different 'context' that we don't
    // want to monitor.
    if (![keyPath isEqualToString:@"finishedDependentOperations"]) {
        [super addObserver:observer forKeyPath:keyPath options:options context:context];
    }
}

- (FOSBeginOperation *)beginOperation {
    return self;
}

- (NSString *)groupName {
    return _groupName;
}

- (void)setGroupName:(NSString *)groupName {
    _groupName = groupName;
}

- (NSError *)error {
    // Don't traverse into our dependencies, which are save operations
    // for other blocks.
    return nil;
}

- (void)main {
    [super main];

    FOSLogDebug(@"-------------------- EXECUTING: Queue group - %@ --------------------", self.groupName);

    // Bring in changes from the store to eliminate conflicts
    FOSOperationQueue *myQueue = (FOSOperationQueue *)[FOSOperationQueue currentQueue];
    [myQueue resetMOC];

    NSAssert(self.managedObjectContext != nil, @"No MOC???");
    NSAssert(!self.managedObjectContext.hasChanges,
             @"The MOC should not have any changes at the beginning of an operation set!");
}

// Overriding these methods inhibits the calculation from passing
// the FOSBeginOperation.  FOSBeginOperations define a contextual
// boundary in the FOSOperation dependency graph.  FOSBeginOperations
// have dependencies against previous (in time) FOSSaveOperation
// instances to force linear processing of the FOSOperation graph,
// but for these calculation purposes, we stop at FOSBeginOperations.

- (NSUInteger)totalDependentOperations {
    // No need to use 1 here as almost all ops
    // are directly or indirectly dependent on FOSBeginOperations.
    return 0;
}

- (NSUInteger)finishedDependentOperations {
    // No need to use 1 here as almost all ops
    // are directly or indirectly dependent on FOSBeginOperations.
    return 0;
}

- (NSUInteger)calcFinishedOps {
    // No need to use 1 here as almost all ops
    // are directly or indirectly dependent on FOSBeginOperations.
    return 0;
}

@end
