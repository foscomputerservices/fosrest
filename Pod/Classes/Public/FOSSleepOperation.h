//
//  FOSSleepOperation.h
//  FOSFoundation
//
//  Created by David Hunt on 12/22/12.
//  Copyright (c) 2012 FOS Computer Services. All rights reserved.
//

#import <FOSFoundation/FOSOperation.h>

@interface FOSSleepOperation : FOSOperation

#pragma mark - Class Methods

+ (instancetype)sleepOperationWithSleepInterval:(NSTimeInterval)sleepInterval;

#pragma mark - Public Properties

@property (nonatomic, readonly) NSTimeInterval sleepInterval;

#pragma mark - Initialization Methods

- (id)initWithSleepInterval:(NSTimeInterval)sleepInterval;

@end
