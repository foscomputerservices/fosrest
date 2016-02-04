//
//  FOSRetrieveCMOOperation.m
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

#import "FOSRetrieveCMOOperation+FOS_Internal.h"
#import "FOSREST_Internal.h"

@implementation FOSRetrieveCMOOperation {
    BOOL _ready;
    NSArray *_toOneOps;
    NSArray *_toManyOps;
    NSError *_validationError;
    BOOL _finishedBinding;
    BOOL _finishedOrdering;
    BOOL _finishedValidation;
    BOOL _finishedCleanup;
    BOOL _createdFaults;
    BOOL _fastTracked;
    NSMutableDictionary *_bindings;
    FOSURLBinding *_urlBinding;
    FOSItemMatcher *_relationshipsToPull;
    NSRelationshipDescription *_relDesc;
    NSManagedObjectID *_managedObjectID;
}

+ (instancetype)retrieveCMOUsingDataOperation:(FOSOperation<FOSRetrieveCMODataOperationProtocol> *)fetchOp
                            forLifecyclePhase:(FOSLifecyclePhase)lifecyclePhase
                            forLifecycleStyle:(NSString *)lifecycleStyle {
    NSMutableDictionary *bindings = [NSMutableDictionary dictionaryWithCapacity:100];
    return [[self alloc] initWithDataOperation:fetchOp
                               isTopLevelFetch:YES
                             forLifecyclePhase:lifecyclePhase
                             forLifecycleStyle:lifecycleStyle
                                  withBindings:bindings];
}

+ (instancetype)retrieveCMOForEntity:(NSEntityDescription *)entity
                              withId:(FOSJsonId)jsonId {
    NSMutableDictionary *bindings = [self primeBindingsForEntity:entity
                                                     withJsonIDs:@[ jsonId ]];

    FOSRetrieveCMOOperation *result = [[self alloc] initForEntity:entity
                                                   ofRelationship:nil
                                                           withId:jsonId
                                                  isTopLevelFetch:YES
                                                forLifecyclePhase:FOSLifecyclePhaseRetrieveServerRecord
                                                forLifecycleStyle:nil
                                                     withBindings:bindings];

    return result;
}

+ (instancetype)retrieveCMOForEntity:(NSEntityDescription *)entity
                            withJson:(NSDictionary *)json
                        withBindings:(NSMutableDictionary *)bindings {
    NSParameterAssert(bindings != nil);

    FOSRetrieveCMOOperation *result = [[self alloc] initForEntity:entity
                                                   ofRelationship:nil
                                                         withJson:json
                                                  isTopLevelFetch:YES
                                                forLifecyclePhase:FOSLifecyclePhaseRetrieveServerRecord
                                                forLifecycleStyle:nil
                                                     withBindings:bindings];

    return result;
}

+ (NSMutableDictionary *)primeBindingsForEntity:(NSEntityDescription *)entity
                                    withJsonIDs:(NSArray *)jsonIds {
    NSParameterAssert(entity != nil);
    NSParameterAssert(jsonIds != nil);

    // Do a top-level pull for these entities from the database to reduce the number
    // of incremental DB hits as the entities are processed by FOSFetchEntityOperation
    Class class = NSClassFromString(entity.managedObjectClassName);
    NSSet *existingEntities = [class fetchWithIds:jsonIds];
    NSMutableDictionary *bindings = [NSMutableDictionary dictionaryWithCapacity:jsonIds.count];

    // Fill the bindings array with null entries telling the resolution mechanism
    // that we've already tried to resolve this jsonId.
    for (FOSJsonId nextId in jsonIds) {
        [self _setBindingValue:[NSNull null] forKey:nextId enity:entity inBindings:bindings];
    }

    // Replace the null entries with those that we've found
    for (FOSCachedManagedObject *nextCMO in existingEntities) {
        NSManagedObjectID *nextObjID = nextCMO.objectID;
        FOSJsonId jsonId = nextCMO.jsonIdValue;

        [self _setBindingValue:nextObjID forKey:jsonId enity:nextCMO.entity inBindings:bindings];
    }

    return bindings;
}

+ (NSManagedObjectID *)cmoForEntity:(NSEntityDescription *)entity
                         withJsonId:(FOSJsonId)jsonId
                       fromBindings:(NSMutableDictionary *)bindings
             inManagedObjectContext:(NSManagedObjectContext *)moc {
    NSParameterAssert(entity != nil);
    NSParameterAssert(jsonId != nil);
    NSParameterAssert(bindings != nil);

    __block NSManagedObjectID *result = nil;

    id bindingVal = [self _bindingValueForKey:jsonId entity:entity inBindings:bindings];

    if ([bindingVal isKindOfClass:[NSManagedObjectID class]]) {
        result = (NSManagedObjectID *)bindingVal;
    }
    else if (bindingVal == nil || [bindingVal isKindOfClass:[NSNull class]]) {

        [moc performBlockAndWait:^{
            Class class = NSClassFromString(entity.managedObjectClassName);
            FOSCachedManagedObject *cmo = [class fetchWithId:jsonId inManagedObjectContext:moc];
            result = cmo.objectID;

            if (result != nil) {
                bindings[jsonId] = result;
            }
        }];
    }

    // This is *extrmely* expensive, so don't let it out into any other build types
#if defined(DEBUG) && !defined(NS_BLOCK_ASSERTIONS)
    {
        Class class = NSClassFromString(entity.managedObjectClassName);

        // See: http://fosmain.foscomputerservices.com:8080/browse/FF-12
        if (![class canHaveDuplicateJsonIds]) {
            NSManagedObjectID *id1 = result;
            NSManagedObjectID *id2 = [[NSClassFromString(entity.managedObjectClassName) fetchWithId:jsonId] objectID];

            NSAssert(id1 == id2 || [id1 isEqual:id2], @"Something's really out of whack!");
        }
    }
#endif

    return result;
}

- (NSManagedObjectID *)cmoForEntity:(NSEntityDescription *)entity
                                withJson:(id<NSObject>)json
                       fromBindings:(NSMutableDictionary *)bindings
             inManagedObjectContext:(NSManagedObjectContext *)moc {

    NSParameterAssert(entity != nil);
    NSParameterAssert(json != nil);

    NSManagedObjectID *result = nil;

    // Let's try just using the FOSJsonId 1st
    NSError *localError = nil;
    FOSJsonId jsonId = [_urlBinding.cmoBinding jsonIdFromJSON:json
                                                    forEntity:entity
                                                        error:&localError];

    if (localError == nil) {
        result = [[self class] cmoForEntity:entity
                                 withJsonId:jsonId
                               fromBindings:bindings
                     inManagedObjectContext:moc];

        // We didn't find using the jsonId, is there a local object that has all of the
        // same values for all other fields other than the id?  This can happen if
        // the object got pushed to the server, but for some reason the jsonId didn't
        // get recorded locally.  https://datamtd.atlassian.net/browse/VBM-719
        if (result == nil && entity.jsonCanValueMatch) {

            NSMutableString *matchPredStr = [NSMutableString stringWithCapacity:512];
            NSMutableArray *predVals = [NSMutableArray arrayWithCapacity:10];
            NSDictionary *context = @{ @"ENTITY" : entity };

            FOSAttributeBinding *identBinding = _urlBinding.cmoBinding.identityBinding;
            id<FOSExpression> idPropExpr = identBinding.cmoKeyPathExpression;

            NSString *idProp = [idPropExpr evaluateWithContext:context
                                                         error:&localError];

            if (localError == nil) {
                NSDictionary *jsonDict = (NSDictionary *)json;
                Class cmoClass = NSClassFromString(entity.managedObjectClassName);
                __block BOOL foundStringProp = NO;

                NSAssert([jsonDict isKindOfClass:[NSDictionary class]], @"It's not a dictionary???");

                for (NSAttributeDescription *attrDesc in entity.cmoAttributes) {

                    // Only match records that locally have no server identities attached
                    if ([attrDesc.name isEqualToString:idProp]) {
                        [matchPredStr appendFormat:@"(%@ == NULL || %@ == \"\")",
                         attrDesc.name, attrDesc.name];
                    }
                    else {
                        // Find the match value
                        id jsonValue = jsonDict[attrDesc.name];
                        if (jsonValue != nil && ![jsonValue isKindOfClass:[NSNull class]]) {

                            id svrValue = [cmoClass objectForAttribute:attrDesc forJsonValue:jsonValue];

                            [predVals addObject:svrValue];

                            if (matchPredStr.length > 0) {
                                [matchPredStr appendString:@" AND "];
                            }

                            [matchPredStr appendFormat:@"(%@ == %%@)", attrDesc.name];

                            foundStringProp =
                            foundStringProp ||
                            [svrValue isKindOfClass:[NSString class]];
                        }
                    }
                };

                if (foundStringProp && matchPredStr.length > 0) {
                    NSPredicate *pred = [NSPredicate predicateWithFormat:matchPredStr
                                                           argumentArray:predVals];

                    NSArray *matched = [cmoClass fetchWithPredicate:pred];

                    if (matched.count == 1) {
                        result = [(FOSCachedManagedObject *)matched.lastObject objectID];
                    }
                }
            }
        }
    }

    if (localError != nil) {
        _error = localError;
        result = nil;
    }

    return result;
}

// Designated Initializer
- (id)initAsTopLevelFetch:(BOOL)isTopLevelFetch
        forLifecyclePhase:(FOSLifecyclePhase)lifecyclePhase
        forLifecycleStyle:(NSString *)lifecycleStyle
                   entity:(NSEntityDescription *)entity
           ofRelationship:(NSRelationshipDescription *)relDesc
             withBindings:(NSMutableDictionary *)bindings {
    NSParameterAssert(entity != nil);
    NSParameterAssert(bindings != nil);

    if ((self = [super init]) != nil) {
        _isTopLevelFetch = isTopLevelFetch;
        _entity = entity;
        _bindings = bindings;
        _allowFastTrack = YES;
        _relDesc = relDesc;

        NSError *localError = nil;

        id<FOSRESTServiceAdapter> adapter = self.restConfig.restServiceAdapter;
        _urlBinding = [adapter urlBindingForLifecyclePhase:lifecyclePhase
                                         forLifecycleStyle:lifecycleStyle
                                           forRelationship:relDesc
                                                 forEntity:entity];

        if (_urlBinding == nil) {
            NSString *msgFmt = @"URL_BINDING missing for lifecycle %@ with lifecycle style '%@' of Entity '%@'%@";
            NSString *msg = [NSString stringWithFormat:msgFmt,
                             [FOSURLBinding stringForLifecycle:lifecyclePhase],
                             lifecycleStyle,
                             entity.name,
                             relDesc == nil
                             ? @""
                                                      : [NSString stringWithFormat:@" for relationship '%@'", relDesc.name]
                             ];

            localError = [NSError errorWithMessage:msg];
        }

        _error = localError;
    }

    return self;
}

- (id)initWithDataOperation:(FOSOperation<FOSRetrieveCMODataOperationProtocol> *)fetchDataOp
            isTopLevelFetch:(BOOL)isTopLevelFetch
          forLifecyclePhase:(FOSLifecyclePhase)lifecyclePhase
          forLifecycleStyle:(NSString *)lifecycleStyle
               withBindings:(NSMutableDictionary *)bindings {
    NSParameterAssert(fetchDataOp != nil);
    NSParameterAssert(bindings != nil);

    if ((self = [self initForEntity:fetchDataOp.entity
                     ofRelationship:nil
                             withId:nil
                    isTopLevelFetch:isTopLevelFetch
                  forLifecyclePhase:lifecyclePhase
                  forLifecycleStyle:lifecycleStyle
                       withBindings:bindings]) != nil) {
        __block FOSRetrieveCMOOperation *blockSelf = self;

        NSError *localError = nil;

        if ([fetchDataOp respondsToSelector:@selector(relationshipsToPull)]) {
            // It's only possible to update 'owned' relationships

            _relationshipsToPull = fetchDataOp.relationshipsToPull;
            NSSet *filteredRels = [self _filterRelationships:self.entity.cmoToManyRelationships];

            for (NSRelationshipDescription *relDesc in filteredRels) {
                if (!relDesc.isOwnershipRelationship) {
                    NSString *msgFmt = @"Invalid request to refresh relationship '%@' on entity '%@'.  Only owned relationships can be refreshed.";
                    NSString *msg = [NSString stringWithFormat:msgFmt,
                                     relDesc.name, fetchDataOp.entity.name];

                    localError = [NSError errorWithDomain:@"FOSREST" andMessage:msg];
                    break;
                }
            }
        }

        if (localError == nil) {

            // Once we've retrieved our jsonId with the fetchDataOp, then we need to update our
            // local information accordingly before running our main() method.
            FOSBackgroundOperation *bgOp = [FOSBackgroundOperation backgroundOperationWithRequest:^(BOOL isCancelled, NSError *error) {
                if (fetchDataOp.error == nil) {
                    NSError *localError = nil;

                    if (fetchDataOp.jsonId == nil) {
                        NSString *msgFmt = @"The CMO data operation returned a nil jsonId while retrieving entity %@";
                        NSString *msg = [NSString stringWithFormat:msgFmt, blockSelf.entity.name];

                        localError = [NSError errorWithMessage:msg];
                    }
                    if (localError == nil && fetchDataOp.jsonResult == nil) {
                        NSString *msgFmt = @"The CMO data operation returned a nil jsonResult while retrieving entity %@";
                        NSString *msg = [NSString stringWithFormat:msgFmt, blockSelf.entity.name];

                        localError = [NSError errorWithMessage:msg];
                    }

                    if (localError == nil &&
                        ![[blockSelf class] _checkItemDeleted:fetchDataOp.jsonId
                                                    forEntity:blockSelf->_entity
                                                        error:&localError]) {

                            // We do NOT call the jsonId property setter here, just save the value.
                            // This is because we already have the json in fdo.jsonResult.  If we
                            // called the jsonId setter here, it would automatically try to retrieve
                            // the json again.
                            blockSelf->_jsonId = fetchDataOp.jsonId;
                            blockSelf.dslQuery = fetchDataOp.dslQuery;
                            blockSelf.mergeResults = fetchDataOp.mergeResults;
                            blockSelf.json = fetchDataOp.jsonResult;

                            // Also store the 'originalJson' in the bindings if we're the top-level
                            // data pull as it can have related-CMO data as well.
                            if (fetchDataOp.originalJsonResult != nil) {
                                bindings[@"originalJsonResult"] = fetchDataOp.originalJsonResult;
                            }
                        }

                    if (localError != nil) {
                        blockSelf->_error = localError;
                        [blockSelf _updateReady];
                    }
                }
                else {
                    [blockSelf _updateReady];
                }
            }];

            [bgOp addDependency:fetchDataOp];
            [self addDependency:bgOp];
        }

        if (localError != nil) {
            _error = localError;
            [self _updateReady];
        }
    }

    return self;
}

- (id)initForEntity:(NSEntityDescription *)entity
     ofRelationship:(NSRelationshipDescription *)relDesc
             withId:(FOSJsonId)jsonId
    isTopLevelFetch:(BOOL)isTopLevelFetch
  forLifecyclePhase:(FOSLifecyclePhase)lifecyclePhase
  forLifecycleStyle:(NSString *)lifecycleStyle
       withBindings:(NSMutableDictionary *)bindings {
    NSParameterAssert(entity != nil);
    NSParameterAssert(bindings != nil);

    if ((self = [self initAsTopLevelFetch:isTopLevelFetch
                        forLifecyclePhase:lifecyclePhase
                        forLifecycleStyle:lifecycleStyle
                                   entity:entity
                           ofRelationship:relDesc
                             withBindings:bindings]) != nil) {
        if (jsonId != nil) {
            self.jsonId = jsonId;
        }
    }

    return self;
}

- (id)initForEntity:(NSEntityDescription *)entity
     ofRelationship:(NSRelationshipDescription *)relDesc
           withJson:(NSDictionary *)json
    isTopLevelFetch:(BOOL)isTopLevelFetch
  forLifecyclePhase:(FOSLifecyclePhase)lifecyclePhase
  forLifecycleStyle:(NSString *)lifecycleStyle
       withBindings:(NSMutableDictionary *)bindings {
    NSParameterAssert(json != nil);
    NSParameterAssert(entity != nil);
    NSParameterAssert(bindings != nil);

    if ((self = [self initAsTopLevelFetch:isTopLevelFetch
                        forLifecyclePhase:lifecyclePhase
                        forLifecycleStyle:lifecycleStyle
                                   entity:entity
                           ofRelationship:relDesc
                             withBindings:bindings]) != nil) {

        if (self.error == nil) {
            NSError *localError = nil;

            _jsonId = [_urlBinding.cmoBinding jsonIdFromJSON:json
                                                   forEntity:entity
                                                       error:&localError];

            if (localError == nil) {
                if (_jsonId != nil) {

                    // Can we fast-track?
                    // NOTE: Cannot check property _allowFastTrack here as it's a user-settable
                    //       property that can be set after init.  Thus, we just set up the possibility
                    //       here and check later.
                    //
                    //       We allow _allowFastTrack to be delay-set as FOSFetchEntityOperation instances
                    //       are created by a variety of mechanisms and passed back to the user.  It would
                    //       be impractical to flow the value through all API calls into init.

                    // We don't 'respect previous' as we might have been handed an 'originalJson'
                    // packet from a top-level pull in which the bindings will not have
                    // this entry.
                    _managedObjectID = [self cmoForEntity:_entity
                                                 withJson:json
                                             fromBindings:_bindings
                                   inManagedObjectContext:self.managedObjectContext];
                    if (_managedObjectID != nil) {

                        [[self class] _setBindingValue:_managedObjectID
                                                forKey:_jsonId enity:entity
                                            inBindings:_bindings];
                    }

                    self.json = json;
                }
                else {
                    NSString *msgFmt = @"Unable to bind identity using URL_BINDING for lifecycle %@ for entity '%@' from JSON: %@";
                    NSString *msg = [NSString stringWithFormat:msgFmt,
                                     [FOSURLBinding stringForLifecycle:lifecyclePhase],
                                     entity.name,
                                     json.description];

                    localError = [NSError errorWithMessage:msg forAtom:_urlBinding];
                }
            }

            _error = localError;
        }
    }

    return self;
}

#pragma mark - Property Overrides

- (NSError *)error {
    NSError *result = [super error];

    // FOSFetchEntityOperation_ItemDeletedLocally is a cancellation, not an error. Don't
    // let it escape.
    if (result != nil && [result.domain isEqualToString:@"FOSFetchEntityOperation_ItemDeletedLocally"]) {
        result = nil;
    }

    return result;
}

- (BOOL)isCancelled {
    BOOL result = [super isCancelled];

    if (!result && _error != nil) {
        result = [_error.domain isEqualToString:@"FOSFetchEntityOperation_ItemDeletedLocally"];
    }

    return result;
}

- (void)setJsonId:(FOSJsonId)jsonId {
    NSParameterAssert(jsonId != nil && ![jsonId isKindOfClass:[NSNull class]]);

    NSError *localError = nil;

    _jsonId = jsonId;

    if (!self.isCancelled && self.error == nil) {

        __block FOSRetrieveCMOOperation *blockSelf = self;

        // Can we find the JSON in _bindings???
        BOOL foundJson = [self _bindToJSONInBindings];

        // No need to pull the jsonData if we already have it
        if (!foundJson) {
            NSURLRequest *urlRequest = nil;

            if (_relDesc == nil) {
                urlRequest = [_urlBinding urlRequestServerRecordOfType:self.entity
                                                            withJsonId:jsonId
                                                          withDSLQuery:self.dslQuery
                                                                 error:&localError];
            }
            else {
                urlRequest = [_urlBinding urlRequestServerRecordsOfRelationship:_relDesc
                                                           forDestinationEntity:self.entity
                                                                    withOwnerId:jsonId
                                                                   withDSLQuery:self.dslQuery
                                                                          error:&localError];
            }

            // Fetch the data for entity with the given jsonId from the server
            FOSWebServiceRequest *jsonDataRequest = nil;

            if (localError == nil) {

                jsonDataRequest = [FOSWebServiceRequest requestWithURLRequest:urlRequest
                                                                forURLBinding:_urlBinding];

                jsonDataRequest.willProcessHandler = /* (NSManagedObjectID *)(^)() */ ^{

                    NSManagedObjectID *result = nil;

                    // Can we FAST-TRACK to an existing object and skip pulling down this instance?
                    if (blockSelf->_allowFastTrack) {
                        result = blockSelf->_managedObjectID;

                        if (result == nil) {
                            NSManagedObjectID *cmoObjID = [[self class] cmoForEntity:blockSelf->_entity
                                                                          withJsonId:jsonId
                                                                        fromBindings:blockSelf->_bindings inManagedObjectContext:blockSelf.managedObjectContext];

                            if (cmoObjID != nil) {
                                result = cmoObjID;

                                [[blockSelf class] _setBindingValue:result
                                                             forKey:jsonId
                                                              enity:blockSelf->_entity
                                                         inBindings:blockSelf->_bindings];
                            }
                        }
                    }

                    blockSelf->_fastTracked = (result != nil);

                    return result;
                };
            }

            // Chain in an op that will add new dependencies to ourself after
            // they're determined from resolving the new FOSCachedManagedObject.  This
            // effectively creates a recursive structure for resolution.  Of course,
            // there hadn't better be any loops.
            FOSBackgroundOperation *queueSubOps = [FOSBackgroundOperation backgroundOperationWithRequest:^(BOOL isCancelled, NSError *error) {
                if (jsonDataRequest != nil &&
                    !jsonDataRequest.isCancelled &&
                    jsonDataRequest.error == nil) {

                    // We got the object early! Woohoo!
                    if ([jsonDataRequest.jsonResult isKindOfClass:[NSManagedObjectID class]]) {
                        blockSelf->_managedObjectID = (NSManagedObjectID *)jsonDataRequest.jsonResult;

                        FOSCachedManagedObject *cmo = (FOSCachedManagedObject *)[self.managedObjectContext objectWithID:blockSelf->_managedObjectID];

                        NSAssert([blockSelf->_jsonId isEqual:(NSString *)cmo.jsonIdValue],
                                 @"Ids aren't the same?");

                        blockSelf.json = cmo.originalJson;

                        FOSLogDebug(@"FOSFETCHENTITY - FASTRACK: %@ (%@)", blockSelf->_entity.name, blockSelf->_jsonId);
                    }
                    else if (jsonDataRequest.jsonResult == nil) {
                        NSString *msgFmt = NSLocalizedString(@"Received no data in response to the query '%@' for entity '%@'.", @"");

                        NSString *msg = [NSString stringWithFormat:msgFmt,
                                         jsonDataRequest.endPoint, blockSelf->_entity.name];
                        blockSelf->_error = [NSError errorWithMessage:msg];

                        [blockSelf _updateReady];
                    }
                    else {
                        // This will call _updateReady
                        blockSelf.json = (NSDictionary *)jsonDataRequest.jsonResult;
                    }
                }
                else {
                    [blockSelf _updateReady];
                }
            }];

            if (jsonDataRequest != nil) {
                [queueSubOps addDependency:jsonDataRequest];
            }

            [self addDependency:queueSubOps];
        }

        // If we've already been queued, then we need to queue these new ops
        if (self.isQueued) {
            NSAssert(!self.isFinished, @"We're already done executing and have new deps???");
            NSAssert(!self.isExecuting, @"We're already executing and have new deps???");

            // Requeue ourself so that we can find the begin op
            [self.restConfig.cacheManager reQueueOperation:self];
        }
    }

    if (localError != nil) {
        _error = localError;
        [self _updateReady];
    }
}

- (void)setJson:(id<NSObject>)json {
    _json = json;

    NSError *localError = nil;

    // We resolve references even if we have fast-tracked as we might be refreshing
    // those relationships and some might be marked as pull = 'Always'.
    if (!self.isCancelled && self.error == nil) {

        // Let's see if there's an updated jsonId in the given JSON
        FOSJsonId jsonId = [_urlBinding.cmoBinding jsonIdFromJSON:json
                                                        forEntity:self.entity
                                                            error:&localError];

        if (localError == nil) {
            if (jsonId != nil) {
                _jsonId = jsonId;
            }

            // Now that we have the json, it's possible that we need to map an abstract entity
            // to the final entity
            if (self.entity.jsonUseAbstract) {
                if ([self.restAdapter respondsToSelector:@selector(subtypeFromBase:givenJSON:)]) {
                    NSEntityDescription *finalEntity = [self.restAdapter subtypeFromBase:self.entity givenJSON:json];

                    if (finalEntity != nil) {
                        _entity = finalEntity;
                    }
                    else {
                        FOSLogCritical(@"Entity '%@' is marked as 'jsonUseAbstract', however the service adapter returned nill for subtypeFromBase:givenJSON: with the following JSON: %@", self.entity.name, json);
                    }
                }
                else if (self.entity.isAbstract) {
                    FOSLogCritical(@"Entity '%@' is marked as 'jsonUseAbstract' and the entity isAbstract == YES, however the service adapter does not implement 'subtypeFromBase:givenJSON:'.  The abstract entity will be used, but this is almost certainly wrong and will cause subsequent failures.", self.entity.name);
                }
            }

            // Previously it was that that if we fast-tracked, there's no reason to resolve the references.
            // However, this is not the case.  When we're refreshing relationships where the receiver
            // has relationships marked jsonRelationshipForcePull == Always, we want to ensure
            // that the entire graph is traversed updating across these boundaries.  Thus, even
            // if the object is in the system, we want to ensure that it's force-pull dependencies
            // are up-to-date.
            [self _resolveReferences];

            // Queue subops, if we're already queued
            if (self.isQueued) {
                NSAssert(!self.isFinished, @"We're already done executing and have new deps???");
                NSAssert(!self.isExecuting, @"We're already executing and have new deps???");

                // We re-queue ourself so that we can find the begin op
                [self.restConfig.cacheManager reQueueOperation:self];
            }
        }
    }

    if (localError != nil) {
        _error = localError;
    }

    [self _updateReady];
}


- (NSManagedObjectID *)managedObjectID {
    NSManagedObjectID *result = nil;

    if (_managedObjectID != nil && self.error == nil) {
        result = _managedObjectID;
    }

    return result;
}

#pragma mark - Binding Methods

- (void)finishBinding {
    NSAssert(_managedObjectID != nil, @"Haven't finished loading the object yet???");

    _finishedErrorPass = NO;

    // In graph resolution cycles, we might get called more than once, so cut off more than
    // the 1st attempt.
    if (!_finishedBinding && !self.isCancelled) {

        // Set at the beginning to skip cycles that might be triggered below
        _finishedBinding = YES;

        NSManagedObjectID *ownerID = self.managedObjectID;
        BOOL encounteredErrors = NO;

        // Bind the to-one relationships
        for (FOSRetrieveToOneRelationshipOperation *nextToOneOp in _toOneOps) {
            [nextToOneOp bindToOwner:ownerID];

            encounteredErrors = (nextToOneOp.error != nil);
            if (encounteredErrors) {
                break;
            }
        }

        if (!encounteredErrors) {
            // Check each of the toOne optional relationships to make sure that the destination
            // hasn't been deleted.

            __block FOSRetrieveCMOOperation *blockSelf = self;
            [self.managedObjectContext performBlockAndWait:^{
                FOSCachedManagedObject *owner = [blockSelf.managedObjectContext objectWithID:ownerID];

                for (NSRelationshipDescription *relDesc in _entity.cmoRelationships) {
                    if (!relDesc.isToMany && relDesc.isOptional) {

                        NSError *localError = nil;
                        FOSCMOBinding *cmoBinding = _urlBinding.cmoBinding;
                        FOSJsonId jsonRelId = [cmoBinding jsonIdFromJSON:_json
                                                               forEntity:_entity
                                                                   error:&localError];

                        if (localError == nil) {
                            if (jsonRelId == nil) {
                                [owner setValue:nil forKey:relDesc.name];
                            }
                        }
                        else {
                            _error = localError;
                        }
                    }

                    if (_error != nil) {
                        [blockSelf _updateReady];
                        break;
                    }
                };
            }];

            // Bind the to-many relationships
            for (FOSRetrieveToManyRelationshipOperation *nextToManyOp in _toManyOps) {
                [nextToManyOp bindToOwner:ownerID];

                encounteredErrors = (nextToManyOp.error != nil);
                if (encounteredErrors) {
                    break;
                }
            }
        }
    }
}

- (void)finishOrdering {

    _finishedErrorPass = NO;

    if (!_finishedOrdering && !self.isCancelled) {
        _finishedOrdering = YES;

        BOOL encounteredErrors = (self.error != nil);

        if (!encounteredErrors) {
            // Traverse the owned hierarchy
            for (FOSRetrieveToManyRelationshipOperation *nextToManyOp in _toManyOps) {
                [nextToManyOp finishOrdering];

                encounteredErrors = (nextToManyOp.error != nil);
                if (encounteredErrors) {
                    break;
                }
            }

            if (!encounteredErrors) {
                // Fix up any graph linked ordered relationships

                NSManagedObjectID *ownerID = self.managedObjectID;
                NSManagedObjectContext *moc = self.managedObjectContext;

                [moc performBlockAndWait:^{
                    FOSCachedManagedObject *owner = [moc objectWithID:ownerID];

                    for (NSRelationshipDescription *relDesc in _entity.cmoRelationships) {
                        if (relDesc.isOrdered && !relDesc.isOwnershipRelationship) {
                            NSAssert(owner != nil, @"Unable to locate owner object!");

                            BOOL ownerWasDirty = owner.isDirty;

                            NSMutableOrderedSet *mutableOrderedSet =
                                [owner mutableOrderedSetValueForKey:relDesc.name];

                            NSString *orderProp = relDesc.jsonOrderProp;
                            NSArray *sortKeys = [orderProp componentsSeparatedByString:@","];
                            NSMutableArray *sortDescs = [NSMutableArray arrayWithCapacity:sortKeys.count];

                            for (NSString *nextSortKey in sortKeys) {
                                NSSortDescriptor *nextSortDesc = [NSSortDescriptor sortDescriptorWithKey:nextSortKey
                                                                                               ascending:YES];
                                [sortDescs addObject:nextSortDesc];
                            }

                            // Why NSMutableOrdered set doesn't implement sortUsingDescriptors is beyond me!
                            [mutableOrderedSet sortUsingComparator:^NSComparisonResult(id obj1, id obj2) {
                                NSComparisonResult compResult = NSOrderedSame;

                                for (NSSortDescriptor *nextSortDesc in sortDescs) {
                                    compResult = [nextSortDesc compareObject:obj1 toObject:obj2];
                                    if (compResult != NSOrderedSame) {
                                        break;
                                    }
                                }
                                
                                return compResult;
                            }];
                            
                            if (!ownerWasDirty) {
                                [owner markClean];
                            }
                        }
                    }
                }];
            }
        }
    }
}

- (NSError *)finishValidation {
    __block NSError *localError = nil;

    _finishedErrorPass = NO;

    // Our subtree should now be valid
    if (!_finishedValidation && !self.isCancelled) {
        _finishedValidation = YES;

        NSManagedObjectContext *moc = self.managedObjectContext;
        NSManagedObjectID *objID = self.managedObjectID;
        if (objID != nil) {
            [moc performBlockAndWait:^{
                [[moc objectWithID:objID] validateForInsert:&localError];
            }];
        }

        if (localError == nil) {
            for (FOSRetrieveToOneRelationshipOperation *nextToOneOp in _toOneOps) {
                localError = [nextToOneOp finishValidation];

                if (localError != nil) {
                    break;
                }
            }
        }

        if (localError == nil) {
            // Traverse the owned hierarchy
            for (FOSRetrieveToManyRelationshipOperation *nextToManyOp in _toManyOps) {
                localError = [nextToManyOp finishValidation];

                if (localError != nil) {
                    break;
                }
            }
        }
    }

    return localError;
}

- (void)finishCleanup:(BOOL)forceDestroy {
    _finishedErrorPass = NO;

    if (!_finishedCleanup) {
        _finishedCleanup = YES;

        // Traverse the owned hierarchy
        for (FOSRetrieveToOneRelationshipOperation *nextToOneOp in _toOneOps) {
            [nextToOneOp finishCleanup:forceDestroy];
        }

        for (FOSRetrieveToManyRelationshipOperation *nextToManyOp in _toManyOps) {
            [nextToManyOp finishCleanup:forceDestroy];
        }

        // If there was an error or cancellation, then delete our corresponding object
        if (self.isCancelled || self.error != nil) {

            // NOTE: Cannot use self.managedObject as it consults the error/cancelled status
            NSManagedObjectContext *moc = self.managedObjectContext;
            FOSCachedManagedObject *cmo =  _managedObjectID != nil
            ? (FOSCachedManagedObject *)[moc objectWithID:_managedObjectID]
            : nil;

            if (cmo != nil) {
                [self.managedObjectContext deleteObject:cmo];
                _managedObjectID = nil;
            }
        }
    }
}

#pragma mark - Overrides

- (BOOL)isReady {
    BOOL result = [super isReady] && _ready;

    return result;
}

- (void)main {
    [super main];

    if (!self.isCancelled && self.error == nil) {

        NSManagedObjectContext *moc = self.managedObjectContext;

        // Did we short-circuit to an existing object?  If not, create it now.
        __block BOOL markClean = YES;

        // There are cases where the _managedObjecgtID is no longer available.
        // I'm not sure how it happens, but it does.
        if (_managedObjectID != nil && ![moc existingObjectWithID:_managedObjectID error:nil]) {
            _managedObjectID = nil;
        }

        if (_managedObjectID == nil) {
            __block NSError *localError = nil;

            id<FOSTwoWayRecordBinding> recordBinder = _urlBinding.cmoBinding;

            // Create the new entity
            NSManagedObjectID *newCMOID = [self _objectFromJSON:_json
                                                        withJsonId:_jsonId
                                                         forEntity:_entity
                                                      withBindings:_bindings
                                                      twoWayBinder:recordBinder
                                                             error:&localError];
            if (localError == nil && newCMOID != nil) {
                __block FOSRetrieveCMOOperation *blockSelf = self;
                NSManagedObjectContext *moc = self.managedObjectContext;

                [moc performBlockAndWait:^{
                    FOSCachedManagedObject *newCMO = [moc objectWithID:newCMOID];

                    newCMO.hasRelationshipFaults = blockSelf->_createdFaults;

                    _managedObjectID = newCMO.objectID;

                    // The jsonId and managed object's jsonId should now align
                    NSAssert([_jsonId isEqual:newCMO.jsonIdValue], @"Ids aren't the same???");

                    // Add to bindings dictionary
                    [[self class] _setBindingValue:_managedObjectID
                                            forKey:newCMO.jsonIdValue
                                             enity:_entity
                                        inBindings:_bindings];
                }];
            }

            else {
                _error = localError;
            }
        }

        // Update the existing object with the new data from the server
        else if (_json != nil && !_fastTracked) {

            id<FOSTwoWayRecordBinding> binder = _urlBinding.cmoBinding;

            __block NSError *error = nil;

            NSManagedObjectID *objID = self.managedObjectID;
            [moc performBlockAndWait:^{
                FOSCachedManagedObject *obj = (FOSCachedManagedObject *)[moc objectWithID:objID];

                // Store the json
                obj.originalJsonData = [NSJSONSerialization dataWithJSONObject:_json
                                                                       options:0
                                                                         error:&error];

                if (error == nil) {
                    [binder updateCMO:obj
                        fromJSON:(NSDictionary *)_json
                    forLifecyclePhase:FOSLifecyclePhaseRetrieveServerRecord
                                error:&error];
                }

                _error = error;

                // updateWithJSONDictionary will mark the object clean (and thus remove
                // all modified properties), if there were not conflicts while updating.
                // If there were conflicts, then we still have modifications and are not
                // 'clean' w.r.t. the server.
                markClean = ![obj hasModifiedProperties];
            }];
        }

        if (_error == nil) {
            NSAssert([[self class] _bindingValueForKey:_jsonId entity:_entity inBindings:_bindings] != nil, @"Entity object missing from bindings???");
            NSAssert(![[[self class] _bindingValueForKey:_jsonId entity:_entity inBindings:_bindings] isKindOfClass:[NSNull class]],
                     @"Entity object missing from bindings???");
#ifdef DEBUG
            // This is expensive, so don't let it out into any other build type
            NSAssert([NSClassFromString(_entity.managedObjectClassName) fetchWithId:_jsonId] != nil,
                     @"Where's the instance in the DB???");
#endif

            // If we are the top-level fetch operation, then begin the binding process
            if (_isTopLevelFetch) {
                [self finishBinding];
                [self finishOrdering];
                NSError *localError = self.error;
                if (localError == nil) {
                    localError = [self finishValidation];
                }

                if (localError != nil) {
                    FOSLogDebug(@"DISCARDING INSTANCE: The entity %@ (%@-%@) failed binding/ordering/validation and has been discarded: %@", self.entity.name, self.jsonId, self.managedObjectID.description,
                                _isTopLevelFetch ? self.error.description : @"");
                }

                [self finishCleanup:(localError != nil)];
            }

            // We're now done binding the object, mark it as clean w.r.t. the server
            if (markClean && self.error == nil) {
                NSManagedObjectID *objID = self.managedObjectID;
                [moc performBlockAndWait:^{
                    [(FOSCachedManagedObject *)[moc objectWithID:objID] markClean];
                }];
            }
        }
    }
    else if (_isTopLevelFetch) {
        [self finishCleanup:self.error != nil];
    }

    NSAssert(self.isCancelled || self.error != nil || _managedObjectID != nil,
             @"Something didn't bind correctly!");
}

- (NSString *)debugDescription {
    NSString *result = [NSString stringWithFormat:@"%@ - %@ (%@)",
                        [super debugDescription],
                        _entity.name, _jsonId];

    return result;
}

#pragma mark - Private Methods

+ (BOOL)_checkItemDeleted:(FOSJsonId)jsonId
                forEntity:(NSEntityDescription *)entity
                    error:(NSError **)error {
    BOOL result = NO;

    // Has this item been deleted locally? If so, there's nothing to do.
    Class entityClass = NSClassFromString(entity.managedObjectClassName);
    if ([FOSDeletedObject existsDeletedObjectWithId:jsonId
                                            andType:entityClass]) {

        NSString *msg = [NSString stringWithFormat:@"The requested item (%@:%@) has been locally deleted.",
                         entity.managedObjectClassName, jsonId];

        if (error != nil) {
            // This 'error' is recognized locally as a mechanism to cancel the receiver's
            // operation.
            *error = [NSError errorWithDomain:@"FOSFetchEntityOperation_ItemDeletedLocally"
                                   andMessage:msg];
        }
        result = YES;
    }

    return result;
}

- (void)_updateReady {

    // NOTE: We need to be extremely careful here.  _managedObjectId & _allowFastTrack are possibly
    //       set in the initializer, but we're not *really* ready until we've been queued.  This is
    //       because the user can set _allowFastTrack between init and being queued
    BOOL ready = _json != nil ||
    (self.isQueued && _allowFastTrack && _managedObjectID != nil) ||
    self.error != nil;

    if (_ready != ready) {
        [self willChangeValueForKey:@"isReady"];
        _ready = ready;
        [self didChangeValueForKey:@"isReady"];
    }
}

- (NSManagedObjectID *)_objectFromJSON:(id<NSObject>)json
                            withJsonId:(FOSJsonId)jsonId
                             forEntity:(NSEntityDescription *)entity
                          withBindings:(NSMutableDictionary *)bindings
                          twoWayBinder:(id<FOSTwoWayRecordBinding>)twoWayBinder
                                 error:(NSError **)error {
    NSParameterAssert(json != nil);
    NSParameterAssert(jsonId != nil);
    NSParameterAssert(entity != nil);
    NSParameterAssert(twoWayBinder != nil);

    __block NSManagedObjectID *result = nil;
    if (error != nil) {
        *error = nil;
    }

    @synchronized(self.restConfig) { // A complete mutex lock across all threads for this REST Config
        NSEntityDescription *finalEntity = [self.restAdapter respondsToSelector:@selector(subtypeFromBase:givenJSON:)]
            ? [self.restAdapter subtypeFromBase:entity givenJSON:json]
            : entity;
        Class managedClass = NSClassFromString(finalEntity.managedObjectClassName);

        // Let's see if we already know this managed object
        __block NSManagedObjectID *cmoObjID = nil;
        __block NSError *localError = nil;
        NSManagedObjectContext *moc = self.managedObjectContext;

        // If the item has been locally deleted, we don't want to restore it back to our
        // parent's context, just skip it.
        if (![[self class] _checkItemDeleted:jsonId forEntity:entity error:&localError]) {
            // Does the fragment have a jsonId?  If not, then we can only pull
            // using the given jsonId.

            FOSJsonId localJsonId = [_urlBinding.cmoBinding jsonIdFromJSON:json
                                                                 forEntity:entity
                                                                     error:&localError];

            if (localError == nil) {
                if (localJsonId == nil) {
                    cmoObjID = [[self class] cmoForEntity:entity
                                          withJsonId:jsonId
                                        fromBindings:bindings
                                   inManagedObjectContext:moc];
                }
                else {
                    NSAssert([localJsonId isEqual:jsonId], @"Why are these different???");

                    // We'll use the JSON form, if possible, to handle the case that we cannot
                    // find a local instance with the id set; then we can search using
                    // "data equality".
                    cmoObjID = [self cmoForEntity:entity
                                    withJson:json
                                fromBindings:bindings
                           inManagedObjectContext:moc];
                }
            }
        }

        if (localError == nil) {
            [moc performBlockAndWait:^{
                FOSCachedManagedObject *cmo = nil;

                // Nope, create a new one
                if (cmoObjID == nil) {
                    cmo = [[managedClass alloc] initSkippingReadOnlyCheckAndInsertingIntoMOC:moc];
                    [cmo setJsonIdValue:jsonId];
                    if ([moc obtainPermanentIDsForObjects:@[cmo] error:&localError]) {
                        cmoObjID = cmo.objectID;
                        bindings[jsonId] = cmoObjID;
                    }
                }
                else {
                    cmo = [moc objectWithID:cmoObjID];
                }

                if (localError == nil) {
                    // Store the json
                    cmo.originalJsonData = [NSJSONSerialization dataWithJSONObject:json
                                                                           options:0
                                                                             error:&localError];

                    // Bind the local vars to the json
                    if ([twoWayBinder updateCMO:cmo
                                       fromJSON:json
                              forLifecyclePhase:FOSLifecyclePhaseRetrieveServerRecord
                                          error:&localError]) {

                        NSAssert([cmo.jsonIdValue isEqual:jsonId], @"Ids not equal???");

                        result = cmoObjID;
                    }
                }
            }];
        }

        if (localError != nil) {
            if (error != nil) {
                *error = localError;
            }

            result = nil;
        }
    }

    return result;
}

- (void)_resolveReferences {

    _toOneOps = [self _resolveToOneReferences];
    _toManyOps = [self _resolveToManyReferences];

    for (FOSOperation *nextOp in _toOneOps) {
        [self addDependency:nextOp];
    }
    for (FOSOperation *nextOp in _toManyOps) {
        [self addDependency:nextOp];
    }
}

- (NSArray *)_resolveToOneReferences {
    NSMutableArray *result = [NSMutableArray array];

    NSSet *filteredRels = [self _filterRelationships:self.entity.cmoToOneRelationships];

    // Process toOne relationships, optional relationships will be hooked up
    // at the last minute by FOSCachedManagedObject::willAccessValueForKey
    for (NSRelationshipDescription *relDesc in filteredRels) {
        FOSOperation *nextOp = nil;

        if (// Skip the inverse ownership relationship, as it will be resolved via finishBinding if
            // this isn't a topLevelFetch, otherwise, we'll have to go get it.
            ((!relDesc.isOptional &&
              (!relDesc.inverseRelationship.isOwnershipRelationship || self.isTopLevelFetch)) ||
             relDesc.jsonRelationshipForcePull == FOSForcePullType_Always)) {

                nextOp = [FOSRetrieveToOneRelationshipOperation fetchToOneRelationship:relDesc
                                                                          jsonFragment:self.json
                                                                          withBindings:_bindings
                                                                   andParentCMOBinding:_urlBinding.cmoBinding];

                [result addObject:nextOp];
            }
    }

    return result;
}

- (NSArray *)_resolveToManyReferences {
    NSMutableArray *result = [NSMutableArray array];

    NSSet *filteredRels = [self _filterRelationships:self.entity.cmoOwnedToManyRelationships];

    // Process toMany relationships, but only from the 'owner's' side
    for (NSRelationshipDescription *relDesc in filteredRels) {

        // Let's see if we can short circuit out
        // -1 => unknown, need to fetch to see
        NSInteger childCount = [self _serverChildCountForToManyRelationship:relDesc];

        // If we *know* that there are no children, we can skip trying to fetch them
        if ((childCount != 0 && relDesc.jsonRelationshipForcePull == FOSForcePullType_UseCount) ||
            !relDesc.isOptional ||
            relDesc.jsonRelationshipForcePull == FOSForcePullType_Always ||
            (_relationshipsToPull != nil)) {

            // We don't auto-pull on optional relationships, unless they tell us to do so.
            if (relDesc.isOptional && relDesc.jsonRelationshipForcePull == FOSForcePullType_Never &&
                (_relationshipsToPull == nil)) {
                [self _configureFaultingForRelationship:relDesc];
            }

            // Nope, must process many-to-one relationship now!
            else if (!relDesc.inverseRelationship.isToMany) {
                FOSOperation *nextOp =
                [FOSRetrieveToManyRelationshipOperation fetchToManyRelationship:relDesc
                                                                      ownerJson:self.json
                                                                    ownerJsonId:self.jsonId
                                                                       dslQuery:self.dslQuery
                                                                   mergeResults:self.mergeResults
                                                                   withBindings:_bindings
                                                            andParentCMOBinding:_urlBinding.cmoBinding];

                [result addObject:nextOp];
            }

            // Process many-to-many relationships
            // Only process toMany rels from the 'owner' side.  The 'owner' is
            // the entity that has 'cascade' delete rule
            else {
                NSString *msg = NSLocalizedString(@"Many-to-many relationships are not yet implemeted for relationship '%@' on entity '%@.", @"");
                [NSException raise:@"FOSNotImplemented"
                            format:msg, relDesc.name, relDesc.entity.name];
            }
        }
    }

    return result;
}

- (NSSet *)_filterRelationships:(NSSet *)relationships {
    NSSet *result = relationships;

    if (_relationshipsToPull != nil) {
        NSDictionary *context = @{ @"ENTITY" : self.entity };

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wselector"
        result = [_relationshipsToPull matchedItems:relationships
                                      matchSelector:@selector(name)
                                            context:context];
#pragma clang diagnostic pop
    }

    return result;
}

- (NSInteger)_serverChildCountForToManyRelationship:(NSRelationshipDescription *)relDesc {
    NSInteger childCount = -1; // -1 => unknown, need to fetch to see

    if ([self.json isKindOfClass:[NSDictionary class]]) {

        // Don't check counts between static table classes and non-static table entities.
        if (!self.entity.isStaticTableEntity || relDesc.destinationEntity.isStaticTableEntity) {
            NSString *childCountKey = [NSString stringWithFormat:@"%@ChildCount_",
                                       relDesc.name];
            id childCountJson = ((NSDictionary *)self.json)[childCountKey];
            if ([childCountJson isKindOfClass:[NSNumber class]]) {
                childCount = ((NSNumber *)childCountJson).integerValue;
            }
        }
        else {
            childCount = 0;
        }
    }

    return childCount;
}

- (void)_configureFaultingForRelationship:(NSRelationshipDescription *)relDesc {
    // Does the user want to auto-pull the relationship when it is crossed?
    if (relDesc.destinationEntity.jsonAllowFault) {
        NSPredicate *pred = [FOSRelationshipFault predicateForEntity:self.entity
                                                              withId:self.jsonId
                                                forRelationshipNamed:relDesc.name];
        NSArray *relationshipFaults =
        [self.restConfig.databaseManager fetchEntitiesNamed:@"FOSRelationshipFault"
                                              withPredicate:pred];

        if (relationshipFaults.count == 0) {
            FOSRelationshipFault *relFault = [[FOSRelationshipFault alloc] init];

            // TODO : http://fosmain.foscomputerservices.com:8080/browse/FF-6
            relFault.jsonId = (NSString *)self.jsonId;
            relFault.managedObjectClassName = self.entity.name;
            relFault.relationshipName = relDesc.name;

            _createdFaults = YES;
        }
    }
}

+ (void)_setBindingValue:(id)value forKey:(id<NSObject>)key enity:(NSEntityDescription *)entity inBindings:(NSMutableDictionary *)bindings {
    NSParameterAssert(value != nil);
    NSParameterAssert(key != nil);
    NSParameterAssert(entity != nil);
    NSParameterAssert(bindings != nil);

    NSString *finalKey = [self _bindingKeyForKey:key entity:entity];
    bindings[finalKey] = value;
}

+ (id)_bindingValueForKey:(id<NSObject>)key entity:(NSEntityDescription *)entity inBindings:(NSDictionary *)bindings {
    NSParameterAssert(key != nil);
    NSParameterAssert(entity != nil);
    NSParameterAssert(bindings != nil);

    id result = nil;

    NSString *finalKey = [self _bindingKeyForKey:key entity:entity];
    result = bindings[finalKey];

    return result;
}

+ (NSString *)_bindingKeyForKey:(id<NSObject>)key entity:(NSEntityDescription *)entity {
    NSParameterAssert(key != nil);
    NSParameterAssert(entity != nil);

    NSString *finalKey = key.description;

    if (entity != nil) {
        finalKey = [NSString stringWithFormat:@"%@:%@", entity.name, key.description];
    }
    
    return finalKey;
}

- (BOOL)_bindToJSONInBindings {
    NSError *localError = nil;
    BOOL result = NO;
    
    // Can we find the json in bindings?
    id<NSObject> originalJson = _bindings[@"originalJsonResult"];
    if (originalJson != nil) {
        NSDictionary *context = @{ @"ENTITY" : self.entity };
        
        id<NSObject> unwrappedJson = [_urlBinding unwrapBulkJSON:originalJson
                                                         context:context
                                                           error:&localError];
        
        // We expect an array of possibilities here. We'll look into
        // the array and attempt to match jsonId.
        if (unwrappedJson != nil && [unwrappedJson isKindOfClass:[NSArray class]]) {
            FOSCMOBinding *cmoBinding = _urlBinding.cmoBinding;
            
            // FF-11 TODO : Fefactor all such impls into a single impl on FOSAttributeBinding.
            FOSAttributeBinding *identityBinding = cmoBinding.identityBinding;
            
            NSDictionary *propsByName = self.entity.propertiesByName;
            NSArray *propNames = propsByName.allKeys;
            NSSet *identNames = [[identityBinding attributeMatcher] matchedItems:propNames
                                                                   matchSelector:nil
                                                                         context:context];
            context = [context mutableCopy];
            ((NSMutableDictionary *)context)[@"ATTRDESC"] = propsByName[identNames.anyObject];
            
            id<FOSExpression> jsonKeyExpression = identityBinding.jsonKeyExpression;
            NSString *jsonIdKeyPath = [jsonKeyExpression evaluateWithContext:context
                                                                       error:&localError];
            if (localError == nil && jsonIdKeyPath.length > 0) {
                for (id<NSObject> nextJson in (NSArray *)unwrappedJson) {
                    id nextJsonId = [(id)nextJson valueForKeyPath:jsonIdKeyPath];
                    
                    if ([nextJsonId isEqual:_jsonId]) {
                        self.json = nextJson;
                        result = YES;
                        break;
                    }
                }
            }
            
            // For now we'll ignore any errors as this is just fast tracking...
            else {
                FOSLogPedantic(@"Skipping binding to _bindings[\"originalJsonResult\"] for entity %@ due to error :%@",
                               localError.description);
                localError = nil;
            }
        }
    }
    
    return result;
}

@end
