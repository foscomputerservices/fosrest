//
//  FOSLoginManager_Internal.h
//  FOSFoundation
//
//  Created by David Hunt on 12/22/12.
//  Copyright (c) 2012 FOS Computer Services. All rights reserved.
//

#import "FOSLoginManager.h"

@interface FOSLoginManager ()

#pragma mark - Class Methods

/*!
 * @method loginContext
 *
 * A separate context into which FOSUser objects are placed during
 * the creation or login process.
 *
 * @discussion
 *
 * The objects created during the create/login process are later
 * discarded internally and the replaced with instances that are pulled
 * from the REST service.
 *
 * By using a separate context into which these instances are created
 * we allow for a simple and extendable API in which to specify FOSUser
 * objects to be crated/logged into the REST service while, at the same time,
 * ensuring that there will be no duplication in the system.
 */
+ (NSManagedObjectContext *)loginUserContext;

@end

@interface FOSLoginManager(Test)

+ (void)dropSharedInstace;
+ (void)clearLoggedInUserId;

- (void)setUserIsLoggingIn;
- (void)setLoggedInUserId:(NSManagedObjectID *)loggedInUserId;

@end