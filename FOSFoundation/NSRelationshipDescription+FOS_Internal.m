//
//  NSRelationshipDescription+FOS_Internal.m
//  FOSFoundation
//
//  Created by David Hunt on 12/28/12.
//  Copyright (c) 2012 FOS Computer Services. All rights reserved.
//

#import "NSRelationshipDescription+FOS_Internal.h"

@implementation NSRelationshipDescription (FOS_Internal)

- (BOOL)isFOSRelationship {
    BOOL result = NO;

    return result;
}

- (BOOL)isOwnershipRelationship {
    BOOL result =
        // delete rule == (Cascade | Deny) => we're the owner
        (self.deleteRule == NSCascadeDeleteRule || self.deleteRule == NSDenyDeleteRule) &&

        // Skip FOS's internal relationships
        !self.isFOSRelationship;

    return result;
}

@end
