//
//  FOSSleepOperation.m
//  FOSFoundation
//
//  Created by David Hunt on 12/22/12.
//  Copyright (c) 2012 FOS Computer Services. All rights reserved.
//

#import "FOSSleepOperation.h"
#import "FOSThreadSleep.h"

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
