//
//  FOSRetrieveToOneRelationshipOperation.m
//  FOSFoundation
//
//  Created by David Hunt on 12/31/12.
//  Copyright (c) 2012 FOS Computer Services. All rights reserved.
//

#import "FOSRetrieveToOneRelationshipOperation.h"
#import "FOSRetrieveCMOOperation+FOS_Internal.h"
#import "FOSCachedManagedObject+FOS_Internal.h"
#import "NSRelationshipDescription+FOS_Internal.h"

@implementation FOSRetrieveToOneRelationshipOperation {
    __block NSError *_error;
    BOOL _ignoreDependentErrors;
    FOSRetrieveCMOOperation *_fetchRelatedEntityOp;
    BOOL *_relAlreadyProcessing;
    NSMutableDictionary *_bindings;
    FOSURLBinding *_urlBinding;
}

+ (instancetype)fetchToOneRelationship:(NSRelationshipDescription *)relDesc
                          jsonFragment:(id<NSObject>)jsonFragment
                          withBindings:(NSMutableDictionary *)bindings
               andParentFetchOperation:(FOSRetrieveCMOOperation *)parentFetchOp {
    NSParameterAssert(relDesc != nil);
    NSParameterAssert(jsonFragment != nil);
    NSParameterAssert(bindings != nil);

    return [[self alloc] initToOneRelationship:relDesc
                                  jsonFragment:jsonFragment
                                  withBindings:bindings
                       andParentFetchOperation:parentFetchOp];
}

- (void)setIsQueued:(BOOL)isQueued {
    [super setIsQueued:isQueued];
}

- (NSError *)error {
    NSError *result = _error;

    if (result == nil && !_ignoreDependentErrors) {
        result = [super error];
    }

    return result;
}

- (id)initToOneRelationship:(NSRelationshipDescription *)relDesc
               jsonFragment:(id<NSObject>)jsonFragment
               withBindings:(NSMutableDictionary *)bindings
    andParentFetchOperation:(FOSRetrieveCMOOperation *)parentFetchOp {
    NSParameterAssert(relDesc != nil);
    NSParameterAssert(jsonFragment != nil);
    NSParameterAssert(bindings != nil);

    if ((self = [super init]) != nil) {
        _relationship = relDesc;
        _jsonFragment = jsonFragment;
        _bindings = bindings;
        _parentFetchOp = parentFetchOp;

        NSEntityDescription *destEntity = _relationship.entity;
        NSError *localError = nil;

#ifndef NS_BLOCK_ASSERTIONS
        NSEntityDescription *ownerEntity = _relationship.entity;
#endif
        NSAssert(!destEntity.isAbstract,
                 @"Encountered an abstract destination entity on relationship %@ of entity %@.",
                 relDesc.name, ownerEntity.name);

        id<FOSRESTServiceAdapter> adapter = self.restConfig.restServiceAdapter;
        _urlBinding = [adapter urlBindingForLifecyclePhase:FOSLifecyclePhaseRetrieveServerRecordRelationship
                                           forRelationship:relDesc
                                             forEntity:destEntity];
        id<FOSTwoWayRecordBinding> recordBinder = _urlBinding.cmoBinding;

        // Only force-load 'owned' relationships.  Non-owned relationships will assumed
        // to be already loaded by the time we're done.
        if (relDesc.isOwnershipRelationship) {
            // Retrieve the relationship id
            FOSJsonId jsonId = [recordBinder jsonIdFromJSON:jsonFragment
                                                  forEntity:destEntity
                                                      error:&localError];

            if (localError == nil) {
                _fetchRelatedEntityOp = [FOSRetrieveCMOOperation fetchRelatedManagedObjectForEntity:destEntity
                                                                                             withId:jsonId
                                                                                       withBindings:bindings
                                                                            andParentFetchOperation:parentFetchOp];

                [self addDependency:_fetchRelatedEntityOp];
            }
        }

        if (localError != nil) {
            _error = localError;
            self = nil;
        }
    }

    return self;
}

- (void)bindToOwner:(NSManagedObjectID *)ownerId {
    NSParameterAssert(ownerId != nil);

    if (!self.isCancelled && self.error == nil) {

        FOSCachedManagedObject *childObj = nil;

        NSDictionary *childFragment = ((NSDictionary *)_jsonFragment);

        if (_fetchRelatedEntityOp != nil) {
            NSAssert(_relationship.isOwnershipRelationship,
                     @"Expected an ownership relationship, not a graph relationship.");
            [_fetchRelatedEntityOp finishBinding];
            childObj = _fetchRelatedEntityOp.managedObject;
        }
        else {
            NSEntityDescription *childEntity = _relationship.destinationEntity;

            if (childFragment != nil) {
                NSError *localError = nil;

                FOSJsonId childId = [_urlBinding.cmoBinding jsonIdFromJSON:childFragment
                                                           forRelationship:_relationship
                                                                     error:&localError];

                if (localError == nil && childId != nil) {
                    childObj = [[FOSRetrieveCMOOperation class] cmoForEntity:childEntity
                                                                  withJsonId:childId
                                                                fromBindings:_bindings
                                                   respectingPreviousLookups:NO];
                }
                else {
                    _error = localError;
                }
            }

            // Here we have a relationship to an instance that does not exist on the
            // server.
            if (_error == nil && childObj == nil) {
                if (!_relationship.isOptional) {
                    NSManagedObjectContext *moc = self.managedObjectContext;
                    FOSCachedManagedObject *owner = (FOSCachedManagedObject *)[moc objectWithID:ownerId];

                    NSString *msgFormat = NSLocalizedString(@"Unable to pull %@ on relationship %@ of instance %@ of type %@ from the server.", @"");
                    NSString *msg = [NSString stringWithFormat:msgFormat,
                                     childEntity.name, _relationship.name, owner.jsonIdValue,
                                     _relationship.entity.name];

                    NSError *error = [NSError errorWithDomain:@"FOSFoundation"
                                                      message:msg
                                                  andUserInfo:nil];

                    _error = error;
                }
                else {
                    _ignoreDependentErrors = YES;
                }
            }
        }

        if (_error == nil && !_ignoreDependentErrors) {
            if (childObj == nil) {
                FOSJsonId jsonId = [_urlBinding.cmoBinding jsonIdFromJSON:childFragment
                                                                forEntity:_relationship.destinationEntity
                                                                    error:nil];
                NSString *title = @"FOSMissingChildEntity";
                NSString *msg = [NSString stringWithFormat:@"A child object is missing for relationship '%@' on entity '%@' for child entity %@ with childId '%@'.",
                                 _relationship.name,
                                 _relationship.entity.name,
                                 _relationship.destinationEntity.name,
                                 jsonId
                                 ];
                NSDictionary *userInfo = @{
                                           @"relationship" : _relationship.name,
                                           @"entity" : _relationship.entity.name,
                                           @"destEntity" : _relationship.destinationEntity.name,
                                           @"jsonFragment" : _jsonFragment
                                           };

                NSError *error = [NSError errorWithDomain:title
                                                  message:msg
                                              andUserInfo:userInfo];
                _error = error;
            }
            else {
                NSManagedObjectContext *moc = self.managedObjectContext;
                FOSCachedManagedObject *owner = (FOSCachedManagedObject *)[moc objectWithID:ownerId];
                BOOL ownerWasDirty = owner.isDirty;
                BOOL childWasDirty = childObj.isDirty;

                NSAssert(owner != nil, @"Unable to locate owner object???");

                NSAssert([owner primitiveValueForKey:_relationship.name] == nil ||
                         [owner primitiveValueForKey:_relationship.name] == childObj,
                         @"Relationship already bound???");

                // Set the forward relationship
                if ([owner primitiveValueForKey:_relationship.name] == nil) {
                    [owner setValue:childObj forKey:_relationship.name];
                }

                // Set the inverse relationship
                NSRelationshipDescription *inverse = _relationship.inverseRelationship;

                if (!inverse.isToMany) {
                    [childObj setValue:owner forKey:inverse.name];
                }
                else {
                    NSMutableSet *mutableSet = [childObj primitiveValueForKey:inverse.name];

                    [mutableSet addObject:owner];
                }

                if (!ownerWasDirty) {
                    [owner markClean];
                }
                if (!childWasDirty) {
                    [childObj markClean];
                }
            }
        }
    }
}

#pragma mark - Overrides

- (NSString *)debugDescription {
    NSString *result = [NSString stringWithFormat:@"%@ - %@::%@",
                        [super debugDescription],
                        _relationship.entity.name, _relationship.name];

    return result;
}

@end
