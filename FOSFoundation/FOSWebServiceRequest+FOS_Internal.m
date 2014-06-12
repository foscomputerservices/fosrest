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
        BOOL isFastTrackID = [originalJsonResult isKindOfClass:[NSManagedObjectID class]];

        // Unwrap the result, if specified to do so && the json
        // isn't a fast-tracked NSManagedObjectId
        if (self.urlBinding != nil && !isFastTrackID) {
            jsonResult = [self.urlBinding unwrapJSON:originalJsonResult
                                             context:nil
                                               error:&localError];
        }

        if (localError == nil) {
            [self willChangeValueForKey:@"jsonResult"];

            _jsonResult = jsonResult;

            if (!isFastTrackID) {
                [self willChangeValueForKey:@"originalJsonResult"];
                _originalJsonResult = originalJsonResult;
                [self didChangeValueForKey:@"originalJsonResult"];
            }

            [self didChangeValueForKey:@"jsonResult"];

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
