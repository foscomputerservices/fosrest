//
//  FOSLoginOperation.m
//  FOSRest
//
//  Created by David Hunt on 1/1/13.
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

#import <FOSLoginOperation.h>
#import "FOSREST_Internal.h"

@implementation FOSLoginOperation {
    FOSRetrieveCMOOperation *__fetchUserRequest;
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
    NSAssert([NSThread isMainThread], @"Can only create a login operation from the main thread.");

    if ((self = [super init]) != nil) {
        _loginStyle = loginStyle;
        FOSRESTConfig *restConfig = self.restConfig;
        NSEntityDescription *restUserEntity = [restConfig.userSubType entityDescription];

        if ([user.entity.name isEqual:restUserEntity.name]) {
            _user = user;

            FOSOperation *resolveUserReq = self._resolveUserRequest;
            if (_error == nil) {
                [self addDependency:resolveUserReq];
            }
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
        __block FOSLoginOperation *blockSelf = self;

        // Only update from the main queue
        [[FOSLoginManager loginUserContext] performBlockAndWait:^{
            // Don't try to send this to the server
            blockSelf.user.jsonIdValue = blockSelf.loggedInUid;
            [blockSelf.user markClean];
        }];

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

        localError = [NSError errorWithDomain:@"FOSREST" andMessage:msg];
    }

    NSURLRequest *urlRequest = nil;

    if (localError == nil) {
        NSDictionary *context = @{ @"CMO" : _user,
                                   @"USER_NAME" : _user.jsonUsername ? _user.jsonUsername : @"",
                                   @"PASSWORD" : _user.password ? _user.password : @""
                                };

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
                [moc performBlockAndWait:^{
                    NSManagedObjectID *loginUserID = loginRequest.managedObjectID;
                    FOSUser *loggedInUser = (FOSUser *)[moc objectWithID:loginUserID];

                    NSAssert(!loggedInUser.isLoginUser,
                             @"We should have a *real* user instance now, not a loginUser!");

                    NSError *error = nil;
                    if ([moc obtainPermanentIDsForObjects:@[ loggedInUser ] error:&error]) {

                        blockSelf->_loggedInUid = loginRequest.jsonId;
                        blockSelf->_loggedInMOID = loggedInUser.objectID;

                        NSAssert(blockSelf->_loggedInUid != nil, @"Why is the loggedInUid nil?");

                        // This is not 'dirty' as we pulled it from the web service
                        [loggedInUser markClean];
                    }
                    else {
                        blockSelf->_error = error;
                    }
                }];
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
