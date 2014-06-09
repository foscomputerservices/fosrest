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
                          withBindings:(NSMutableDictionary *)bindings {
    NSParameterAssert(relDesc != nil);
    NSParameterAssert(jsonFragment != nil);
    NSParameterAssert(bindings != nil);

    return [[self alloc] initToOneRelationship:relDesc
                                  jsonFragment:jsonFragment
                                  withBindings:bindings];
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
               withBindings:(NSMutableDictionary *)bindings {
    NSParameterAssert(relDesc != nil);
    NSParameterAssert(jsonFragment != nil);
    NSParameterAssert(bindings != nil);

    if ((self = [super init]) != nil) {
        _relationship = relDesc;
        _jsonFragment = jsonFragment;
        _bindings = bindings;

        NSEntityDescription *destEntity = _relationship.destinationEntity;
        NSError *localError = nil;

        if (!destEntity.isAbstract) {

            id<FOSRESTServiceAdapter> adapter = self.restConfig.restServiceAdapter;
            _urlBinding = [adapter urlBindingForLifecyclePhase:FOSLifecyclePhaseRetrieveServerRecordRelationship
                                             forLifecycleStyle:nil
                                               forRelationship:relDesc
                                                     forEntity:destEntity];

            if (_urlBinding == nil) {
                NSString *msgFmt = @"Missing URL_BINDING for lifecycle %@ for Relationship '%@' between Entity '%@' and Entity '%@'";
                NSString *msg = [NSString stringWithFormat:msgFmt,
                                 [FOSURLBinding stringForLifecycle:FOSLifecyclePhaseRetrieveServerRecordRelationship],
                                 relDesc.name,
                                 _relationship.entity.name,
                                 destEntity.name];

                localError = [NSError errorWithMessage:msg];
            }

            if (localError == nil &&
                (relDesc.isOwnershipRelationship ||
                 relDesc.jsonRelationshipForcePull == FOSForcePullType_Always)) {
                id<FOSTwoWayRecordBinding> recordBinder = _urlBinding.cmoBinding;

                if (recordBinder == nil) {
                    NSString *msgFmt = @"Missing CMO_BINDING for lifecycle %@ for Relationship '%@' between Entity '%@' and Entity '%@'";
                    NSString *msg = [NSString stringWithFormat:msgFmt,
                                     [FOSURLBinding stringForLifecycle:FOSLifecyclePhaseRetrieveServerRecordRelationship],
                                     relDesc.name,
                                     _relationship.entity.name,
                                     destEntity.name];

                    localError = [NSError errorWithMessage:msg forAtom:_urlBinding];
                }

                // Retrieve the relationship id from the parent's json
                FOSJsonId jsonId = [recordBinder jsonIdFromJSON:jsonFragment
                                                      forEntity:destEntity
                                                          error:&localError];

                if (localError == nil) {
                    if (jsonId != nil) {
                        _fetchRelatedEntityOp =
                            [FOSRetrieveCMOOperation fetchRelatedManagedObjectForEntity:destEntity
                                                                         ofRelationship:relDesc
                                                                                 withId:jsonId
                                                                           withBindings:bindings];

                        [self addDependency:_fetchRelatedEntityOp];
                    }
                    else {
                        NSString *msgFmt = @"Unable to find identity for lifecycle %@ for Relationship '%@' between Entity '%@' and Entity '%@' in json: %@";
                        NSString *msg = [NSString stringWithFormat:msgFmt,
                                         [FOSURLBinding stringForLifecycle:FOSLifecyclePhaseRetrieveServerRecordRelationship],
                                         relDesc.name,
                                         _relationship.entity.name,
                                         destEntity.name,
                                         jsonFragment];

                        localError = [NSError errorWithMessage:msg forAtom:_urlBinding.cmoBinding];
                    }
                }
            }
        }
        else {
            NSString *msgFmt = @"Encountered an abstract destination entity on relationship %@ of entity %@.";
            NSString *msg = [NSString stringWithFormat:msgFmt,
                             relDesc.name,
                             _relationship.entity];

            localError = [NSError errorWithMessage:msg];
        }

        _error = localError;
    }

    return self;
}

- (void)bindToOwner:(NSManagedObjectID *)ownerId {
    NSParameterAssert(ownerId != nil);

    if (!self.isCancelled && self.error == nil) {
        FOSCachedManagedObject *childObj = nil;

        NSDictionary *childFragment = ((NSDictionary *)_jsonFragment);

        if (_fetchRelatedEntityOp != nil) {
            NSAssert(_relationship.isOwnershipRelationship ||
                     _relationship.jsonRelationshipForcePull != FOSForcePullType_Never,
                     @"Expected an ownership relationship, not a graph relationship.");
            [_fetchRelatedEntityOp finishBinding];
            childObj = _fetchRelatedEntityOp.managedObject;
        }
        else {
            NSEntityDescription *childEntity = _relationship.destinationEntity;

            if (childFragment != nil) {
                NSError *localError = nil;

                NSAssert(_urlBinding != nil, @"_urlBinding should have been assigned by now!");

                FOSJsonId childId = [_urlBinding.cmoBinding jsonIdFromJSON:childFragment
                                                           forRelationship:_relationship
                                                                     error:&localError];

                if (localError == nil && childId != nil) {
                    childObj = [FOSRetrieveCMOOperation cmoForEntity:childEntity
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

                    NSError *error = [NSError errorWithMessage:msg];

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
