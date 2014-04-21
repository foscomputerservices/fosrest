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
        if (_mainCalled) {
            [self willChangeValueForKey:@"error"];
        }
        _error = error;
        if (_mainCalled) {
            [self didChangeValueForKey:@"error"];
        }

        // The order of ops here is as detailed in Apple's docs:
        // http://developer.apple.com/library/ios/#documentation/General/Conceptual/ConcurrencyProgrammingGuide/OperationObjects/OperationObjects.html

        if (_mainCalled) {
            [self willChangeValueForKey:@"isFinished"];
            [self willChangeValueForKey:@"isExecuting"];
        }
        _requestState = FOSWSRequestStateFinished;
        if (_mainCalled) {
            [self didChangeValueForKey:@"isExecuting"];
            [self didChangeValueForKey:@"isFinished"];
        }
    }
}

- (void)setJsonResult:(id<NSObject>)jsonResult {
    @synchronized(self) {
        if (_mainCalled) {
            [self willChangeValueForKey:@"jsonResult"];
        }
        _jsonResult = jsonResult;
        if (_mainCalled) {
            [self didChangeValueForKey:@"jsonResult"];
        }

        // The order of ops here is as detailed in Apple's docs:
        // http://developer.apple.com/library/ios/#documentation/General/Conceptual/ConcurrencyProgrammingGuide/OperationObjects/OperationObjects.html
        if (_mainCalled) {
            [self willChangeValueForKey:@"isFinished"];
            [self willChangeValueForKey:@"isExecuting"];
        }
        _requestState = FOSWSRequestStateFinished;
        if (_mainCalled) {
            [self didChangeValueForKey:@"isExecuting"];
            [self didChangeValueForKey:@"isFinished"];
        }
    }
}

@end
