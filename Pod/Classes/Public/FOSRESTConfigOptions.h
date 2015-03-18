//
//  FOSRESTConfigOptions.h
//  Pods
//
//  Created by David Hunt on 3/18/15.
//
//

#ifndef FOSRESTConfigOptions_h
#define FOSRESTConfigOptions_h

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
typedef NS_OPTIONS(NSUInteger, FOSRESTConfigOptions) {
    FOSRESTConfigOptionsNone = (0),
    FOSRESTConfigAutomaticallySynchronize = (1 << 0),
    FOSRESTConfigAllowFaulting = (1 << 1),
    FOSRESTConfigCaseSensitiveUserNames = (1 << 2),
    FOSRESTConfigAllowStaticTableModifications = (1 << 3),
    FOSRESTConfigUseOfflineFiles = (1 << 4),
    FOSRESTConfigDeleteDBOnLogout = (1 << 5),
};

#endif
