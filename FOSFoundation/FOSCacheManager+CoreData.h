//
//  FOSCacheManager+CoreData.h
//  FOSFoundation
//
//  Created by David Hunt on 6/14/14.
//  Copyright (c) 2014 FOS Computer Services. All rights reserved.
//

#import "FOSCacheManager.h"

@class FOSManagedObjectContext;

@interface FOSCacheManager (CoreData)

- (void)processOutstandingDeleteRequests;
- (void)registerMOC:(FOSManagedObjectContext *)moc;
- (void)unregisterMOC:(FOSManagedObjectContext *)moc;

@end
