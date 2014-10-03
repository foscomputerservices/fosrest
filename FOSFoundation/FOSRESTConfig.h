//
//  FOSRESTConfig.h
//  FOSFoundation
//
//  Created by David Hunt on 12/25/12.
//  Copyright (c) 2012 FOS Computer Services. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FOSNetworkStatusMonitor.h"
#import "FOSRESTServiceAdapter.h"

/*!
 * @enum FOSRESTConfigOptions
 *
 * @constant FOSRESTConfigOptionsNone Used to turn off all other options (specified by itself)
 *
 * @constant FOSRESTConfigAutomaticallySynchronize Allows the framework to automatically push changes to the server.
 *
 * @constant FOSRESTConfigAllowFaulting Allows faults to be placed in faultable relationships, which are then faulted to their real values when the relationship is traversed.
 *
 * @constant FOSRESTConfigCaseSensitiveUserNames Forces user names to be case sensitive.  By default they are all forced to be lower case before authentication. 
 *
 * @constant FOSRESTConfigDeleteDBOnLogout Deletes the database file once a user's logout process has been completed (a full synchronize of the user is done before logout completes).
 *
 * @discussion
 *
 * These configuration options turn on optional behaviors of the FOSREST service.
 */
typedef enum : NSUInteger {
    FOSRESTConfigOptionsNone = (0),
    FOSRESTConfigAutomaticallySynchronize = (1 << 0),
    FOSRESTConfigAllowFaulting = (1 << 1),
    FOSRESTConfigCaseSensitiveUserNames = (1 << 2),
    FOSRESTConfigAllowStaticTableModifications = (1 << 3),
    FOSRESTConfigUseOfflineFiles = (1 << 4),
    FOSRESTConfigDeleteDBOnLogout = (1 << 5),
} FOSRESTConfigOptions;

@class FOSLoginManager;

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
 * @remarks
 *
 * This property is KVO compliant.
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
 * @discussion
 *
 * The following endpoints are automatically considered to be
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
 * @discussion
 *
 * This method can only be called one time at initialization of the application.
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
 * @discussion
 *
 * This method is safe to use from multiple threads.
 */
+ (instancetype)sharedInstance;

@end
