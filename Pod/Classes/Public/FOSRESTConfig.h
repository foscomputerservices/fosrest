//
//  FOSRestConfig.h
//  FOSRest
//
//  Created by David Hunt on 12/25/12.
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

@import Foundation;
#import "FOSAnalytics.h"
#import "FOSNetworkStatus.h"
#import "FOSRESTConfigOptions.h"

@protocol FOSRESTServiceAdapter;

@class FOSLoginManager;
@class FOSDatabaseManager;
@class FOSCacheManager;

@protocol FOSRESTServiceAdapter;

@interface FOSRESTConfig : NSObject<
    FOSAnalytics
>

/*!
 * @methodgroup Required Configuration Properties
 */
#pragma mark - Required Configuration Properties

@property (nonatomic, readonly) id<FOSRESTServiceAdapter> restServiceAdapter;

/*!
 * @property headerFields
 *
 * A set of (NSString *)key/ (NSString *)value pairs that are added to all web service
 * request headers.
 */
@property (nonatomic, readonly) NSDictionary *headerFields;

/*!
 * @property userSubType
 *
 * The type of the application's custom subType of FOSUser.
 */
@property (nonatomic, readonly) Class userSubType;

/*!
 * @property defaultTimeout
 *
 * Setting this property overrides the default value of 20 seconds.
 *
 */
@property (nonatomic, readonly) NSTimeInterval defaultTimeout;

/*!
 * @property isFaultingEnabled
 *
 * Returns YES if FOSRESTConfigAllowFaulting was specified as an option
 * during configuration.
 */
@property (nonatomic, readonly) BOOL isFaultingEnabled;

/*!
 * @property isAutomaticallySynchronizing
 *
 * Returns YES if FOSRESTConfigAutomaticallySynchronize was specified as an option
 * during configuration.
 */
@property (nonatomic, readonly) BOOL isAutomaticallySynchronizing;

/*!
 * @property isSavingOfflineChanges
 *
 * Returns YES if FOSRESTConfigSaveOfflineChanges was specified as an option
 * during configuration.
 */
@property (nonatomic, readonly) BOOL isSavingOfflineChanges;

/*!
 * @property userNamesAreCaseSensitive
 *
 * Returns YES if FOSRESTConfigCaseSensitiveUserNames was specified as an option
 * during configuration.
 */
@property (nonatomic, readonly) BOOL userNamesAreCaseSensitive;

/*!
 * @property allowStaticTableModifications
 *
 * Returns YES if FOSRESTConfigAllowStaticTableModifications was specified as an option
 * during configuration.
 */
@property (nonatomic, readonly) BOOL allowStaticTableModifications;

/*!
 * @property deleteDatabaseOnLogout
 *
 * Returns YRES if FOSRESTConfigDeleteDBOnLogout was specified as an option
 * during configuration.
 */
@property (nonatomic, readonly) BOOL deleteDatabaseOnLogout;

/*!
 * @property networkStatus
 *
 * Returns the current networkStatus as provided by the FOSNetworkStatusMonitor.
 *
 * @remarks This property is KVO compliant.
 */
@property (nonatomic, readonly) FOSNetworkStatus networkStatus;

/*!
 * @methodgroup  Optional Configuration Properties
 */
#pragma mark - Optional Configuration Properties

/*!
 * @property customCacheLineManagers
 *
 * A dictionary of keys of type NSString, which corresponds to an
 * Objective-C class that is a subtype of FOSCachedManagedObject and
 * values of type NSString which correspond to classes that implement
 * the FOSCacheLineManager protocol.
 *
 * Providing this map allows for the substitution of a custom
 * cache line manager for a given managed object class.
 */
@property (nonatomic, strong) NSDictionary *customCacheLineManagers;

/*!
 * @property validOfflineEndpoints
 *
 * A set of URI fragments that can be matched against processing
 * endpoints that can be called even when there's no logged in
 * user.
 *
 * @discussion The following endpoints are automatically considered to be
 * valid offline endpoints:
 * 
 *   * [userSubType entityDescription].jsonPOSTEndPoint
 *   * loginEndPoint
 */
@property (nonatomic, strong) NSSet *validOfflineEndPoints;

/*!
 * @methodgroup Cache Manager Access
 */
#pragma mark - Cache Manager Access

@property (nonatomic, readonly) FOSDatabaseManager *databaseManager;
@property (nonatomic, readonly) FOSCacheManager *cacheManager;
@property (nonatomic, readonly) FOSLoginManager *loginManager;

/*!
 * @methodgroup Class Methods
 */
#pragma mark - Class Methods

/*!
 * @method configWithApplicationVersion:options:userSubType:defaultTimeout:
 *
 * This must be the first method called.  The arguments to the method are
 * all of the required paramters to ensure proper startup of the REST services.
 *
 * @throws FOSCannotReconfigure
 *
 * @throws FOSBadUserSubType
 *
 * @discussion This method can only be called one time at initialization of the application.
 */
+ (void)configWithApplicationVersion:(NSString *)appVersion
                             options:(FOSRESTConfigOptions)options
                         userSubType:(Class)userSubType
                  restServiceAdapter:(id<FOSRESTServiceAdapter>)restServiceAdapter;

/*!
 * @method sharedInstance
 *
 * Returns a singleton shared instance of the receiver's type.
 *
 * @throws FOSNotInitialized
 *
 * @discussion This method is safe to use from multiple threads.
 */
+ (instancetype)sharedInstance;

@end
