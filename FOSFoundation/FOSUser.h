//
//  FOSUser.h
//  FOSFoundation
//
//  Created by David Hunt on 12/23/12.
//  Copyright (c) 2012 FOS Computer Services. All rights reserved.
//

@interface FOSUser : FOSCachedManagedObject

#pragma mark - Class Methods

/*!
 * @method createLoginUser
 *
 * Use this method to create an instance to pass to FOSLoginManager's createUser:
 * and loginUser: methods.  Any FOSUser instance passed to these methods that
 * is created using any other means will cause those methods to fail.
 *
 * @discussion
 *
 * This method creates the user instance in a separate NSManagedObjectContext
 * that is managed by the FOSLoginManager's internal mechanisms.  This ensures
 * that the user is never duplicated in the database.
 */
+ (instancetype)createLoginUser;

#pragma mark - Public Properties

@property (nonatomic, readonly) FOSJsonId uid;
@property (nonatomic, readonly) BOOL isLoginUser;
@property (nonatomic, strong) NSString *username;
@property (nonatomic, strong) NSString *password;

@end
