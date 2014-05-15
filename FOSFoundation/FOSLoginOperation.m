//
//  FOSLoginOperation.m
//  FOSFoundation
//
//  Created by David Hunt on 1/1/13.
//  Copyright (c) 2013 FOS Computer Services. All rights reserved.
//

#import "FOSLoginOperation.h"
#import "FOSRetrieveCMOOperation.h"
#import "FOSCacheManager_Internal.h"
#import "FOSLoginManager_Internal.h"

@implementation FOSLoginOperation {
    FOSRetrieveCMOOperation *__fetchUserRequest;

    __block FOSUser *_loggedInUser;
    __block NSError *_error;
}

#pragma mark - Class methods
+ (instancetype)loginOperationForUser:(FOSUser *)user {
    NSParameterAssert(user != nil);
    NSParameterAssert(user.isLoginUser);

    return [[self alloc] initForUser:user];
}

- (id)initForUser:(FOSUser *)user {
    NSParameterAssert(user != nil);
    NSParameterAssert(user.isLoginUser);

    if ((self = [super init]) != nil) {
        _user = user;

        [self addDependency:self._resolveUserRequest];
    }

    return self;
}

#pragma mark - Overrides

- (NSError *)error {
    NSError *result = _error;
    if (result == nil) {
        result = [super error];
    }

    return result;
}

- (void)main {
    [super main];

    if (!self.isCancelled && self.error == nil) {
        // Don't try to send this to the server
        self.user.jsonIdValue = _loggedInUser.jsonIdValue;
        [self.user markClean];

        NSLog(@"Logged in: %@", _loggedInUid);
    }
    else {
        if (self.isCancelled) {
            NSLog(@"Login cancelled.");
        }
        else {
            NSLog(@"Error during login: %@", self.error.description);
        }
    }
}

- (NSString *)debugDescription {
    NSString *result = [NSString stringWithFormat:@"%@ - %@",
                        [super debugDescription],
                        _user.uid];

    return result;
}

#pragma mark - Private methods

- (FOSBackgroundOperation *)_resolveUserRequest {
    FOSBackgroundOperation *result = nil;

    id<FOSRESTServiceAdapter> adapter = self.restConfig.restServiceAdapter;
    FOSURLBinding *urlBinding = [adapter urlBindingForLifecyclePhase:FOSLifecyclePhaseLogin
                                                     forRelationship:nil
                                                           forEntity:_user.entity];

    NSDictionary *context = @{ @"USER_NAME" : _user.username, @"PASSWORD" : _user.password };

    NSError *localError = nil;
    NSURLRequest *urlRequest = [urlBinding urlRequestForServerCommandWithContext:context
                                                                           error:&localError];
    if (localError == nil) {

        FOSRetrieveCMODataOperation *fetchDataOp =
            [FOSRetrieveCMODataOperation retrieveDataOperationForEntity:_user.entity
                                                            withRequest:urlRequest
                                                          andURLBinding:urlBinding];

        FOSBackgroundOperation *cmLoginOp = [FOSBackgroundOperation backgroundOperationWithRequest:^(BOOL isCancelled, NSError *error) {

            if (error == nil) {
                // We need to run ops to load in the user's dependent data.
                [self.restConfig.loginManager setUserIsLoggingIn];
            }
        }];

        FOSRetrieveCMOOperation *loginRequest =
            [FOSRetrieveCMOOperation retrieveCMOUsingDataOperation:fetchDataOp];
        [loginRequest addDependency:cmLoginOp];

        __block FOSLoginOperation *blockSelf = self;

       result = [FOSBackgroundOperation backgroundOperationWithRequest:^(BOOL isCancelled, NSError *error) {
            if (!isCancelled && loginRequest.error == nil) {

                // Make it real
                NSManagedObjectContext *moc = blockSelf.managedObjectContext;
                FOSUser *loggedInUser = (FOSUser *)loginRequest.managedObject;

                NSAssert(!loggedInUser.isLoginUser, @"We should have a *real* user instance now, not a loginUser!");

                NSError *error = nil;
                if ([moc obtainPermanentIDsForObjects:@[ loggedInUser ] error:&error]) {

                    blockSelf->_loggedInUid = loginRequest.jsonId;
                    blockSelf->_loggedInUser = loggedInUser;
                    blockSelf->_loggedInMOID = loggedInUser.objectID;

                    NSAssert(blockSelf->_loggedInUid != nil, @"Why is the loggedInUid nil?");
                    NSAssert([(NSString *)blockSelf->_loggedInUser.uid isEqualToString:(NSString *)blockSelf->_loggedInUid],
                             @"Why aren't the uids equal???");

                    // This is not 'dirty' as we pulled it from the web service
                    [blockSelf->_loggedInUser markClean];
                }
                else {
                    blockSelf->_error = error;
                }
            }
            else {
                blockSelf.restConfig.loginManager.loggedInUserId = nil;
            }
        } callRequestIfCancelled:YES];

        [result addDependency:loginRequest];
    }

    if (localError != nil) {
        _error = localError;
        result = nil;
    }

    return result;
}

@end