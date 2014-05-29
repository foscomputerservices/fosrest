//
//  FOSWebServiceRequest+FOS_Internal.m
//  FOSFoundation
//
//  Created by David Hunt on 1/30/13.
//  Copyright (c) 2013 FOS Computer Services. All rights reserved.
//

#import "FOSWebServiceRequest+FOS_Internal.h"

@implementation FOSWebServiceRequest (FOS_Internal)

- (void)setError:(NSError *)error {
    @synchronized(self) {
        [self willChangeValueForKey:@"error"];
        _error = error;
        [self didChangeValueForKey:@"error"];

        [self _setToFinished];
    }
}

- (void)setOriginalJsonResult:(id<NSObject>)originalJsonResult {
    @synchronized(self) {

        NSError *localError = nil;
        id<NSObject> jsonResult = originalJsonResult;

        // Unwrap the result, if specified to do so
        if (self.urlBinding != nil) {
            jsonResult = [self.urlBinding unwrapJSON:originalJsonResult
                                             context:nil
                                               error:&localError];
        }

        if (localError == nil) {
            [self willChangeValueForKey:@"jsonResult"];
            [self willChangeValueForKey:@"originalJsonResult"];

            _jsonResult = jsonResult;
            _originalJsonResult = originalJsonResult;

            [self didChangeValueForKey:@"jsonResult"];
            [self didChangeValueForKey:@"originalJsonResult"];

            [self _setToFinished];
        }
        else {
            self.error = localError;
        }
    }
}

#pragma mark - Private Methods

- (void)_setToFinished {
    // The order of ops here is as detailed in Apple's docs:
    // http://developer.apple.com/library/ios/#documentation/General/Conceptual/ConcurrencyProgrammingGuide/OperationObjects/OperationObjects.html

    [self willChangeValueForKey:@"isFinished"];
    [self willChangeValueForKey:@"isExecuting"];

    _requestState = FOSWSRequestStateFinished;

    [self didChangeValueForKey:@"isExecuting"];
    [self didChangeValueForKey:@"isFinished"];
}

@end
