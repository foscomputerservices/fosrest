//
//  FOSLoginManager.m
//  FOSFoundation
//
//  Created by David Hunt on 12/22/12.
//  Copyright (c) 2012 FOS Computer Services. All rights reserved.
//

#import "FOSLoginManager.h"
#import "FOSCacheManager.h"
#import "FOSRESTConfig.h"
#import "FOSCacheManager.h"
#import "FOSUser.h"
#import "FOSCachedManagedObject.h"
#import "FOSLoginOperation.h"
#import "FOSLogoutOperation.h"
#import "FOSRefreshUserOperation.h"
#import "FOSRetrieveCMOOperation.h"
#import "FOSBackgroundOperation.h"
#import "FOSPullStaticTablesOperation.h"
#import "FOSLoginManager_Internal.h"

// Note: This key changed, which will for re-login for the sake of
//       upgrading to NSManagedObjectID vs. NSString, which caused
//       failures between contexts on certain occasions.
static NSString *kUserUidKey = @"FOS_LoggedInUserMOId";

@implementation FOSLoginManager {
    __weak FOSRESTConfig *_restConfig;
    FOSJsonId _loggedInUserId;
    NSManagedObjectID *__loggedInUserMOID;
    BOOL _userIsLoggingIn;
    FOSUser *_loginUser;
    FOSLoginOperation *_loginOp;
}

#pragma mark - Class Methods

+ (NSManagedObjectContext *)loginUserContext {
    static NSManagedObjectContext *_loginUserContext;

    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _loginUserContext =
            [[NSManagedObjectContext alloc] initWithConcurrencyType:NSConfinementConcurrencyType];
        _loginUserContext.persistentStoreCoordinator = [FOSRESTConfig sharedInstance].storeCoordinator;
    });

    return _loginUserContext;
}

#pragma mark - Property Overrides

- (BOOL)isLoggedIn {
    return _userIsLoggingIn || ([self _loggedInUserId] != nil);
}

- (FOSJsonId)loggedInUserId {

    if (_loggedInUserId == nil) {
        _loggedInUserId = self.loggedInUser.uid;
    }
    
    return _loggedInUserId;
}

// This method should only be called in a *very* few instances:
//    1) Testing reset
//
// If it is called elsewhere, then Key-Value Observing changes will
// not be fired.
+ (void)clearLoggedInUserId {
    [self _setLoggedInUserId:nil];
}

- (void)setLoggedInUserId:(NSManagedObjectID *)loggedInUserId {
    NSParameterAssert(loggedInUserId == nil || ![loggedInUserId isTemporaryID]);

    @synchronized(self) {
        if ([self _loggedInUserId] != loggedInUserId) {
            [self willChangeValueForKey:@"loggedInUserId"];
            [self willChangeValueForKey:@"isLoggedIn"];
            [self willChangeValueForKey:@"loggedInUser"];

            [[self class] _setLoggedInUserId:loggedInUserId];
            __loggedInUserMOID = nil;
            _loggedInUserId = nil;

            [self didChangeValueForKey:@"loggedInUserId"];
            [self didChangeValueForKey:@"isLoggedIn"];
            [self didChangeValueForKey:@"loggedInUser"];
        }

        _userIsLoggingIn = NO;
    }
}

- (FOSUser *)loggedInUser {
    @synchronized(self) {
        FOSUser *result = nil;

        if (_userIsLoggingIn) {
            result = _loginUser;
        }
        else {
            // NOTE: We do *not* hold on to the logged in FOSUser as this causes sync
            //       problems between threads.
            NSManagedObjectID *loggedInUserId = [self _loggedInUserId];

            if (loggedInUserId != nil) {
                NSManagedObjectContext *moc = _restConfig.databaseManager.currentMOC;

                NSError *error = nil;
                if ([moc existingObjectWithID:loggedInUserId error:&error]) {
                    FOSUser *user = (FOSUser *)[moc objectWithID:loggedInUserId];

                    if (user == nil) {
                        self.loggedInUserId = nil;
                    }

                    // This can happen when the DB is upgraded.  The MOID is stored
                    // as a URI string, but no longer matches the logged in (upgraded)
                    // user MOID and we seem to get a phantom user record.
                    // So we'll just log out the user.
                    else if (user.uid == nil) {
                        self.loggedInUserId = nil;
                        user = nil;
                    }

                    if (user == nil) {
                        FOSLogError(@" ******  Cannot find a the logged in user???   *****");
                    }

                    result = user;
                }
                else {
                    FOSLogError(@" ******  Cannot find a the logged in user???   *****");
                }
            }

            NSAssert(!result.isLoginUser, @"We should *not* have a 'login-style' user here!");
            NSAssert(!(result == nil && self.isLoggedIn), @"Logged in, but no user???");
        }

        return result;
    }
}

#pragma mark - Public Methods

- (id)initWithCacheConfig:(FOSRESTConfig *)restConfig {
    NSParameterAssert(restConfig != nil);
    NSParameterAssert(restConfig.userSubType != nil);
    NSParameterAssert([restConfig.userSubType isSubclassOfClass:[FOSUser class]]);

    if ((self = [super init]) != nil) {
        _restConfig = restConfig;

        // Check that the 'isLoggedIn' status & the db are in sync
        if ([self _loggedInUserId] != nil) {
            NSManagedObjectContext *moc = restConfig.databaseManager.currentMOC;

            NSError *error = nil;
            if ([moc existingObjectWithID:[self _loggedInUserId] error:&error] == nil) {

                // No need for KVO here and the local member variables are not yet set
                // by definition.
                [[self class] clearLoggedInUserId];
            }
        }
    }

    return self;
}

- (void)createUser:(FOSUser *)user createStyle:(NSString *)createStyle handler:(FOSLoginHandler)handler {
    NSAssert([NSThread isMainThread], @"Creating users should only be done from the main thread.");

    NSParameterAssert(user != nil);
    NSParameterAssert(user.isLoginUser);

    if (!user.isUploadable) {

        [NSException raise:@"FOSNonUploadableUser"
                    format:NSLocalizedString(@"The provided user is a non-uploadable user (user.isUploadable == NO).", @"FOSNonUploadableUser")];
    }

    __block FOSLoginManager *blockSelf = self;

    if (_restConfig.networkStatus != FOSNetworkStatusNotReachable) {
        FOSOperation *pushOp = [user sendServerRecordWithLifecycleStyle:createStyle];

        FOSBackgroundOperation *clearContextOp = [FOSBackgroundOperation backgroundOperationWithRequest:^(BOOL cancelled, NSError *error) {

            // Delete this temp user before saving changes
            [blockSelf _clearLoginUserContext];

            [[FOSRESTConfig sharedInstance].databaseManager.currentMOC rollback];
        } callRequestIfCancelled:YES];

        [clearContextOp addDependency:pushOp];

        FOSBackgroundOperation *finalOp = [FOSBackgroundOperation backgroundOperationWithMainThreadRequest:^(BOOL cancelled, NSError *error) {
            BOOL success = !cancelled && error == nil;

            if (handler != nil) {
                NSError *localError = error;

                if (cancelled && error == nil) {
                    NSString *msg = NSLocalizedString(@"Unable to create user account as the operation was cancelled.  Please check your network connection.", @"");

                    localError = [NSError errorWithMessage:msg];
                }

                handler(success, localError);
            }
        }];

        [_restConfig.cacheManager queueOperation:clearContextOp
                         withCompletionOperation:finalOp
                                   withGroupName:@"Create User"];
    }
    else {
        dispatch_async(dispatch_get_main_queue(), ^{
            // Remove the user in the login context
            [blockSelf _clearLoginUserContext];

            if (handler != nil) {
                NSString *msg = NSLocalizedString(@"Unable to create user accounts unless connected to the Internet.  Please check your network connection.", @"");

                NSError *error = [NSError errorWithMessage:msg];
                
                handler(NO, error);
            }
        });
    }
}

- (void)loginUser:(FOSUser *)user loginStyle:(NSString *)loginStyle handler:(FOSLoginHandler)handler {
    NSAssert([NSThread isMainThread], @"Login should only be done from the main thread.");

    NSParameterAssert(user != nil);
    NSParameterAssert(user.isLoginUser || user.isLocalOnly);

    if (self.isLoggedIn) {
        [NSException raise:@"FOSLoggedIn"
                    format:NSLocalizedString(@"An account is already logged in.", @"FOSLoggedIn")];
    }

    __block FOSLoginManager *blockSelf = self;
    
    // We'll support 'local' users too, but don't go to the web service for them!
    if (!user.isLocalOnly && _restConfig.networkStatus != FOSNetworkStatusNotReachable) {
        [self _storeTempLoginUser:user];

        // Ensure that the static tables have all been pulled before attempting to create
        // any further objects
        FOSPullStaticTablesOperation *pullStaticTablesOp =
            [[FOSPullStaticTablesOperation alloc] initResettingProcessedTables:YES];

        FOSBackgroundOperation *handlerOp = [FOSBackgroundOperation backgroundOperationWithMainThreadRequest:^(BOOL isCancelled, NSError *error) {

            if (!isCancelled && error == nil) {

                FOSLoginOperation *loginOp = [FOSLoginOperation loginOperationForUser:user
                                                                       withLoginStyle:loginStyle];
                [loginOp addDependency:pullStaticTablesOp];

                blockSelf->_loginOp = loginOp;

                FOSBackgroundOperation *finalOp = [FOSBackgroundOperation backgroundOperationWithMainThreadRequest:^(BOOL cancelled, NSError *error) {

                    // Remove the user in the login context
                    [blockSelf _clearLoginUserContext];

                    // Save the object id now that the FOSUser object has been saved
                    blockSelf.loggedInUserId = loginOp.loggedInMOID;
                    blockSelf->_loginOp = nil;

                    NSAssert((error == nil && blockSelf.loggedInUser != nil) ||
                             ((error != nil || isCancelled) &&
                              blockSelf.loggedInUser == nil),
                             @"Cannot find the logged in user on the main thread???");

                    if (handler != nil) {
                        NSError *localError = error;
                        if (isCancelled && localError == nil) {
                            NSString *msg = NSLocalizedString(@"Unable to login as the operation was cancelled.  Please check your network connection.", @"");

                            localError = [NSError errorWithMessage:msg];
                        }

                        handler(localError == nil && !isCancelled, localError);
                    }
                }];

                [blockSelf->_restConfig.cacheManager queueOperation:loginOp
                                            withCompletionOperation:finalOp
                                                      withGroupName:@"Login user"];
            }
            else {
                // Remove the user in the login context
                [blockSelf _clearLoginUserContext];

                if (handler != nil) {
                    NSError *localError = error;
                    if (isCancelled && localError == nil) {
                        NSString *msg = NSLocalizedString(@"Unable to login as the operation was cancelled.  Please check your network connection.", @"");

                        localError = [NSError errorWithMessage:msg];
                    }
                    
                    handler(NO, localError);
                }
            }
        }];

        [_restConfig.cacheManager queueOperation:pullStaticTablesOp
                         withCompletionOperation:handlerOp
                                   withGroupName:@"Refresh Static Tables"];
    }
    else if (user.isLocalOnly) {
        if (user.uid == nil) {
            [NSException raise:@"FOSMissing_LocalUserId"
                        format:@"The provided local user (user.isLocalOnly == YES) must have the identity property set."];
        }

        self.loggedInUserId = user.objectID;

        // Remove the user in the login context
        [self _clearLoginUserContext];

        if (handler != nil) {
            handler(YES, nil);
        }
    }
    else {
        // Remove the user in the login context
        [self _clearLoginUserContext];

        if (handler != nil) {

            NSString *msg = NSLocalizedString(@"Unable to login unless connected to the Internet.  Please check your network connection.", @"");

            NSError *error = [NSError errorWithMessage:msg];

            handler(NO, error);
        }
    }
}

- (void)refreshLoggedInUser:(FOSLoginHandler)handler {
    NSAssert([NSThread isMainThread], @"User refresh should only be done from the main thread.");

    if (self.isLoggedIn) {
        FOSUser *loggedInUser = self.loggedInUser;

        if (_restConfig.networkStatus != FOSNetworkStatusNotReachable) {

            if (!loggedInUser.isLocalOnly) {
                // Ensure that the static tables have all been pulled before attempting to create
                // any further objects
                FOSPullStaticTablesOperation *pullStaticTablesOp =
                    [[FOSPullStaticTablesOperation alloc] initResettingProcessedTables:NO];

                FOSRefreshUserOperation *refreshOp = [FOSRefreshUserOperation refreshUserOperation];
                [refreshOp addDependency:pullStaticTablesOp];

                FOSBackgroundOperation *handlerOp = [FOSBackgroundOperation backgroundOperationWithRequest:^(BOOL isCancelled, NSError *error) {
                    if (handler != nil) {
                        dispatch_async(dispatch_get_main_queue(), ^{
                            handler(refreshOp.error == nil, refreshOp.error);
                        });
                    }
                } callRequestIfCancelled:YES];

                [_restConfig.cacheManager queueOperation:refreshOp
                                 withCompletionOperation:handlerOp
                                           withGroupName:@"Refresh user"];
            }
            else if (handler != nil) {
                handler(YES, nil);
            }
        }
        else if (handler != nil) {
            dispatch_async(dispatch_get_main_queue(), ^{
                NSString *msg = NSLocalizedString(@"Unable to refresh user unless connected to the Internet.  Please check your network connection.", @"");

                NSError *error = [NSError errorWithMessage:msg];

                handler(NO, error);
            });
        }
    }
    else {
        dispatch_async(dispatch_get_main_queue(), ^{
            handler(NO, nil);
        });
    }
}

- (void)logout:(FOSLoginHandler)handler {
    NSAssert([NSThread isMainThread], @"Logout should only be done from the main thread.");

    if (!self.isLoggedIn) {
        [NSException raise:@"FOSNotLoggedIn"
                    format:NSLocalizedString(@"Cannot log out when no one is logged in.", @"")];
    }

    if (_isLoggingOut) {
        [NSException raise:@"FOSAlreadyLoggingOut"
                    format:NSLocalizedString(@"Logout process is already in progress.", @"")];
    }

    if (_restConfig.networkStatus != FOSNetworkStatusNotReachable) {
        [self _setIsLoggingOut:YES];

        __block FOSLoginManager *blockSelf = self;

        FOSLogoutOperation *logoutOp = [FOSLogoutOperation logoutOperation];
        FOSBackgroundOperation *handlerOp = [FOSBackgroundOperation backgroundOperationWithRequest:^(BOOL isCancelled, NSError *error) {

            [blockSelf _setIsLoggingOut:NO];

            if (handler != nil) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    handler(logoutOp.error == nil, logoutOp.error);
                });
            }
        } callRequestIfCancelled:YES];

        [_restConfig.cacheManager queueOperation:logoutOp
                         withCompletionOperation:handlerOp
                                   withGroupName:@"Log out user"];
    }
    else if (handler != nil) {
        NSString *msg = NSLocalizedString(@"Unable to logout user unless connected to the Internet.  Please check your network connection.", @"");

        NSError *error = [NSError errorWithMessage:msg];

        handler(NO, error);
    }
}

- (void)resetPasswordForResetKey:(NSString *)resetKey
                        andValue:(NSString *)resetValue
                         handler:(FOSLoginHandler)handler {
    NSParameterAssert(resetKey.length > 0);
    NSParameterAssert(resetValue.length > 0);

    if (_restConfig.networkStatus != FOSNetworkStatusNotReachable) {
        NSEntityDescription *userEntity = [_restConfig.userSubType entityDescription];

        id<FOSRESTServiceAdapter> adapter = _restConfig.restServiceAdapter;
        FOSURLBinding *urlBinding = [adapter urlBindingForLifecyclePhase:FOSLifecyclePhasePasswordReset
                                                          forLifecycleStyle:nil
                                                         forRelationship:nil
                                                               forEntity:userEntity];

        NSDictionary *context = @{ resetKey : resetValue };
        NSError *localError = nil;
        NSURLRequest *urlRequest = [urlBinding urlRequestForServerCommandWithContext:context
                                                                               error:&localError];

        if (localError == nil) {
            FOSWebServiceRequest *request = [FOSWebServiceRequest requestWithURLRequest:urlRequest
                                                                          forURLBinding:urlBinding];

            FOSBackgroundOperation *handlerOp = [FOSBackgroundOperation backgroundOperationWithRequest:^(BOOL isCancelled, NSError *error) {
                if (handler != nil) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        handler(error == nil, error);
                    });
                }
            } callRequestIfCancelled:YES];

            [_restConfig.cacheManager queueOperation:request
                             withCompletionOperation:handlerOp
                                       withGroupName:@"Password reset"];
        }
        else if (handler != nil) {
            dispatch_async(dispatch_get_main_queue(), ^{
                handler(NO, localError);
            });
        }
    }
    else if (handler != nil) {
        dispatch_async(dispatch_get_main_queue(), ^{
            NSString *msg = NSLocalizedString(@"Unable to logout user unless connected to the Internet.  Please check your network connection.", @"");

            NSError *error = [NSError errorWithMessage:msg];

            handler(NO, error);
        });
    }
}

#pragma mark - Private Methods

- (void)_clearLoginUserContext {
    _loginUser = nil;

    NSManagedObjectContext *moc = [[self class] loginUserContext];

    [moc rollback];
    [moc reset];
}

- (void)_storeTempLoginUser:(FOSUser *)tempUser {
    NSParameterAssert(tempUser.isLoginUser);

    _userIsLoggingIn = YES;
    _loginUser = tempUser;
}

- (NSManagedObjectID *)_loggedInUserId {
    if (__loggedInUserMOID == nil) {
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];

        NSString *uriStr = [defaults objectForKey:kUserUidKey];
        if (uriStr.length > 0) {
            NSURL *uri = [NSURL URLWithString:uriStr];

            NSPersistentStoreCoordinator *coord = _restConfig.storeCoordinator;
            __loggedInUserMOID = [coord managedObjectIDForURIRepresentation:uri];

            BOOL isIdInvalid = NO;
            if (__loggedInUserMOID == nil) {
                isIdInvalid = YES;
            }

            else {
                NSManagedObjectContext *moc = _restConfig.databaseManager.currentMOC;

                if ([moc existingObjectWithID:__loggedInUserMOID error:nil]) {
                    FOSUser *user = (FOSUser *)[moc objectWithID:__loggedInUserMOID];

                    NSAssert(!user.isLoginUser, @"We should *never* have a loginUser here!");

                    if (user == nil) {
                        isIdInvalid = YES;
                    }
                }
                else {
                    isIdInvalid = YES;
                }
            }

            if (isIdInvalid) {
                [[self class ]_setLoggedInUserId:nil];
                __loggedInUserMOID = nil;
                _loggedInUserId = nil;
            }
        }
    }

    _loggedInUserId = nil;

    return __loggedInUserMOID;
}

+ (void)_setLoggedInUserId:(NSManagedObjectID *)loggedInUserId {
    NSParameterAssert(loggedInUserId == nil || ![loggedInUserId isTemporaryID]);

    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];

    if (loggedInUserId != nil) {
        NSURL *uri = loggedInUserId.URIRepresentation;
        NSString *uriStr = uri.absoluteString;

        [defaults setObject:uriStr forKey:kUserUidKey];

        // Make sure that we're *never* given a loginUser
#ifndef NS_BLOCK_ASSERTIONS
        NSManagedObjectContext *curMoc = [FOSRESTConfig sharedInstance].databaseManager.currentMOC;
        FOSUser *usrInst = (FOSUser *)[curMoc objectWithID:loggedInUserId];

        NSParameterAssert(!usrInst.isLoginUser);
#endif
    }
    else {
        [defaults removeObjectForKey:kUserUidKey];
    }
    
    [defaults synchronize];
}

- (void)_setIsLoggingOut:(BOOL)loggingOutStatus {
    [self willChangeValueForKey:@"isLoggingOut"];

    _isLoggingOut = loggingOutStatus;

    [self didChangeValueForKey:@"isLoggingOut"];
}

@end
