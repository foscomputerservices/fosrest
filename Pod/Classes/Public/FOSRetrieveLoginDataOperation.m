//
//  FOSRetrieveLoginDataOperation.m
//  FOSRest
//
//  Created by David Hunt on 5/28/14.
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

#import "FOSRetrieveLoginDataOperation.h"
#import "FOSWebServiceRequest+FOS_Internal.h"
#import "FOSREST_Internal.h"

@implementation FOSRetrieveLoginDataOperation {
    NSError *_error;
}

#pragma mark - Overrides

- (NSError *)error {
    NSError *result = _error;

    if (result == nil) {
        result = [super error];
    }

    return  result;
}

- (void)setOriginalJsonResult:(id<NSObject>)jsonResult
                postProcessor:(FOSRequestPostProcessor)postProcessor {

    __block FOSRetrieveLoginDataOperation *blockSelf = self;

    NSAssert(self.loginUser != nil, @"loginUser must be set!");

    [super setOriginalJsonResult:jsonResult postProcessor:^(id<NSObject> originalJson, id<NSObject> unwrappedJson) {
        if (postProcessor != nil) {
            postProcessor(originalJson, unwrappedJson);
        }

        // NOTE:
        //
        // We need to capture user authentication information after we've authenticated
        // with the server, but before the FOSRetrieveCMOOperation is run as the latter
        // will potential recurse required deps, which may cause further server requests
        // that need to be authenticated.  So we drop in an op to slide the fetched,
        // but not saved, user instance into the login manager.
        //
        // It's a bit tricky, but we've kinda got a chicken & egg scenario here.
        //
        // A specific example is that the adapter binding might have HEADER_FIELDS
        // specifications that retrieve properties off of the logged in user.  We
        // cannot save the user yet, as not all required deps have been realized.
        // However, in order to realize those deps, we need the user surfaced to the
        // adapter bindings so that subsequent server requests can be made.

        NSError *localError = nil;

        id<FOSRESTServiceAdapter> adapter = blockSelf.restAdapter;
        FOSURLBinding *urlBindig =
            [adapter urlBindingForLifecyclePhase:FOSLifecyclePhaseLogin
                                  forLifecycleStyle:nil
                                 forRelationship:nil
                                       forEntity:blockSelf.loginUser.entity];
        FOSCMOBinding *cmoBinding = urlBindig.cmoBinding;

        [cmoBinding updateCMO:blockSelf.loginUser
                     fromJSON:unwrappedJson
            forLifecyclePhase:FOSLifecyclePhaseLogin
                        error:&localError];

        if (localError != nil) {
            [blockSelf willChangeValueForKey:@"error"];
            blockSelf->_error = localError;
            [blockSelf didChangeValueForKey:@"error"];
        }
    }];
}

@end
