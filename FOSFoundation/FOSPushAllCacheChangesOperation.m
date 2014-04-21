//
//  FOSPushAllCacheChangesOperation.m
//  FOSFoundation
//
//  Created by David Hunt on 1/7/13.
//  Copyright (c) 2013 FOS Computer Services. All rights reserved.
//

#import "FOSPushAllCacheChangesOperation.h"
#import "FOSPushCacheChangesOperation.h"

@implementation FOSPushAllCacheChangesOperation

+ (instancetype)pushAllChangesOperation {
    return [[self alloc] init];
}

- (id)init {
    if ((self = [super init]) != nil) {
        FOSPushCacheChangesOperation *pushOp = [FOSPushCacheChangesOperation pushCacheChangesOperationWithParentOperation:self];

        [self addDependency:pushOp];
    }

    return self;
}

@end
