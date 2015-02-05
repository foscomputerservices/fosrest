//
//  FOSThreadSleep.h
//  FOSFoundation
//
//  Created by David Hunt on 12/8/13.
//  Copyright (c) 2013 FOS Computer Services. All rights reserved.
//

@import Foundation;
#import <FOSFoundation/FOSCacheManager.h>

@interface FOSThreadSleep : NSThread

#pragma mark - Class methods

+ (instancetype)threadSleepWithSleepInterval:(NSTimeInterval)sleepInterval
                        andCompletionHandler:(FOSBackgroundRequest)completionHandler;

#pragma mark - Properties

@property (nonatomic, readonly) NSTimeInterval sleepInterval;

#pragma mark - Init Methods

- (id)initWithSleepInterval:(NSTimeInterval)sleepInterval
       andCompletionHandler:(FOSBackgroundRequest)completionHandler;

@end
