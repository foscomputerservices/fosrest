//
//  FOSMergePolicy.m
//  FOSFoundation
//
//  Created by David Hunt on 7/23/12.
//  Copyright (c) 2012 FOS Computer Services. All rights reserved.
//

#import "FOSMergePolicy.h"

@implementation FOSMergePolicy

#pragma mark - Overrides

- (id)initWithMergeType:(NSMergePolicyType)type {
    
    // We only support NSMergeByPropertyStoreTrumpMergePolicy
    self = [super initWithMergeType:NSMergeByPropertyStoreTrumpMergePolicyType];
    
    return self;
}

- (BOOL)resolveConflicts:(NSArray *)conflicts error:(NSError **)error {
    BOOL result = [super resolveConflicts:conflicts error:error];
    
    if (!result) {
        FOSLogDebug(@"FOSMergePloicy attempting to resolve %li conflicts...",
                    (unsigned long)conflicts.count);

        result = YES;
        
        for (NSMergeConflict *nextConflict in conflicts) {
            
            if (nextConflict.persistedSnapshot == nil) {
                if (![self _resolveConflict:nextConflict]) {
                    result = NO;
                }
            }
            
            // The problem is between the store coordinator and the external store
            else {
                result = NO;
            }
            
            if (!result) {
                break;
            }
        }
    }
    
    return result;
}

#pragma mark - Private methods

- (BOOL)_resolveConflict:(NSMergeConflict *)conflict {
    BOOL result = NO;

    if ([conflict.sourceObject isKindOfClass:[FOSCachedManagedObject class]]) {

        FOSCachedManagedObject *source = (FOSCachedManagedObject *)conflict.sourceObject;

        // Is the conflict in any of FOSManagedObject's properties
        NSDate *objUWSADate = conflict.objectSnapshot[@"updatedWithServerAt"];
        NSDate *cacheUWSADate = conflict.cachedSnapshot[@"updatedWithServerAt"];

        if (objUWSADate != cacheUWSADate) {
            NSComparisonResult comp = [objUWSADate compare:cacheUWSADate];

            // Pick the newest date
            if (comp == NSOrderedAscending) {
                source.updatedWithServerAt = cacheUWSADate;
                result = YES;
            }
            else {
                source.updatedWithServerAt = objUWSADate;
                result = YES;
            }
        }
    }

    return result;
}

@end
