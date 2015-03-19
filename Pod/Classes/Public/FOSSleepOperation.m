//
//  FOSSleepOperation.m
//  FOSRest
//
//  Created by David Hunt on 12/22/12.
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

#import <FOSSleepOperation.h>
#import <FOSThreadSleep.h>

@implementation FOSSleepOperation {
    BOOL _isCancelled;
    BOOL _isExecuting;
    BOOL _isFinished;
    FOSThreadSleep *_threadSleep;
}

#pragma mark - Class Methods

+ (instancetype)sleepOperationWithSleepInterval:(NSTimeInterval)sleepInterval {
    NSParameterAssert(sleepInterval >= 0.0);

    FOSSleepOperation *result = [[self alloc] initWithSleepInterval:sleepInterval];

    return result;
}

#pragma mark - Initialization Methods

- (id)initWithSleepInterval:(NSTimeInterval)sleepInterval {
    NSParameterAssert(sleepInterval >= 0.0);

    if ((self = [super init]) != nil) {
        _sleepInterval = sleepInterval;
    }

    return self;
}

#pragma mark - Overrides

- (BOOL)isConcurrent {
    return YES;
}

- (BOOL)isCancelled {
    @synchronized(self) {
        BOOL result = _isCancelled;

        if (!result) {
            result = [super isCancelled];
        }

        return result;
    }
}

- (BOOL)isExecuting {
    @synchronized(self) {
        return _isExecuting;
    }
}

- (BOOL)isFinished {
    @synchronized(self) {
        return _isFinished;
    }
}

- (void)start {
    @synchronized(self) {
        __block FOSSleepOperation *blockSelf = self;

        _threadSleep = [FOSThreadSleep threadSleepWithSleepInterval:_sleepInterval andCompletionHandler:^(BOOL cancelled, NSError *error) {

            [blockSelf willChangeValueForKey:@"isExecuting"];
            [blockSelf willChangeValueForKey:@"isFinished"];

            if (cancelled) {
                [blockSelf willChangeValueForKey:@"isCancelled"];
            }

            blockSelf->_isCancelled = cancelled;
            blockSelf->_isExecuting = NO;
            blockSelf->_isFinished = YES;

            if (cancelled) {
                [blockSelf didChangeValueForKey:@"isCancelled"];
            }
            [blockSelf didChangeValueForKey:@"isExecuting"];
            [blockSelf didChangeValueForKey:@"isFinished"];
        }];
        [_threadSleep start];

        _isExecuting = YES;
        [self didChangeValueForKey:@"isExecuting"];
    }
}

- (void)cancel {
    [super cancel];

    @synchronized(self) {
        [self willChangeValueForKey:@"isFinished"];
        [self willChangeValueForKey:@"isExecuting"];
        _isCancelled = YES;
        _isExecuting = NO;
        _isFinished = YES;
        [self didChangeValueForKey:@"isExecuting"];
        [self didChangeValueForKey:@"isFinished"];
    }
}

@end
