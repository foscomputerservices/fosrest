//
//  FOSSendToOneRelationshipOperation.m
//  FOSFoundation
//
//  Created by David Hunt on 4/10/14.
//  Copyright (c) 2014 FOS Computer Services. All rights reserved.
//

#import "FOSSendToOneRelationshipOperation.h"

@implementation FOSSendToOneRelationshipOperation

#pragma mark - Initialization methods

- (id)initWithCMO:(FOSCachedManagedObject *)cmo
  forRelationship:(NSRelationshipDescription *)relDesc {

    if ((self = [super initWithCMO:cmo forRelationship:relDesc]) != nil) {
        FOSCachedManagedObject *relObj = (FOSCachedManagedObject *)[cmo valueForKey:relDesc.name];
        if (relObj != nil) {
            [self addDependency:relObj.sendServerRecord];
        }
    }

    return self;
}

@end
