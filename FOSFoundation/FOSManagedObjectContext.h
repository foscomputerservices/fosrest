//
//  FOSManagedObjectContext.h
//  FOSFoundation
//
//  Created by David Hunt on 6/14/14.
//  Copyright (c) 2014 FOS Computer Services. All rights reserved.
//

/*!
 * @class FOSManagedObjectContext
 *
 * The only additional feature that FOSManagedObjectContext provides is
 * to register and unregister the MOC with the FOSCacheManager.
 */
@interface FOSManagedObjectContext : NSManagedObjectContext

@property (nonatomic, weak) FOSCacheManager *cacheManager;

@end
