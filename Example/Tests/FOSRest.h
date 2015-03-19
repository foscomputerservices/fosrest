//
//  FOSRest.h
//  FOSRest
//
//  Created by David Hunt on 2/6/15.
//  Copyright (c) 2015 David Hunt. All rights reserved.
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

@import FOSRest;

#pragma mark - Expose Private Testing Interfaces

@interface NSError (FOS_Internal)

+ (NSError *)errorWithMessage:(NSString *)message;
+ (NSError *)errorWithMessage:(NSString *)message forAtom:(id<FOSCompiledAtomInfo>)atom;

@end

@interface FOSRESTConfig ()

+ (BOOL)sharedInstanceInitialized;
+ (void)resetSharedInstance;

@end

@interface FOSLoginManager(Test)

+ (void)dropSharedInstace;
+ (void)clearLoggedInUserId;

- (void)setLoggedInUserId:(NSManagedObjectID *)loggedInUserId;

@end

#ifdef CONFIGURATION_Debug
@interface FOSOperation (Testing)

- (void)setError:(NSError *)error;

@end
#endif

@interface FOSPullStaticTablesOperation ()

#pragma mark - Testing Only!

+ (void)_initStaticTablesList:(BOOL)resetTables managedObjectContext:(NSManagedObjectContext *)moc;

@end

@interface FOSNetworkStatusMonitor ()

/*!
 * @property forceOffline
 *
 * This is an internal property for testing online/offline mode.  By setting
 * this property to YES, it will cause the receiver to report back
 * FOSNetworkStatusNotReachable from the networkStatus property.  It will also
 * trigger the appropriate change in status notifications.
 *
 * @discussion
 *
 * Setting this property will reset forceOnline to NO.
 */
@property (nonatomic, assign, getter=isForcedOffline) BOOL forceOffline;

@end

@interface FOSCachedManagedObject(FOS_Internal)

+ (NSString *)entityName;

/*!
 * @method entityDescription
 *
 * Returns the NSEntityDescription associated with the
 * receiver's class.
 */
+ (NSEntityDescription *)entityDescription;

/*!
 * @method initSkippingReadOnlyCheck
 *
 * An internal initializer that allows skipping the
 * static table check so that static table instances
 * can be created when being pulled from the server.
 */
- (id)initSkippingReadOnlyCheck;

@end
