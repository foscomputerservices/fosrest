//
//  FOSFlushCachesOperation.m
//  FOSFoundation
//
//  Created by David Hunt on 1/3/13.
//  Copyright (c) 2013 FOS Computer Services. All rights reserved.
//

#import "FOSFlushCachesOperation.h"
#import "FOSCacheManager_Internal.h"
#import "FOSPushAllCacheChangesOperation.h"

@implementation FOSFlushCachesOperation

+ (FOSFlushCachesOperation *)flushCacheOperationForCacheManager:(FOSCacheManager *)cacheManager {
    return [[self alloc] initForCacheManager:cacheManager];
}

- (id)initForCacheManager:(FOSCacheManager *)cacheManager {
    NSParameterAssert(cacheManager != nil);

    if ((self = [super init]) != nil) {

        _cacheManager = cacheManager;

        [self addDependency:[self _depOp]];
    }

    return self;
}

- (FOSOperation *)_depOp {
    FOSBackgroundOperation *flushCompleteOp = [FOSBackgroundOperation backgroundOperationWithRequest:^(BOOL isCancelled, NSError *error) {
        if (isCancelled) {
            NSLog(@"FLUSH CANCELLED!");
        }
        else if (error != nil) {
            NSLog(@"FLUSH ERROR: %@", error.description);
        }
        else {
            NSLog(@"FLUSH COMPLETE: *** All queues ***");
        }
    } callRequestIfCancelled:YES];
    flushCompleteOp.queuePriority = NSOperationQueuePriorityVeryLow;

    // Push out any changes in the cache
    FOSPushAllCacheChangesOperation *pushAllChangesOp =
        [FOSPushAllCacheChangesOperation pushAllChangesOperation];

    [flushCompleteOp addDependency:pushAllChangesOp];

    return flushCompleteOp;
}

@end
