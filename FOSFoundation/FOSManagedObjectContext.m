//
//  FOSManagedObjectContext.m
//  FOSFoundation
//
//  Created by David Hunt on 6/14/14.
//  Copyright (c) 2014 FOS Computer Services. All rights reserved.
//

#import "FOSManagedObjectContext.h"
#import "FOSCacheManager+CoreData.h"

@implementation FOSManagedObjectContext

- (void)setCacheManager:(FOSCacheManager *)cacheManager {
    _cacheManager = cacheManager;

    [self.cacheManager registerMOC:self];
}

- (void)dealloc {
    [self.cacheManager unregisterMOC:self];
}

@end
