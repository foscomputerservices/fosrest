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

/*!
 * @method shouldSkipServerDeletionOfId:
 *
 * Reports as to whether the CMO with the given FOSJsonId is marked as being
 * skipped for deletion on the next sync pass.
 */
- (BOOL)shouldSkipServerDeletionOfId:(FOSJsonId)jsonId;

- (void)skipServerDeletetionForId:(FOSJsonId)jsonId;

- (void)processOutstandingDeleteRequests;
- (void)registerMOC:(FOSManagedObjectContext *)moc;
- (void)unregisterMOC:(FOSManagedObjectContext *)moc;

@end
