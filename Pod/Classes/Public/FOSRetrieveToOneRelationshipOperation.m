//
//  FOSRetrieveToOneRelationshipOperation.m
//  FOSREST
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
    FOSCMOBinding *_parentCMOBinding;
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
        FOSCachedManagedObject *childObj = nil;

        NSDictionary *childFragment = ((NSDictionary *)_jsonFragment);

        if (_fetchRelatedEntityOp != nil) {
            NSAssert(_relationship.isOwnershipRelationship ||
                     !_relationship.isOptional ||
                     _relationship.jsonRelationshipForcePull != FOSForcePullType_Never,
                     @"Expected an ownership relationship, not a graph relationship.");
            [_fetchRelatedEntityOp finishBinding];
            childObj = _fetchRelatedEntityOp.managedObject;
        }
        else {
            NSEntityDescription *childEntity = _relationship.destinationEntity;

            if (childFragment != nil) {
                NSError *localError = nil;

                FOSJsonId childId = [_parentCMOBinding jsonIdFromJSON:childFragment
                                                      forRelationship:_relationship
                                                                error:&localError];

                if (localError == nil && childId != nil) {
                    childObj = [FOSRetrieveCMOOperation cmoForEntity:childEntity
                                                          withJsonId:childId
                                                        fromBindings:_bindings];
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
                FOSJsonId jsonId = [_parentCMOBinding jsonIdFromJSON:childFragment
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

                // Check FOSForcePullType_Always. Some clients use this to force the owner
                // to be different than what would normally be found when a parent pulls their
                // children.  That is, the parent object may pull children from its siblings
                // too, so those owners are not the parent object that performed the pull.
                NSAssert([owner primitiveValueForKey:_relationship.name] == nil ||
                         [owner primitiveValueForKey:_relationship.name] == childObj ||
                         _relationship.jsonRelationshipForcePull == FOSForcePullType_Always,
                         @"Relationship already bound???");

                // Set the forward relationship
                if ([owner primitiveValueForKey:_relationship.name] == nil ||
                    _relationship.jsonRelationshipForcePull == FOSForcePullType_Always) {
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
