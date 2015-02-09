//
//  FOSRetrieveToManyRelationshipOperation.m
//  FOSFoundation
//
//  Created by David Hunt on 12/31/12.
//  Copyright (c) 2012 FOS Computer Services. All rights reserved.
//

#import <FOSRetrieveToManyRelationshipOperation.h>
#import "FOSFoundation_Internal.h"

@implementation FOSRetrieveToManyRelationshipOperation {
    NSMutableSet *_childRetrieveCMOOps;
    FOSCMOBinding *_parentCMOBinding;
    BOOL _mergeResults;
}

+ (instancetype)fetchToManyRelationship:(NSRelationshipDescription *)relDesc
                              ownerJson:(id<NSObject>)ownerJson
                            ownerJsonId:(FOSJsonId)ownerJsonId
                               dslQuery:(NSString *)dslQuery
                           mergeResults:(BOOL)mergeResults
                           withBindings:(NSMutableDictionary *)bindings
                    andParentCMOBinding:(FOSCMOBinding *)parentCMOBinding {
    NSParameterAssert(relDesc != nil);
    NSParameterAssert(ownerJsonId != nil);
    NSParameterAssert(parentCMOBinding != nil);

    return [[self alloc] initToManyRelationship:relDesc
                                      ownerJson:ownerJson
                                    ownerJsonId:ownerJsonId
                                       dslQuery:dslQuery
                                   mergeResults:mergeResults
                                   withBindings:bindings
                            andParentCMOBinding:(FOSCMOBinding *)parentCMOBinding];
}

- (id)initToManyRelationship:(NSRelationshipDescription *)relDesc
                   ownerJson:(id<NSObject>)ownerJson
                 ownerJsonId:(FOSJsonId)ownerJsonId
                    dslQuery:(NSString *)dslQuery
                mergeResults:(BOOL)mergeResults
                withBindings:(NSMutableDictionary *)bindings
         andParentCMOBinding:(FOSCMOBinding *)parentCMOBinding {
    NSParameterAssert(relDesc != nil);
    NSParameterAssert(ownerJsonId != nil);
    NSParameterAssert(parentCMOBinding != nil);

    if ((self = [super init]) != nil) {
        _relationship = relDesc;
        _parentCMOBinding = parentCMOBinding;
        _mergeResults = mergeResults;

        NSError *localError = nil;

        // Retrieve query(ies) to pull array of json fragments defining the members of the
        // relationship relDesc.  The relationship might be to an abstract type, so then we
        // need to pull across the relationship for all leaf types of the abstract type,
        // which is why there might be multiple queries.
        NSSet *leafEntities = relDesc.destinationEntity.leafEntities;

        // Look to see if we can bind to json in the bindings from upper-level queries
        NSSet *existingJSON = [self _jsonBindingsForRelationship:relDesc
                                                    leafEntities:leafEntities
                                                        bindings:bindings
                                                     ownerJsonId:ownerJsonId];

        NSSet *requests = nil;
        if (existingJSON == nil) {

            // If couldn't find JSON, then we need to ask the server
            requests = [self _webServiceRequestsForRelationship:relDesc
                                                   leafEntities:leafEntities
                                                       bindings:bindings
                                                    ownerJsonId:ownerJsonId
                                                       dslQuery:dslQuery
                                                          error:&localError];
        }

        // Process existing JSON
        if (existingJSON != nil) {
            for (NSDictionary *jsonEntry in existingJSON) {
                NSEntityDescription *destEntity = jsonEntry[@"DestEntity"];
                NSArray *existingJSON = jsonEntry[@"JSON"];

                [self _processJSONFragmentsForRelationships:relDesc
                                                   bindings:bindings
                                                 destEntity:destEntity
                                              jsonFragments:existingJSON];
            }
        }

        // Queue the server requests
        else if (requests != nil) {
            [self _queueRequestsForRelationship:relDesc
                                    ownerJsonId:ownerJsonId
                                       bindings:bindings
                                       requests:requests];
        }
        else if (localError == nil) {
            NSString *msgFmt = @"Unable to locate a URL_BINDING for lifecycle RETRIEVE_RELATIONSHIP of entity %@ (across to-many relationship %@ of entity %@)";
            NSString *msg = [NSString stringWithFormat:msgFmt,
                             relDesc.destinationEntity.name, relDesc.name,
                             relDesc.entity.name];

            localError = [NSError errorWithMessage:msg];
        }

        _error = localError;
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
        if (_childRetrieveCMOOps.count == 0) {
            if (!_mergeResults) {
                id<NSFastEnumeration> deadCMOs = [relationshipMutableSet mutableCopy];

                for (FOSCachedManagedObject *nextDeadCMO in deadCMOs) {
                    if (nextDeadCMO.hasBeenUploadedToServer) {
                        if (nextDeadCMO.isDirty) {
                            FOSLogDebug(@"Deleting a dirty object: %@ (%@)",
                                        NSStringFromClass([nextDeadCMO class]),
                                        nextDeadCMO.jsonIdValue);
                        }

                        // Tell the underlying delete code not to attempt to remove this obj from
                        // the server, as it's already been done.
                        nextDeadCMO.skipServerDelete = YES;

                        [relationshipMutableSet removeObject:nextDeadCMO];
                        [nextDeadCMO.managedObjectContext deleteObject:nextDeadCMO];
                    }
                }
            }
        }
        else {
            // Gather the, now realized, entities
            NSMutableSet *newEntries = [NSMutableSet setWithCapacity:_childRetrieveCMOOps.count];
            for (FOSRetrieveCMOOperation *nextOp in _childRetrieveCMOOps) {

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

#if !defined(CONFIGURATION_Debug) && !defined(NS_BLOCK_ASSERTIONS)
                        Class destClass = NSClassFromString(_relationship.destinationEntity.managedObjectClassName);

                        NSAssert([nextCMO isKindOfClass:destClass], @"Received type %@, expected %@.",
                                 NSStringFromClass([nextCMO class]),
                                 _relationship.destinationEntity.managedObjectClassName);
#endif
                        // Set the forward relationship
                        [newEntries addObject:nextCMO];

                        // Set Inverse relationship
                        NSRelationshipDescription *inverse = _relationship.inverseRelationship;
                        if (!inverse.isToMany) {

                            // It is possible that they 'force resolved' the owner by setting
                            // the owner's relationship 'jsonRelationshipForcePull == Always'.
                            // This might be done if the query for these objects is broader than
                            // just the simple owner as reolved by this protocol.
                            if (!inverse.jsonRelationshipForcePull) {
                                [nextCMO setValue:owner forKey:inverse.name];
                            }
                            else {
                                [newEntries removeObject:nextCMO];
                            }
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
                            FOSLogWarning(@"IGNORING ERROR: during to-many fetch operation %@ to entity %@: %@",
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
    for (FOSRetrieveCMOOperation *nextOp in _childRetrieveCMOOps) {
        [nextOp finishOrdering];
    }
}

- (NSError *)finishValidation {
    NSError *result = nil;

    for (FOSRetrieveCMOOperation *nextOp in _childRetrieveCMOOps) {
        result = [nextOp finishValidation];
    }

    return result;
}

- (void)finishCleanup:(BOOL)forceDestroy {
    for (FOSRetrieveCMOOperation *nextOp in _childRetrieveCMOOps) {
        [nextOp finishCleanup:forceDestroy || (self.error != nil)];
    }
}

#pragma mark - Overrides

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

    if (!_mergeResults) {
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
}

- (NSSet *)_jsonBindingsForRelationship:(NSRelationshipDescription *)relDesc
                             leafEntities:(NSSet *)leafEntities
                                 bindings:(NSDictionary *)bindings
                              ownerJsonId:(FOSJsonId)ownerJsonId {
    NSParameterAssert(relDesc != nil);
    NSParameterAssert(leafEntities != nil);
    NSParameterAssert(ownerJsonId != nil);

    NSMutableSet *result = nil;

    for (NSEntityDescription *nextLeafEntity in leafEntities) {
        // Let's see if we can find a parent-supplied set of values
        NSArray *json = [self _bindToJSONInBindings:bindings
                                     forRelaionship:relDesc
                                         destEntity:nextLeafEntity
                                     andOwnerJsonId:ownerJsonId];

        if (json != nil) {
            result = [NSMutableSet setWithCapacity:json.count];

            if (json.count > 0) {
                NSDictionary *nextEntry = @{
                                            @"DestEntity" : nextLeafEntity,
                                            @"JSON" : json
                                          };

                [result addObject:nextEntry];
            }
        }
    }

    return result;
}

- (NSSet *)_webServiceRequestsForRelationship:(NSRelationshipDescription *)relDesc
                                 leafEntities:(NSSet *)leafEntities
                                     bindings:(NSDictionary *)bindings
                                  ownerJsonId:(FOSJsonId)ownerJsonId
                                     dslQuery:(NSString *)dslQuery
                                        error:(NSError **)error {
    NSParameterAssert(relDesc != nil);
    NSParameterAssert(leafEntities != nil);
    NSParameterAssert(ownerJsonId != nil);

    NSMutableSet *result = nil;
    id<FOSRESTServiceAdapter> adapter = self.restConfig.restServiceAdapter;
    NSError *localError = nil;

    for (NSEntityDescription *nextLeafEntity in leafEntities) {
        FOSURLBinding *urlBinding =
            [adapter urlBindingForLifecyclePhase:FOSLifecyclePhaseRetrieveServerRecordRelationship
                               forLifecycleStyle:nil
                                 forRelationship:relDesc
                                       forEntity:nextLeafEntity];

        if (urlBinding != nil) {
            NSURLRequest *urlRequest =
                [urlBinding urlRequestServerRecordsOfRelationship:relDesc
                                             forDestinationEntity:nextLeafEntity
                                                      withOwnerId:ownerJsonId
                                                     withDSLQuery:dslQuery
                                                            error:&localError];

            if (localError == nil) {
                FOSWebServiceRequest *request = [FOSWebServiceRequest requestWithURLRequest:urlRequest
                                                                              forURLBinding:urlBinding];
                NSDictionary *requestEntry = @{
                                               @"DestEntity" : nextLeafEntity,
                                               @"Request" : request
                                               };

                if (result == nil) {
                    result = [NSMutableSet setWithObject:requestEntry];
                }
                else {
                    [result addObject:requestEntry];
                }
            }
        }

        if (localError != nil) {
            break;
        }
    }

    if (localError != nil) {
        if (error != nil) { *error = localError; }

        result = nil;
    }

    return result;
}

- (NSArray *)_bindToJSONInBindings:(NSDictionary *)bindings
                    forRelaionship:(NSRelationshipDescription *)relDesc
                        destEntity:(NSEntityDescription *)destEntity
                    andOwnerJsonId:(FOSJsonId)ownerJsonId {
    NSError *localError = nil;
    NSArray *results = nil;

    // Can we find the json in bindings?
    id<NSObject> originalJson = bindings[@"originalJsonResult"];
    if (originalJson != nil) {
        FOSRelationshipBinding *relBinding = nil;

        NSDictionary *context = @{ @"ENTITY" : destEntity, @"RELDESC" : relDesc };

        for (FOSRelationshipBinding *nextRelBinding in _parentCMOBinding.relationshipBindings) {
            if ([nextRelBinding.entityMatcher itemIsIncluded:destEntity.name
                                                     context:context]) {
                relBinding = nextRelBinding;
                break;
            }
        }

        id<NSObject> unwrappedJson = [relBinding unwrapJSON:originalJson
                                                    context:context
                                                      error:&localError];


        // We expect an array of possibilities here. We'll look into
        // the array and attempt to match jsonId.
        if (unwrappedJson != nil && [unwrappedJson isKindOfClass:[NSArray class]]) {

            // TODO : Could issue a warning...
            if (relBinding != nil) {
                id<FOSExpression> jsonKeyExpression = relBinding.jsonIdBindingExpression;
                NSString *jsonIdKeyPath = [jsonKeyExpression evaluateWithContext:context
                                                                           error:&localError];
                if (localError == nil && jsonIdKeyPath.length > 0) {

                    NSPredicate *pred = [NSPredicate predicateWithFormat:@"%K = %@",
                                         jsonIdKeyPath, ownerJsonId];

                    results = [(NSArray *)unwrappedJson filteredArrayUsingPredicate:pred];

                    // Just incase something changes in foundation later...
                    if (results == nil) {
                        results = @[];
                    }
                }
            }

            // For now we'll ignore any errors as this is just fast tracking...
            localError = nil;
        }
    }
    
    return results;
}

- (void)_queueRequestsForRelationship:(NSRelationshipDescription *)relDesc
                          ownerJsonId:(FOSJsonId)ownerJsonId
                             bindings:(NSMutableDictionary *)bindings
                             requests:(NSSet *)requests {

    __block FOSRetrieveToManyRelationshipOperation *blockSelf = self;

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
                if (self.relationship.minCount > 0) {
                    isValid = fragCount >= blockSelf.relationship.minCount;
                }

                if (isValid && self.relationship.maxCount > 0) {
                    NSUInteger fragCount = jsonFragments.count;

                    isValid = fragCount <= blockSelf.relationship.maxCount;
                }

                if (isValid && fragCount > 0) {
                    blockSelf->_childRetrieveCMOOps = [NSMutableSet setWithCapacity:jsonFragments.count];

                    id<FOSRESTServiceAdapter> adapter = self.restConfig.restServiceAdapter;
                    FOSURLBinding *urlBinding =
                    [adapter urlBindingForLifecyclePhase:FOSLifecyclePhaseRetrieveServerRecordRelationship
                                          forLifecycleStyle:nil
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
                        [newBindings addEntriesFromDictionary:bindings];

                        // Also store the 'originalJson' in the bindings if we're the top-level
                        // data pull as it can have related-CMO data as well.
                        id ojr = webServiceRequest.originalJsonResult;

                        // NOTE: Right now we're not merging with parent results as it could
                        //       prove to be difficult as there might be a mismatch of
                        //       NSArray & NSDictionary types between the parent and here.
                        //
                        //       If it proves that we need to maintain state from all levels,
                        //       we'll probably have to invent a more formal scoping
                        //       mechanism for bindings (which is a horrid name anyway).
                        if ([ojr respondsToSelector:@selector(count)] && [ojr count] > 0) {
                            newBindings[@"originalJsonResult"] = webServiceRequest.originalJsonResult;
                        }

                        [self _processJSONFragmentsForRelationships:relDesc
                                                           bindings:newBindings
                                                         destEntity:destEntity
                                                      jsonFragments:jsonFragments];
                    }
                }
                else if (!isValid) {
                    NSString *msg = [NSString stringWithFormat:@"Relationship %@ of entity %@(%@) does not contain the schema required number of destination entities.  Found %lu entities, but the required MIN was %lu and the required MAX was %lu.",
                                     blockSelf.relationship.name,
                                     blockSelf.relationship.entity.name,
                                     ownerJsonId,
                                     (unsigned long)jsonFragments.count,
                                     (unsigned long)blockSelf.relationship.minCount,
                                     (unsigned long)blockSelf.relationship.maxCount];

                    blockSelf->_error = [NSError errorWithMessage:msg];
                }
            }
        }];

        [bgOp addDependency:webServiceRequest];
        [self addDependency:bgOp];
    }
}

- (void)_processJSONFragmentsForRelationships:(NSRelationshipDescription *)relDesc
                                     bindings:(NSMutableDictionary *)bindings
                                   destEntity:(NSEntityDescription *)destEntity
                                jsonFragments:(NSArray *)jsonFragments {
    NSParameterAssert(relDesc != nil);
    NSParameterAssert(destEntity != nil);
    NSParameterAssert(jsonFragments != nil);
    NSParameterAssert(jsonFragments.count > 0);

    _childRetrieveCMOOps = [NSMutableSet setWithCapacity:jsonFragments.count];

    for (id<NSObject> nextFragment in jsonFragments) {
        // NOTE: Here we use the 'related' form of the constructor to inihibit save
        //       of the context until the entire graph is loaded.  This ensures that
        //       the required relationships are realized.

        FOSRetrieveCMOOperation *nextFetchOp =
            [FOSRetrieveCMOOperation fetchRelatedManagedObjectForEntity:destEntity
                                                         ofRelationship:relDesc
                                                               withJson:nextFragment
                                                           withBindings:bindings];

        [_childRetrieveCMOOps addObject:nextFetchOp];

        [self addDependency:nextFetchOp];
    }

    // Requeue self adding further dependencies
    if (self.isQueued) {
        [self.restConfig.cacheManager reQueueOperation:self];
    }
}

@end
