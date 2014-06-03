//
//  FOSRetrieveRelationshipUpdatesOperation.m
//  FOSFoundation
//
//  Created by David Hunt on 6/3/14.
//  Copyright (c) 2014 FOS Computer Services. All rights reserved.
//

#import "FOSRetrieveRelationshipUpdatesOperation.h"

@interface _FOSCMODataOpPackage : FOSOperation<FOSRetrieveCMODataOperationProtocol>

+ (instancetype)packageFor:(FOSCachedManagedObject *)cmo
                  matching:(FOSItemMatcher *)relationshipNameMatcher;

@end

@implementation _FOSCMODataOpPackage

@synthesize entity = _entity;
@synthesize jsonId = _jsonId;
@synthesize jsonResult = _jsonResult;
@synthesize originalJsonResult = _originalJsonResult;
@synthesize relationshipsToPull = _relationshipsToPull;

+ (instancetype)packageFor:(FOSCachedManagedObject *)cmo
                  matching:(FOSItemMatcher *)relationshipNameMatcher {
    return [[self alloc] initForCMO:cmo forRelationships:relationshipNameMatcher];
}

- (id)initForCMO:(FOSCachedManagedObject *)cmo
forRelationships:(FOSItemMatcher *)relationshipNameMatcher {
    NSParameterAssert(cmo != nil);
    NSParameterAssert(relationshipNameMatcher != nil);

    if ((self = [super init])) {
        _entity = cmo.entity;
        _jsonId = cmo.jsonIdValue;
        _jsonResult = cmo.originalJson;
        _relationshipsToPull = relationshipNameMatcher;
    }

    return self;
}

@end

@implementation FOSRetrieveRelationshipUpdatesOperation

#pragma mark - Class Methods

+ (instancetype)retrieveRealtionshipUpdatesForCMO:(FOSCachedManagedObject *)cmo {
    return [[self alloc] initForCMO:cmo];
}

+ (instancetype)retrieveRealtionshipUpdatesForCMO:(FOSCachedManagedObject *)cmo
                                         matching:(FOSItemMatcher *)relationshipNameMatcher {
    return [[self alloc] initForCMO:cmo forRelationships:relationshipNameMatcher];
}

#pragma mark - Initialization Methods

- (id)initForCMO:(FOSCachedManagedObject *)cmo {
    return [self initForCMO:cmo forRelationships:[FOSItemMatcher matcherMatchingAllItems]];
}

- (id)initForCMO:(FOSCachedManagedObject *)cmo
forRelationships:(FOSItemMatcher *)relationshipNameMatcher {
    NSParameterAssert(cmo != nil);
    NSParameterAssert(relationshipNameMatcher != nil);

    if ((self = [super init]) != nil) {
        _FOSCMODataOpPackage *dataOpPackage = [_FOSCMODataOpPackage packageFor:cmo
                                                                      matching:relationshipNameMatcher];

        FOSRetrieveCMOOperation *retrieveCMO =
            [FOSRetrieveCMOOperation retrieveCMOUsingDataOperation:dataOpPackage
                                                 forLifecyclePhase:FOSLifecyclePhaseRetrieveServerRecord
                                                 forLifecycleStyle:self.lifecycleStyle];

        [self addDependency:retrieveCMO];
    }

    return self;
}

@end
