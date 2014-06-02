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

/*!
 * @property uid
 *
 * The unique identifier of the user according to the server.
 */
@property (nonatomic, readonly) FOSJsonId uid;

/*!
 * @property jsonUsername
 *
 * A value used to identify the user from the perspective of a
 * username/password tuple.
 *
 * Its value is surfaced to the adapter map via the $USER_NAME variable.
 *
 * @discussion
 *
 * This is an abstract property that must be overridden by subclasses to map
 * to the actual property that is used by the server.
 */
@property (nonatomic, strong) NSString *jsonUsername;

/*!
 * @property isLoginUser
 *
 * Indicates that this instance is being used to login.  This property
 * is set when createLoginUser is used to create the instance.
 *
 * @discussion
 *
 * This property is *not* stored in the database.
 */
@property (nonatomic, readonly) BOOL isLoginUser;

/*!
 * @property password
 *
 * The password to use for authentication when isLoginUser is
 * set to YES.
 *
 * @discussion
 *
 * This property is *not* stored in the database.
 */
@property (nonatomic, strong) NSString *password;

@end
