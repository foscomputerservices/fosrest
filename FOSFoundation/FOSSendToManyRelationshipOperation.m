//
//  FOSSendToManyRelationshipOperation.m
//  FOSFoundation
//
//  Created by David Hunt on 4/10/14.
//  Copyright (c) 2014 FOS Computer Services. All rights reserved.
//

#import "FOSSendToManyRelationshipOperation.h"

@implementation FOSSendToManyRelationshipOperation

#pragma mark - Initialization Methods

- (id)initWithCMO:(FOSCachedManagedObject *)cmo
  forRelationship:(NSRelationshipDescription *)relDesc {

    if ((self = [super initWithCMO:cmo forRelationship:relDesc]) != nil) {
        id<NSFastEnumeration> relatedCMOs = [cmo primitiveValueForKey:relDesc.name];
        if (relatedCMOs != nil) {

            for (FOSCachedManagedObject *relatedCMO in relatedCMOs) {
                FOSSendServerRecordOperation *sendOp = relatedCMO.sendServerRecord;

                [self addDependency:sendOp];
            }
        }
    }

    return self;
}

@end
