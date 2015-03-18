//
//  FOSUser.h
//  FOSREST
//
//  Created by David Hunt on 12/23/12.
//
//  The MIT License (MIT)
//
//  Copyright (c) 2015 FOS Services, LLC
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in all
//  copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
//  SOFTWARE.
//

#import <FOSRest/FOSCachedManagedObject.h>

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
