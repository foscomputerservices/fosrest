//
//  FOSSendRelationshipOperation.m
//  FOSFoundation
//
//  Created by David Hunt on 4/10/14.
//  Copyright (c) 2014 FOS Computer Services. All rights reserved.
//

#import "FOSSendRelationshipOperation.h"

@implementation FOSSendRelationshipOperation {
    NSManagedObjectID *_cmoID;
}

#pragma mark - Class Methods

+ (instancetype)operationForCMO:(FOSCachedManagedObject *)cmo
                forRelationship:(NSRelationshipDescription *)relDesc {

    return [[self alloc] initWithCMO:cmo forRelationship:relDesc];
}

#pragma mark - Property Overides

- (FOSCachedManagedObject *)cmo {
    return (FOSCachedManagedObject *)[self.managedObjectContext objectWithID:_cmoID];
}

#pragma mark - Initialization methods

- (id)initWithCMO:(FOSCachedManagedObject *)cmo
  forRelationship:(NSRelationshipDescription *)relDesc {
    if ((self = [super init]) != nil) {
        _cmoID = cmo.objectID;
        _relDesc = relDesc;
    }
    
    return self;
}

@end
