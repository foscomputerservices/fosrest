//
//  FOSSendToManyRelationshipOperation.m
//  FOSFoundation
//
//  Created by David Hunt on 4/10/14.
//  Copyright (c) 2014 FOS Computer Services. All rights reserved.
//

#import "FOSSendToManyRelationshipOperation.h"
#import "FOSFoundation_Internal.h"

@implementation FOSSendToManyRelationshipOperation

#pragma mark - Initialization Methods

- (id)initWithCMO:(FOSCachedManagedObject *)cmo
  forRelationship:(NSRelationshipDescription *)relDesc
    parentSentIDs:(NSSet *)parentSentIDs {
    if ((self = [super initWithCMO:cmo forRelationship:relDesc parentSentIDs:parentSentIDs]) != nil) {

        id<NSFastEnumeration> relatedCMOs = [cmo primitiveValueForKey:relDesc.name];
        if (relatedCMOs != nil) {

            for (FOSCachedManagedObject *relatedCMO in relatedCMOs) {

                if (![parentSentIDs containsObject:relatedCMO.objectID] &&
                    !relatedCMO.isLocalOnly) {
                    FOSSendServerRecordOperation *sendOp =
                        [relatedCMO sendServerRecordWithLifecycleStyle:nil parentSentIDs:parentSentIDs];

                    [self addDependency:sendOp];
                }
            }
        }
    }

    return self;
}

@end
