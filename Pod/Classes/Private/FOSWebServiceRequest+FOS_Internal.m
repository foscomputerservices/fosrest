//
//  FOSWebServiceRequest+FOS_Internal.m
//  FOSFoundation
//
//  Created by David Hunt on 1/30/13.
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

#import "FOSWebServiceRequest+FOS_Internal.h"
#import "FOSFoundation_Internal.h"

@implementation FOSWebServiceRequest (FOS_Internal)

- (void)setError:(NSError *)error {
    @synchronized(self) {
        [self willChangeValueForKey:@"error"];
        _error = error;
        [self didChangeValueForKey:@"error"];

        [self _setToFinished];
    }
}

- (void)setOriginalJsonResult:(id<NSObject>)originalJsonResult
                postProcessor:(FOSRequestPostProcessor)postProcessor {
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

            if (postProcessor != nil) {
                postProcessor(originalJsonResult, jsonResult);
            }

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
