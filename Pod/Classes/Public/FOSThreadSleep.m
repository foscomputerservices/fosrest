//
//  FOSThreadSleep.m
//  FOSRest
//
//  Created by David Hunt on 12/8/13.
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

#import <FOSThreadSleep.h>
#import <time.h>

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
