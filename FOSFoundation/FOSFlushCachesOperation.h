//
//  FOSFlushCachesOperation.h
//  FOSFoundation
//
//  Created by David Hunt on 1/3/13.
//  Copyright (c) 2013 FOS Computer Services. All rights reserved.
//

#import <FOSFoundation/FOSFoundation.h>

@class FOSCacheManager;

@interface FOSFlushCachesOperation : FOSOperation

@property (nonatomic, readonly) FOSCacheManager *cacheManager;

+ (FOSFlushCachesOperation *)flushCacheOperationForCacheManager:(FOSCacheManager *)cacheManager;

@end
