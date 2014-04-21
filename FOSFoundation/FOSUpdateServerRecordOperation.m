//
//  FOSUpdateServerRecordOperation.m
//  FOSFoundation
//
//  Created by David Hunt on 4/8/14.
//  Copyright (c) 2014 FOS Computer Services. All rights reserved.
//

#import "FOSUpdateServerRecordOperation.h"

@implementation FOSUpdateServerRecordOperation

#pragma mark - Class Methods

+ (instancetype)updateOperationForCMO:(FOSCachedManagedObject *)cmo {
    return [[self alloc] initWithCMO:cmo forLifecyclePhase:FOSLifecyclePhaseUpdateServerRecord];
}

@end
