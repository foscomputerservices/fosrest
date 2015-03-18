//
//  FOSMergePolicy.m
//  FOSREST
//
//  Created by David Hunt on 7/23/12.
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

#import <FOSMergePolicy.h>
#import "FOSREST_Internal.h"

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
