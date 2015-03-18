//
//  FOSBeginOperation.m
//  FOSREST
//
//  Created by David Hunt on 12/22/12.
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

#import <FOSBeginOperation.h>
#import "FOSREST_Internal.h"

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
