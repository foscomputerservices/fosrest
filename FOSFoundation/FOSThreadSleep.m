//
//  FOSThreadSleep.m
//  FOSFoundation
//
//  Created by David Hunt on 12/8/13.
//  Copyright (c) 2013 FOS Computer Services. All rights reserved.
//

#import "FOSThreadSleep.h"
#import "time.h"

const double resolution = 4.0; // times/second to check for cancellation

@implementation FOSThreadSleep {
    NSTimeInterval _sleepInterval;
    FOSBackgroundRequest _completionHandler;
}

#pragma mark - Class methods

+ (instancetype)threadSleepWithSleepInterval:(NSTimeInterval)sleepInterval
                        andCompletionHandler:(FOSBackgroundRequest)completionHandler {
    NSParameterAssert(sleepInterval > 0.0f);
    NSParameterAssert(completionHandler != nil);

    return [[self alloc] initWithSleepInterval:sleepInterval andCompletionHandler:completionHandler];
}

#pragma mark - Properties

- (NSTimeInterval)sleepInterval {
    return _sleepInterval;
}

#pragma mark - Init Methods

- (id)initWithSleepInterval:(NSTimeInterval)sleepInterval
       andCompletionHandler:(FOSBackgroundRequest)completionHandler {
    NSParameterAssert(sleepInterval > 0.0f);
    NSParameterAssert(completionHandler != nil);

    if ((self = [super init]) != nil) {
        _sleepInterval = sleepInterval;
        _completionHandler = completionHandler;
    }

    return self;
}

#pragma mark - Overrides

- (void)main {
    int sleepFragments = (int)(self.sleepInterval * resolution);

    NSAssert(sleepFragments > 0, @"sleepInterval must be > %g", 1.0 / resolution);

    struct timespec timeSpec;
    timeSpec.tv_sec = 0L;
    timeSpec.tv_nsec = 1000000000L / (NSUInteger)resolution; // Nanosecond = 1 billionth of a second

    // Spin waiting/cancelling, if necessary
    for (int sleepFragment = 0;
         !self.isCancelled && sleepFragment < sleepFragments;
         sleepFragment++) {

        // Sleep for another resolution epoch
        nanosleep(&timeSpec, NULL);
    }

    _completionHandler(self.isCancelled, nil);
}

@end
