//
//  FOSSearchOperation+Internal.m
//  FOSFoundation
//
//  Created by David Hunt on 10/7/13.
//  Copyright (c) 2013 FOS Computer Services. All rights reserved.
//

#import "FOSSearchOperation+Internal.h"

@implementation FOSSearchOperation (Internal)

- (void)finalizeDependencies {
    NSSet *depOps = self.dependentSearchOperations;

    // This op is dependent on all other search ops
    for (FOSOperation *nextDepOp in depOps) {
        [self addDependency:nextDepOp];
    }
}

@end
