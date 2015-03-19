//
//  FOSLoginManager_Internal.h
//  FOSRest
//
//  Created by David Hunt on 12/22/12.
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

- (void)setLoggedInUserId:(NSManagedObjectID *)loggedInUserId;

@end