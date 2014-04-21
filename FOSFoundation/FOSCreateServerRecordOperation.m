//
//  FOSCreateServerRecordOperation.m
//  FOSFoundation
//
//  Created by David Hunt on 4/10/14.
//  Copyright (c) 2014 FOS Computer Services. All rights reserved.
//

#import "FOSCreateServerRecordOperation.h"

@implementation FOSCreateServerRecordOperation

#pragma mark - Class Methods

+ (instancetype)createOperationForCMO:(FOSCachedManagedObject *)cmo {
    return [[self alloc] initWithCMO:cmo forLifecyclePhase:FOSLifecyclePhaseCreateServerRecord];
}

@end
