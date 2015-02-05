//
//  FOSLoginManager.h
//  FOSFoundation
//
//  Created by David Hunt on 12/22/12.
//  Copyright (c) 2012 FOS Computer Services. All rights reserved.
//

@import Foundation;
#import <FOSFoundation/FOSCachedManagedObject.h>

typedef void (^FOSLoginHandler)(BOOL succeeded, NSError *error);

@interface FOSLoginManager : NSObject

#pragma mark - Public Properties

/*!
 * @property isLoggedIn
 *
 * @return
 *
 * YES if the application has server credentials stored,
 * NO otherwise.
 *
 * @discussion
 *
 * The concept of 'logged in' is that the application has
 * credentials stored that *could* be used to authenticate calls
 * to the server.  Thus, this check is a trivial check that there
 * are credentials saved.
 *
 * Being 'logged in' has nothing to do with 'online status' and
 * whether the server is actually available.
 *
 * This property is KVO compliant.
 */
@property (nonatomic, readonly) BOOL isLoggedIn;

/*!
 * @property loggedInUserId
 *
 * Upon login the receiver stores the logged in FOSUser's uid
 * to remember which user was logged in.  This information can be
 * retrieved at any time via this property.
 *
 * If the user is logged out, this property will return nil.
 *
 * This property is KVO compliant.
 */
@property (nonatomic, readonly) FOSJsonId loggedInUserId;

/*!
 * @property isLoggingOut
 *
 * Upon logout request, this property is set to YES until
 * the logout process has completed.
 *
 * This property is KVO compliant.
 */
@property (nonatomic, readonly) BOOL isLoggingOut;

/*!
 * @property loggedInUser
 *
 * @return
 *
 * The currently logged in user information or nil if the
 * user is not logged in.
 *
 * The resulting type is actually an instance of the class
 * indicated by the FOSRESTConfig's userSubType
 * parameter, which is a subtype of FOSUser.
 *
 * This property is KVO compliant.
 */
@property (nonatomic, readonly) FOSUser *loggedInUser;

// Public Methods
- (id)initWithCacheConfig:(FOSRESTConfig *)restConfig;

/*!
 * @method createUser:createStyle:handler:
 *
 * @param user  An FOSUser (or subtype) instance to use for account creation
 *
 * @param createStyle A style to match the 'LIFECYCLE_STYLE' of the login URL_BINDING
 *                   specification.  If none is required, this parameter may be nil.
 *
 * @param handler  A callback that will be invoked after the success/failure of the call
 *
 * @throws FOSLoggedIn, FOSLocalUser
 *
 * @discussion
 *
 * - It is illegal to call this method if an account is already logged in.
 * - 'user' must be marked as isLoginUser
 *
 * Upon successful call to 'handler', ownership of 'user' is taken over by the login manager.
 * If a temporary user was created, there's no need to delete it.  At the same time,
 * 'user' should be considered invalid and re-obtained from the receiver via
 * the 'loggedInUser' property.
 */
- (void)createUser:(FOSUser *)user createStyle:(NSString *)createStyle handler:(FOSLoginHandler)handler;

/*!
 * @method loginUser:loginStyle:handler:
 *
 * Provides a mechanism for authenticating to the server with
 * the given credentials.
 *
 * @param user  An FOSUser (or subtype) instance to use for authentication
 *
 * @param loginStyle A style to match the 'LIFECYCLE_STYLE' of the login URL_BINDING
 *                   specification.  If none is required, this parameter may be nil.
 *
 * @param handler  A callback that will be invoked after the success/failure of the call
 *
 * @throws FOSLoggedIn
 *
 * @discussion
 *
 * - This method must be called from the Main thread.
 * - It is illegal to call this method if an account is already logged in.
 * - 'user' must have either the isLocalOnly or isLoginUser set
 *
 * Upon successful call to 'handler', ownership of 'user' is taken over by the login manager.
 * If a temporary user was created, there's no need to delete it.  At the same time,
 * 'user' should be considered invalid and re-obtained from the receiver via
 * the 'loggedInUser' property.
 */
- (void)loginUser:(FOSUser *)user loginStyle:(NSString *)loginStyle handler:(FOSLoginHandler)handler;

/*!
 * @method refreshLoggedInUser:
 *
 * This method should be called when the application is initialized
 * this method should be invoked to refresh account information
 * related to the logged in user.
 *
 * It is not necessary, but okay, to check if the user is logged in
 * before calling this method.  If the user isn't logged in, then
 * succeeded will equal NO and error will equal nil;
 */
- (void)refreshLoggedInUser:(FOSLoginHandler)handler;

/*!
 * @method logout:
 *
 * @throws FOSNotLoggedIn
 *
 * @discussion
 *
 * It is illegal to call this method if the account is not already logged in or
 * if a logout operation is already scheduled.
 */
- (void)logout:(FOSLoginHandler)handler;

/*!
 * @method resetPasswordForResetKey:andValue:
 *
 * Sends a request to the server to reset the user's password.
 *
 * @param resetKey   A value to send to the jsonPasswordResetEndPoint as the key
 *                   of the packet.
 *
 * @param resetValue  A value that can be passed to the jsonPasswordResetEndPoint to
 *                    indicate to the web service which account to reset.  Often this
 *                    value is an email or user id.
 *
 * @param handler  A callback that is invoked after the request has been
 *                 attempted to be delivered to the server and the status
 *                 of the attempt.
 *
 * @discussion
 *
 * This method may be called regardless of whether the user is logged in.
 */
- (void)resetPasswordForResetKey:(NSString *)resetKey
                        andValue:(NSString *)resetValue
                         handler:(FOSLoginHandler)handler;

@end
