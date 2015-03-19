//
//  FOSLogoutOperation.m
//  FOSRest
//
//  Created by David Hunt on 1/2/13.
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

#import <FOSLogoutOperation.h>
#import "FOSREST_Internal.h"

@implementation FOSLogoutOperation

#pragma mark - Class methods

+ (instancetype)logoutOperation {
    return [[self alloc] init];
}

- (id)init {
    if ((self = [super init]) != nil) {
        [self addDependency:self._logoutUserRequest];
    }

    return self;
}

#pragma mark - Overrides

- (void)main {

    [super main];

    FOSLogInfo(@"Logged out");
}

#pragma mark - Private methods

- (FOSBackgroundOperation *)_logoutUserRequest {
    NSEntityDescription *entity = [self.restConfig.userSubType entityDescription];
    FOSWebServiceRequest *logoutRequest = nil;
    NSError *localError = nil;

    // Make sure to flush caches before logging out
    FOSPushCacheChangesOperation *pushChanges = [FOSPushCacheChangesOperation pushCacheChangesOperation];

    // Retrieve the optional server logout URL
    id<FOSRESTServiceAdapter> adapter = self.restAdapter;
    FOSURLBinding *urlBinding = [adapter urlBindingForLifecyclePhase:FOSLifecyclePhaseLogout
                                                   forLifecycleStyle:nil
                                                     forRelationship:nil
                                                           forEntity:entity];

    FOSUser *loggedInUser = self.restConfig.loginManager.loggedInUser;
    FOSJsonId loggedInUserId = loggedInUser.uid;

    if (urlBinding != nil) {
        NSDictionary *context = @{
                                  @"ENTITY" : loggedInUser.entity,
                                  @"CMOID" : loggedInUserId,
                                  @"USER_NAME" : loggedInUser.jsonUsername
                                };

        NSURLRequest *urlRequest = [urlBinding urlRequestForServerCommandWithContext:context
                                                                               error:&localError];

        if (localError == nil) {
            logoutRequest = [FOSWebServiceRequest requestWithURLRequest:urlRequest
                                                          forURLBinding:urlBinding];
        }
    }

    __block FOSLogoutOperation *blockSelf = self;
    FOSBackgroundOperation *result = [FOSBackgroundOperation backgroundOperationWithRequest:^(BOOL isCancelled, NSError *error) {

        if (!isCancelled && error == nil) {
            blockSelf.restConfig.loginManager.loggedInUserId = nil;
            
            FOSLogInfo(@"Logged out user: %@", loggedInUserId);

            if (blockSelf.restConfig.deleteDatabaseOnLogout) {
                [blockSelf.restConfig.databaseManager resetDatabase];
            }
        }
        else if (error != nil) {
            FOSLogError(@"Unable to complete logout due to error: %@", error.description);
        }
        else {
            FOSLogInfo(@"Logout cancelled.");
        }
    } callRequestIfCancelled:YES];

    if (localError == nil) {
        if (logoutRequest != nil) {
            [logoutRequest addDependency:pushChanges];
            [result addDependency:logoutRequest];
        }
        else {
            [result addDependency:pushChanges];
        }
    }
    else {
        _error = localError;
        result = nil;
    }

    return result;
}

@end
