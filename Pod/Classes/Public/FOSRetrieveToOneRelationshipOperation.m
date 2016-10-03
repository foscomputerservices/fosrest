//
//  FOSRetrieveToOneRelationshipOperation.m
//  FOSRest
//
//  Created by David Hunt on 12/31/12.
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

#import <FOSRetrieveToOneRelationshipOperation.h>
#import "FOSREST_Internal.h"

@implementation FOSRetrieveToOneRelationshipOperation {
    FOSRetrieveCMOOperation *_fetchRelatedEntityOp;
    BOOL *_relAlreadyProcessing;
    NSMutableDictionary *_bindings;
    __block FOSCMOBinding *_parentCMOBinding;
}

+ (instancetype)fetchToOneRelationship:(NSRelationshipDescription *)relDesc
                          jsonFragment:(id<NSObject>)jsonFragment
                          withBindings:(NSMutableDictionary *)bindings
                   andParentCMOBinding:(FOSCMOBinding *)parentCMOBinding {
    NSParameterAssert(relDesc != nil);
    NSParameterAssert(jsonFragment != nil);
    NSParameterAssert(bindings != nil);
    NSParameterAssert(parentCMOBinding != nil);

    return [[self alloc] initToOneRelationship:relDesc
                                  jsonFragment:jsonFragment
                                  withBindings:bindings
                           andParentCMOBinding:parentCMOBinding];
}

- (id)initToOneRelationship:(NSRelationshipDescription *)relDesc
               jsonFragment:(id<NSObject>)jsonFragment
               withBindings:(NSMutableDictionary *)bindings
        andParentCMOBinding:(FOSCMOBinding *)parentCMOBinding {
    NSParameterAssert(relDesc != nil);
    NSParameterAssert(jsonFragment != nil);
    NSParameterAssert(bindings != nil);
    NSParameterAssert(parentCMOBinding != nil);

    if ((self = [super init]) != nil) {
        _relationship = relDesc;
        _jsonFragment = jsonFragment;
        _bindings = bindings;
        _parentCMOBinding = parentCMOBinding;

        NSEntityDescription *destEntity = _relationship.destinationEntity;
        NSError *localError = nil;

        if (destEntity.leafEntities.count == 1) {
            destEntity = destEntity.leafEntities.anyObject;
        }

        if (!destEntity.isAbstract) {

            // Retrieve the relationship id from the parent's json
            FOSJsonId jsonId = [_parentCMOBinding jsonIdFromJSON:jsonFragment
                                                 forRelationship:relDesc
                                                           error:&localError];

            if (localError == nil) {
                // jsonId == nil => the server provided '<null>' for this relationship
                if (jsonId != nil) {
                    _fetchRelatedEntityOp =
                        [FOSRetrieveCMOOperation fetchRelatedManagedObjectForEntity:destEntity
                                                                     ofRelationship:relDesc
                                                                             withId:jsonId
                                                                       withBindings:bindings];

                    [self addDependency:_fetchRelatedEntityOp];
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
        NSManagedObjectContext *moc = self.managedObjectContext;
        __block FOSRetrieveToOneRelationshipOperation *blockSelf = self;

        [moc performBlockAndWait:^{
            FOSCachedManagedObject *childObj = nil;
            NSRelationshipDescription *relDesc = blockSelf.relationship;

            NSDictionary *childFragment = ((NSDictionary *)blockSelf.jsonFragment);

            if (blockSelf->_fetchRelatedEntityOp != nil) {
                NSAssert(blockSelf.relationship.isOwnershipRelationship ||
                         !relDesc.isOptional ||
                         [[moc objectWithID:ownerId] forcePullForRelationship:relDesc givenJSON:[[moc objectWithID:ownerId] originalJson]] != FOSForcePullType_Never,
                         @"Expected an ownership relationship, not a graph relationship.");
                [blockSelf->_fetchRelatedEntityOp finishBinding];
                childObj = [moc objectWithID:blockSelf->_fetchRelatedEntityOp.managedObjectID];
            }
            else {
                NSEntityDescription *childEntity = relDesc.destinationEntity;

                if (childFragment != nil) {
                    NSError *localError = nil;

                    FOSJsonId childId = [blockSelf->_parentCMOBinding jsonIdFromJSON:childFragment
                                                          forRelationship:relDesc
                                                                    error:&localError];

                    if (localError == nil && childId != nil) {
                        NSManagedObjectID *childObjID = [FOSRetrieveCMOOperation cmoForEntity:childEntity
                                                                                   withJsonId:childId
                                                                                 fromBindings:blockSelf->_bindings
                                                                       inManagedObjectContext:blockSelf.managedObjectContext];

                        childObj = [moc objectWithID:childObjID];
                    }
                    else {
                        blockSelf->_error = localError;
                    }
                }

                // Here we have a relationship to an instance that does not exist on the
                // server.
                if (blockSelf->_error == nil && childObj == nil) {
                    if (!relDesc.isOptional) {
                        NSManagedObjectContext *moc = blockSelf.managedObjectContext;
                        FOSCachedManagedObject *owner = (FOSCachedManagedObject *)[moc objectWithID:ownerId];

                        NSString *msgFormat = NSLocalizedString(@"Unable to pull %@ on relationship %@ of instance %@ of type %@ from the server.", @"");
                        NSString *msg = [NSString stringWithFormat:msgFormat,
                                         childEntity.name, relDesc.name, owner.jsonIdValue,
                                         relDesc.entity.name];

                        NSError *error = [NSError errorWithMessage:msg];

                        blockSelf->_error = error;
                    }
                    else {
                        blockSelf->_ignoreDependentErrors = YES;
                    }
                }
            }

            if (blockSelf->_error == nil && !blockSelf->_ignoreDependentErrors) {
                if (childObj == nil) {
                    FOSJsonId jsonId = [blockSelf->_parentCMOBinding jsonIdFromJSON:childFragment
                                                               forEntity:relDesc.destinationEntity
                                                                   error:nil];
                    NSString *title = @"FOSMissingChildEntity";
                    NSString *msg = [NSString stringWithFormat:@"A child object is missing for relationship '%@' on entity '%@' for child entity %@ with childId '%@'.",
                                     relDesc.name,
                                     relDesc.entity.name,
                                     relDesc.destinationEntity.name,
                                     jsonId
                                     ];
                    NSDictionary *userInfo = @{
                                               @"relationship" : relDesc.name,
                                               @"entity" : relDesc.entity.name,
                                               @"destEntity" : relDesc.destinationEntity.name,
                                               @"jsonFragment" : blockSelf.jsonFragment
                                               };

                    NSError *error = [NSError errorWithDomain:title
                                                      message:msg
                                                  andUserInfo:userInfo];
                    blockSelf->_error = error;
                }
                else {
                    FOSCachedManagedObject *owner = (FOSCachedManagedObject *)[moc objectWithID:ownerId];
                    BOOL ownerWasDirty = owner.isDirty;
                    BOOL childWasDirty = childObj.isDirty;

                    NSAssert(owner != nil, @"Unable to locate owner object???");

                    // Check FOSForcePullType_Always. Some clients use this to force the owner
                    // to be different than what would normally be found when a parent pulls their
                    // children.  That is, the parent object may pull children from its siblings
                    // too, so those owners are not the parent object that performed the pull.
                    NSAssert([owner primitiveValueForKey:relDesc.name] == nil ||
                             [owner primitiveValueForKey:relDesc.name] == childObj ||
                             [owner forcePullForRelationship:relDesc givenJSON:owner.originalJson] == FOSForcePullType_Always,
                             @"Relationship already bound???");

                    // Set the forward relationship
                    FOSForcePullType forcePull = [owner forcePullForRelationship:relDesc givenJSON: owner.originalJson];
                    
                    if ([owner primitiveValueForKey:relDesc.name] == nil ||
                        forcePull == FOSForcePullType_Always) {
                        [owner setValue:childObj forKey:relDesc.name];
                    }

                    // Set the inverse relationship
                    NSRelationshipDescription *inverse = relDesc.inverseRelationship;

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
        }];
    }
}

- (NSError *)finishValidation {
    NSError *result = [_fetchRelatedEntityOp finishValidation];

    return result;
}

- (void)finishCleanup:(BOOL)forceDestroy {
    [_fetchRelatedEntityOp finishCleanup:forceDestroy];
}

#pragma mark - Overrides

- (NSString *)debugDescription {
    NSString *result = [NSString stringWithFormat:@"%@ - %@::%@",
                        [super debugDescription],
                        _relationship.entity.name, _relationship.name];

    return result;
}

@end
