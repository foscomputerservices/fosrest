//
//  FOSSendRelationshipOperation.m
//  FOSFoundation
//
//  Created by David Hunt on 4/10/14.
//  Copyright (c) 2014 FOS Computer Services. All rights reserved.
//

#import <FOSSendRelationshipOperation.h>
#import "FOSFoundation_Internal.h"

@implementation FOSSendRelationshipOperation {
    NSManagedObjectID *_cmoID;
}

#pragma mark - Class Methods

+ (instancetype)operationForCMO:(FOSCachedManagedObject *)cmo
                forRelationship:(NSRelationshipDescription *)relDesc
                  parentSentIDs:(NSSet *)parentSentIDs {

    return [[self alloc] initWithCMO:cmo forRelationship:relDesc parentSentIDs:parentSentIDs];
}

#pragma mark - Property Overides

- (FOSCachedManagedObject *)cmo {
    return (FOSCachedManagedObject *)[self.managedObjectContext objectWithID:_cmoID];
}

#pragma mark - Initialization methods

- (id)initWithCMO:(FOSCachedManagedObject *)cmo
  forRelationship:(NSRelationshipDescription *)relDesc
    parentSentIDs:(NSSet *)parentSentIDs {
    if ((self = [super init]) != nil) {
        _cmoID = cmo.objectID;
        _relDesc = relDesc;
        _parentSentIDs = parentSentIDs;
    }
    
    return self;
}

@end
