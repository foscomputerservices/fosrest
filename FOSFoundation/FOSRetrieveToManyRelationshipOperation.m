//
//  FOSRetrieveToManyRelationshipOperation.m
//  FOSFoundation
//
//  Created by David Hunt on 12/31/12.
//  Copyright (c) 2012 FOS Computer Services. All rights reserved.
//

#import "FOSRetrieveToManyRelationshipOperation.h"
#import "FOSRetrieveCMOOperation+FOS_Internal.h"
#import "FOSRelationshipFault.h"

@implementation FOSRetrieveToManyRelationshipOperation {
    NSMutableSet *_boundEntityQueries;
    BOOL _ignoreDependentErrors;
    NSError *_error;
}

+ (instancetype)fetchToManyRelationship:(NSRelationshipDescription *)relDesc
                              ownerJson:(id<NSObject>)ownerJson
                            ownerJsonId:(FOSJsonId)ownerJsonId
                           withBindings:(NSMutableDictionary *)bindings
                andParentFetchOperation:(FOSRetrieveCMOOperation *)parentFetchOp {
    NSParameterAssert(relDesc != nil);
    NSParameterAssert(ownerJsonId != nil);

    return [[self alloc] initToManyRelationship:relDesc
                                      ownerJson:ownerJson
                                    ownerJsonId:ownerJsonId
                                   withBindings:bindings
                        andParentFetchOperation:parentFetchOp];
}

- (id)initToManyRelationship:(NSRelationshipDescription *)relDesc
                   ownerJson:(id<NSObject>)ownerJson
                 ownerJsonId:(FOSJsonId)ownerJsonId
                withBindings:(NSMutableDictionary *)bindings
     andParentFetchOperation:(FOSRetrieveCMOOperation *)parentFetchOp {
    NSParameterAssert(relDesc != nil);
    NSParameterAssert(ownerJsonId != nil);

    if ((self = [super init]) != nil) {
        _relationship = relDesc;
        _parentFetchOp = parentFetchOp;

        __block FOSRetrieveToManyRelationshipOperation *blockSelf = self;

        // Retrieve query(ies) to pull array of json fragments defining the members of the
        // relationship relDesc.  The relationship might be to an abstract type, so then we
        // need to pull across the relationship for all leaf types of the abstract type,
        // which is why there might be multiple queries.
        NSSet *leafEntities = relDesc.destinationEntity.leafEntities;
        NSMutableSet *requests = [NSMutableSet setWithCapacity:leafEntities.count];

        id<FOSRESTServiceAdapter> adapter = self.restConfig.restServiceAdapter;
        BOOL found = NO;
        for (NSEntityDescription *nextLeafEntity in leafEntities) {
            FOSURLBinding *urlBinding =
                [adapter urlBindingForLifecyclePhase:FOSLifecyclePhaseRetrieveServerRecordRelationship
                                     forRelationship:relDesc
                                       forEntity:nextLeafEntity];

            if (urlBinding != nil) {
                NSError *localError = nil;
                NSURLRequest *urlRequest =
                    [urlBinding urlRequestServerRecordsOfRelationship:relDesc
                                                 forDestinationEntity:nextLeafEntity
                                                          withOwnerId:ownerJsonId
                                                                error:&localError];

                if (localError != nil) {
                    NSString *msg = localError.description;

                    NSException *e = [NSException exceptionWithName:@"FOSFoundation"
                                                             reason:msg
                                                           userInfo:nil];
                    @throw e;
                }

                FOSWebServiceRequest *request = [FOSWebServiceRequest requestWithURLRequest:urlRequest
                                                                              forURLBinding:urlBinding];
                NSDictionary *requestEntry = @{
                                               @"DestEntity" : nextLeafEntity,
                                               @"Request" : request
                                              };
                [requests addObject:requestEntry];

                found = YES;
            }
        }

        if (!found) {
            NSString *msgFmt = @"Unable to locate a URL_BINDING for lifecycle RETRIEVE_SERVER_RECORD of entity %@ (across to-many relationship %@ of entity %@)";
            NSString *msg = [NSString stringWithFormat:msgFmt,
                             relDesc.destinationEntity.name, relDesc.name,
                             relDesc.entity.name];

            NSException *e = [NSException exceptionWithName:@"FOSFoundation"
                                                     reason:msg
                                                   userInfo:nil];
            @throw e;
        }

        for (NSDictionary *nextRequestEntry in requests) {

            NSEntityDescription *destEntity = nextRequestEntry[@"DestEntity"];
            FOSWebServiceRequest *webServiceRequest = nextRequestEntry[@"Request"];

            NSAssert(destEntity != nil, @"Expected a destination entity description!");
            NSAssert(webServiceRequest != nil, @"Expected web service request!");

            FOSBackgroundOperation *bgOp = [FOSBackgroundOperation backgroundOperationWithRequest:^(BOOL isCancelled, NSError *error) {

                if (!isCancelled && error == nil) {

                    // Now that we've retrieved the fragments representing the members of the
                    // relationship, bind each entity.
                    //
                    // NOTE: We'd like to just create the entity and be done here, but the
                    //       entity might, itself, have relationships that need to be bound,
                    //       so we must use the FOSFetchEntityOperation to ensure that all
                    //       require relationships are bound correctly.
                    NSArray *jsonFragments = (NSArray *)webServiceRequest.jsonResult;
                    NSUInteger fragCount = jsonFragments.count;

                    // Let's see if we can short-circuit a test for cardinality here
                    BOOL isValid = YES;
                    if (isValid && self.relationship.minCount > 0) {
                        isValid = fragCount >= blockSelf.relationship.minCount;
                    }

                    if (isValid && self.relationship.maxCount > 0) {
                        NSUInteger fragCount = jsonFragments.count;

                        isValid = fragCount <= blockSelf.relationship.maxCount;
                    }
                    
                    if (isValid) {
                        blockSelf->_boundEntityQueries = [NSMutableSet setWithCapacity:jsonFragments.count];

                        id<FOSRESTServiceAdapter> adapter = self.restConfig.restServiceAdapter;
                        FOSURLBinding *urlBinding =
                            [adapter urlBindingForLifecyclePhase:FOSLifecyclePhaseRetrieveServerRecordRelationship
                                                 forRelationship:relDesc
                                                   forEntity:relDesc.entity];
                        id<FOSTwoWayRecordBinding> recordBinder = urlBinding.cmoBinding;

                        NSError *localError = nil;
                        NSMutableArray *fetchIds = [NSMutableArray arrayWithCapacity:jsonFragments.count];
                        for (NSDictionary *jsonFragment in jsonFragments) {
                            FOSJsonId jsonId = [recordBinder jsonIdFromJSON:jsonFragment
                                                                  forEntity:destEntity
                                                                      error:&localError];
                            if (jsonId && localError == nil) {
                                [fetchIds addObject:jsonId];
                            }
                            else {
                                blockSelf->_error = localError;
                                break;
                            }
                        }

                        if (localError == nil) {
                            // Do a top-level pull for these entities from the database to reduce the number
                            // of incremental DB hits as the entities are processed by FOSFetchEntityOperation
                            NSMutableDictionary *newBindings =
                                [[FOSRetrieveCMOOperation class] primeBindingsForEntity:destEntity
                                                                            withJsonIDs:fetchIds];

                            // Add to existing bindings
                            [bindings addEntriesFromDictionary:newBindings];

                            for (id<NSObject> nextFragment in jsonFragments) {
                                // NOTE: Here we use the 'related' form of the constructor to inihibit save
                                //       of the context until the entire graph is loaded.  This ensures that
                                //       the required relationships are realized.

                                FOSRetrieveCMOOperation *nextFetchOp =
                                    [FOSRetrieveCMOOperation fetchRelatedManagedObjectForEntity:destEntity
                                                                                 ofRelationship:relDesc
                                                                                       withJson:nextFragment
                                                                                   withBindings:bindings
                                                                        andParentFetchOperation:blockSelf->_parentFetchOp];

                                [blockSelf->_boundEntityQueries addObject:nextFetchOp];

                                [blockSelf addDependency:nextFetchOp];
                            }

                            // Requeue self adding further dependencies
                            [self.restConfig.cacheManager requeueOperation:self];
                        }
                    }
                    else {
                        NSString *msg = [NSString stringWithFormat:@"Relationship %@ of entity %@(%@) does not contain the schema required number of destination entities.  Found %lu entities, but the required MIN was %lu and the required MAX was %lu.",
                                         blockSelf.relationship.name,
                                         blockSelf.relationship.entity.name,
                                         ownerJsonId,
                                         (unsigned long)jsonFragments.count,
                                         (unsigned long)blockSelf.relationship.minCount,
                                         (unsigned long)blockSelf.relationship.maxCount];

                        blockSelf->_error = [NSError errorWithDomain:@"FOSFoundation" errorCode:0 andMessage:msg];
                    }
                }
            }];

            [bgOp addDependency:webServiceRequest];
            [self addDependency:bgOp];
        }
    }

    return self;
}

- (void)bindToOwner:(NSManagedObjectID *)ownerId {
    NSParameterAssert(ownerId != nil);

    if (!self.isCancelled && self.error == nil) {
        id relationshipMutableSet = nil;

        NSManagedObjectContext *moc = self.managedObjectContext;
        FOSCachedManagedObject *owner = (FOSCachedManagedObject *)[moc objectWithID:ownerId];

        NSAssert(owner != nil, @"Unable to locate owner object!");
        NSAssert(_relationship.isOwnershipRelationship, @"Not an ownership relationship???");

        if (_relationship.isOrdered) {
            relationshipMutableSet = [owner mutableOrderedSetValueForKey:_relationship.name];
        }
        else {
            relationshipMutableSet = [owner mutableSetValueForKey:_relationship.name];
        }

        BOOL encounteredErrors = NO;

        // There no longer exist any relations, so make sure to clear the local relationships.
        if (_boundEntityQueries.count == 0) {
            id<NSFastEnumeration> deadCMOs = [relationshipMutableSet mutableCopy];

            for (FOSCachedManagedObject *nextDeadCMO in deadCMOs) {
                if (nextDeadCMO.hasBeenUploadedToServer) {
                    NSAssert(!nextDeadCMO.isDirty, @"Attempting to delete a dirty object.");

                    // Tell the underlying delete code not to attempt to remove this obj from
                    // the server, as it's already been done.
                    nextDeadCMO.skipServerDelete = YES;

                    [relationshipMutableSet removeObject:nextDeadCMO];
                    [nextDeadCMO.managedObjectContext deleteObject:nextDeadCMO];
                }
            }
        }
        else {
            // Gather the, now realized, entities
            NSMutableSet *newEntries = [NSMutableSet setWithCapacity:_boundEntityQueries.count];
            for (FOSRetrieveCMOOperation *nextOp in _boundEntityQueries) {

                // If the op was cancelled, we won't include it in our result set.
                // One way that an op can be cancelled is if it was marked as deleted
                // locally, but still remains on the server.
                if (!nextOp.isCancelled) {
                    [nextOp finishBinding];

                    FOSCachedManagedObject *nextCMO = nextOp.managedObject;
                    BOOL cmoWasDirty = nextCMO.isDirty;

                    NSAssert(nextCMO != nil || nextOp.error != nil, @"We must have an instance or an error by now.");

                    // It's possible that there were lower-level binding issues, so we need to check
                    if (nextCMO != nil) {

#ifndef NS_BLOCK_ASSERTIONS
                        Class destClass = NSClassFromString(_relationship.destinationEntity.managedObjectClassName);

                        NSAssert([nextCMO isKindOfClass:destClass], @"Received type %@, expected %@.",
                                 NSStringFromClass([nextCMO class]),
                                 _relationship.destinationEntity.managedObjectClassName);
#endif
                        // Set the forward relationship
                        [newEntries addObject:nextOp.managedObject];

                        // Set Inverse relationship
                        NSRelationshipDescription *inverse = _relationship.inverseRelationship;
                        if (!inverse.isToMany) {
                            [nextCMO setValue:owner forKey:inverse.name];
                        }
                        else {
                            NSAssert(NO, @"Many-to-many not yet implemented!");
                        }

                        if (!cmoWasDirty && nextCMO.isDirty) {
                            [nextCMO markClean];
                        }
                    }
                    else {
                        if (!_relationship.isOptional) {
                            NSAssert(nextOp.error != nil, @"Should only get here on an error!");
                            NSAssert(self.error != nil, @"We should have an error as one of our deps has an error.");

                            encounteredErrors = YES;
                            _ignoreDependentErrors = NO;
                            break;
                        }
                        else {
                            NSLog(@"IGNORING ERROR: during to-many fetch operation %@ to entity %@: %@",
                                  _relationship.name, _relationship.entity.name, nextOp.error.description);
                            _ignoreDependentErrors = YES;
                        }
                    }
                }
            }

            if (!encounteredErrors) {
                // Clean up the entries that might be locally deleted
                [self _removeDeadCMOSFromRelationshipSet:relationshipMutableSet newEntries:newEntries];

                // Combine with the new entries
                [relationshipMutableSet unionSet:newEntries];

                // Sort the ordered set
                if (_relationship.isOrdered) {
                    NSString *orderProp = _relationship.jsonOrderProp;
                    NSArray *sortKeys = [orderProp componentsSeparatedByString:@","];
                    NSMutableArray *sortDescs = [NSMutableArray arrayWithCapacity:sortKeys.count];

                    for (NSString *nextSortKey in sortKeys) {
                        NSSortDescriptor *nextSortDesc = [NSSortDescriptor sortDescriptorWithKey:nextSortKey
                                                                                       ascending:YES];
                        [sortDescs addObject:nextSortDesc];
                    }

                    NSMutableOrderedSet *orderedSet = (NSMutableOrderedSet *)relationshipMutableSet;

                    // Why NSMutableOrdered set doesn't implement sortUsingDescriptors is beyond me!
                    [orderedSet sortUsingComparator:^NSComparisonResult(id obj1, id obj2) {
                        NSComparisonResult compResult = NSOrderedSame;

                        for (NSSortDescriptor *nextSortDesc in sortDescs) {
                            compResult = [nextSortDesc compareObject:obj1 toObject:obj2];
                            if (compResult != NSOrderedSame) {
                                break;
                            }
                        }

                        return compResult;
                    }];
                }
            }
            else {
                [relationshipMutableSet removeAllObjects];
            }
        }
    }
}

- (void)finishOrdering {
    for (FOSRetrieveCMOOperation *nextOp in _boundEntityQueries) {
        [nextOp finishOrdering];
    }
}

- (void)finishValidation {
    for (FOSRetrieveCMOOperation *nextOp in _boundEntityQueries) {
        [nextOp finishValidation];
    }
}

- (void)finishCleanup:(BOOL)forceDestroy {
    for (FOSRetrieveCMOOperation *nextOp in _boundEntityQueries) {
        [nextOp finishCleanup:forceDestroy || (self.error != nil)];
    }
}

#pragma mark - Overrides

- (NSError *)error {
    NSError *result = _error;

    if (!_ignoreDependentErrors && result == nil) {
        result = [super error];
    }

    return result;
}

- (BOOL)isCancelled {

    // We don't want our dependencies to cancel us. Cancellation usually
    // results in pulling down an already deleted object.
    return NO;
}

- (NSString *)debugDescription {
    NSString *result = [NSString stringWithFormat:@"%@ - %@::%@",
                        [super debugDescription],
                        _relationship.entity.name, _relationship.name];

    return result;
}

#pragma mark - Private Methods

- (void)_removeDeadCMOSFromRelationshipSet:(id)relationshipMutableSet
                                newEntries:(NSMutableSet *)newEntries {

    // Remove entries that are no longer found on the server.
    // NOTE: We cannot just assign mutableSet to newEntries, so we need to
    //       manually remove dead entries.  Additionally, we want to keep the number
    //       of changes to the absolute minimum as to not send false KVO notifications.
    NSMutableSet *deadObjectIDs = [[relationshipMutableSet valueForKeyPath:@"objectID"] mutableCopy];
    NSMutableSet *newObjectIDs = [newEntries valueForKeyPath:@"objectID"];

    [deadObjectIDs minusSet:newObjectIDs];
    NSPredicate *pred = [NSPredicate predicateWithFormat:@"objectID in %@", deadObjectIDs];
    id<NSFastEnumeration> deadCMOs = nil;
    if (_relationship.isOrdered) {
        deadCMOs = [relationshipMutableSet filteredOrderedSetUsingPredicate:pred];
    }
    else {
        deadCMOs = [relationshipMutableSet filteredSetUsingPredicate:pred];
    }

    for (FOSCachedManagedObject *nextDeadCMO in deadCMOs) {
        if (nextDeadCMO.hasBeenUploadedToServer) {
            NSAssert(!nextDeadCMO.isDirty, @"Attempting to delete a dirty object.");

            // Tell the underlying delete code not to attempt to remove this obj from
            // the server, as it's already been done.
            nextDeadCMO.skipServerDelete = YES;

            [relationshipMutableSet removeObject:nextDeadCMO];
            [nextDeadCMO.managedObjectContext deleteObject:nextDeadCMO];
        }
    }
}

@end
