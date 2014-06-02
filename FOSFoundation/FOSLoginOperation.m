//
//  FOSLoginOperation.m
//  FOSFoundation
//
//  Created by David Hunt on 1/1/13.
//  Copyright (c) 2013 FOS Computer Services. All rights reserved.
//

#import "FOSLoginOperation.h"
#import "FOSRetrieveCMOOperation.h"
#import "FOSCacheManager.h"
#import "FOSLoginManager_Internal.h"
#import "FOSRetrieveLoginDataOperation.h"

@implementation FOSLoginOperation {
    FOSRetrieveCMOOperation *__fetchUserRequest;

    __block FOSUser *_loggedInUser;
    __block NSError *_error;
}

#pragma mark - Class methods
+ (instancetype)loginOperationForUser:(FOSUser *)user withLoginStyle:(NSString *)loginStyle {
    NSParameterAssert(user != nil);
    NSParameterAssert(user.isLoginUser);

    return [[self alloc] initForUser:user withLoginStyle:loginStyle];
}

- (id)initForUser:(FOSUser *)user withLoginStyle:(NSString *)loginStyle {
    NSParameterAssert(user != nil);
    NSParameterAssert(user.isLoginUser);

    if ((self = [super init]) != nil) {
        _loginStyle = loginStyle;
        FOSRESTConfig *restConfig = self.restConfig;
        NSEntityDescription *restUserEntity = [restConfig.userSubType entityDescription];

        if ([user.entity.name isEqual:restUserEntity.name]) {
            _user = user;

            [self addDependency:self._resolveUserRequest];
        }
        else {
            NSString *msgFmt = @"FOSLoginOperation was initialized with a user of type %@, but the FOSRESTConfig specified %@ as the user type.";
            NSString *msg = [NSString stringWithFormat:msgFmt,
                             user.entity.name, restUserEntity.name];

            _error = [NSError errorWithMessage:msg];
        }
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

        FOSLogInfo(@"Logged in: %@", _loggedInUid);
    }
    else {
        if (self.isCancelled) {
            FOSLogInfo(@"Login cancelled.");
        }
        else {
            FOSLogError(@"Error during login: %@", self.error.description);
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
    NSError *localError = nil;

    id<FOSRESTServiceAdapter> adapter = self.restConfig.restServiceAdapter;
    FOSURLBinding *urlBinding = [adapter urlBindingForLifecyclePhase:FOSLifecyclePhaseLogin
                                                      forLifecycleStyle:self.loginStyle
                                                     forRelationship:nil
                                                           forEntity:_user.entity];

    if (urlBinding == nil) {
        NSString *msgFmt = @"Missing URL_BINDING for lifecycle %@, lifecycle style %@ for Entity '%@'.";
        NSString *msg = [NSString stringWithFormat:msgFmt,
                         [FOSURLBinding stringForLifecycle:FOSLifecyclePhaseLogin],
                         self.loginStyle ? self.loginStyle : @"<none>",
                         _user.entity.name];

        localError = [NSError errorWithDomain:@"FOSFoundation" andMessage:msg];
    }

    NSURLRequest *urlRequest = nil;

    if (localError == nil) {
        NSDictionary *context = @{ @"USER_NAME" : _user.jsonUsername, @"PASSWORD" : _user.password };

        urlRequest = [urlBinding urlRequestForServerCommandWithContext:context
                                                                 error:&localError];
    }

    if (localError == nil) {
        __block FOSLoginOperation *blockSelf = self;

        FOSRetrieveLoginDataOperation *fetchDataOp =
            [FOSRetrieveLoginDataOperation retrieveDataOperationForEntity:_user.entity
                                                            withRequest:urlRequest
                                                          andURLBinding:urlBinding];
        fetchDataOp.loginUser = _user;

        FOSRetrieveCMOOperation *loginRequest =
            [FOSRetrieveCMOOperation retrieveCMOUsingDataOperation:fetchDataOp
                                                 forLifecyclePhase:FOSLifecyclePhaseLogin
                                                 forLifecycleStyle:self.loginStyle];

        result = [FOSBackgroundOperation backgroundOperationWithRequest:^(BOOL isCancelled, NSError *error) {
            if (!isCancelled && loginRequest.error == nil) {

                // Make it real
                NSManagedObjectContext *moc = blockSelf.managedObjectContext;
                FOSUser *loggedInUser = (FOSUser *)loginRequest.managedObject;

                NSAssert(!loggedInUser.isLoginUser,
                         @"We should have a *real* user instance now, not a loginUser!");

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
