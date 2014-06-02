//
//  FOSRetrieveCMOOperation.m
//  FOSFoundation
//
//  Created by David Hunt on 12/31/12.
//  Copyright (c) 2012 FOS Computer Services. All rights reserved.
//

#import "FOSRetrieveCMOOperation+FOS_Internal.h"
#import "FOSRetrieveCMODataOperation.h"
#import "FOSCachedManagedObject+FOS_Internal.h"
#import "FOSRetrieveToOneRelationshipOperation.h"
#import "FOSRetrieveToManyRelationshipOperation.h"

@implementation FOSRetrieveCMOOperation {
    BOOL _ready;
    NSArray *_toOneOps;
    NSArray *_toManyOps;
    NSError *_error;
    BOOL _finishedBinding;
    BOOL _finishedOrdering;
    BOOL _finishedValidation;
    BOOL _finishedCleanup;
    BOOL _createdFaults;
    NSMutableDictionary *_bindings;
    FOSURLBinding *_urlBinding;
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
    NSMutableDictionary *bindings = [NSMutableDictionary dictionaryWithCapacity:100];
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
                              withId:(FOSJsonId)jsonId
                        withBindings:(NSMutableDictionary *)bindings {
    NSParameterAssert(bindings != nil);

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
                            withJson:(NSDictionary *)json {

    NSMutableDictionary *bindings = [NSMutableDictionary dictionaryWithCapacity:100];
    FOSRetrieveCMOOperation *result = [[self alloc] initForEntity:entity
                                                   ofRelationship:nil
                                                         withJson:json
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
        bindings[nextId] = [NSNull null];
    }

    // Replace the null entries with those that we've found
    for (FOSCachedManagedObject *nextCMO in existingEntities) {
        NSManagedObjectID *nextObjID = nextCMO.objectID;
        FOSJsonId jsonId = nextCMO.jsonIdValue;

        bindings[jsonId] = nextObjID;
    }

    return bindings;
}

+ (FOSCachedManagedObject *)cmoForEntity:(NSEntityDescription *)entity
                              withJsonId:(FOSJsonId)jsonId
                            fromBindings:(NSDictionary *)bindings
               respectingPreviousLookups:(BOOL)respectPrevious {
    NSParameterAssert(entity != nil);
    NSParameterAssert(jsonId != nil);
    NSParameterAssert(bindings != nil);

    FOSCachedManagedObject *result = nil;
    NSManagedObjectContext *moc = [FOSRESTConfig sharedInstance].databaseManager.currentMOC;

    id bindingVal = bindings[jsonId];

    if ([bindingVal isKindOfClass:[NSNull class]]) {
        bindingVal = nil;
    }

    if ([bindingVal isKindOfClass:[NSManagedObjectID class]]) {
        result = (FOSCachedManagedObject *)[moc objectWithID:(NSManagedObjectID *)bindingVal];
    }
    else if (bindingVal == nil && !respectPrevious) {
        Class class = NSClassFromString(entity.managedObjectClassName);
        result = [class fetchWithId:jsonId];
    }

    // This is expensive, so don't let it out into any other build types
#ifdef CONFIGURATION_Debug
    NSManagedObjectID *id1 = result.objectID;
    NSManagedObjectID *id2 = [[NSClassFromString(entity.managedObjectClassName) fetchWithId:jsonId] objectID];

    NSAssert(id1 == id2 || [id1 isEqual:id2], @"Something's really out of whack!");
#endif

    return result;
}

- (FOSCachedManagedObject *)cmoForEntity:(NSEntityDescription *)entity
                                withJson:(id<NSObject>)json
                            fromBindings:(NSDictionary *)bindings
               respectingPreviousLookups:(BOOL)respectPrevious {

    NSParameterAssert(entity != nil);
    NSParameterAssert(json != nil);

    FOSCachedManagedObject *result = nil;

    // Let's try just using the FOSJsonId 1st
    NSError *localError = nil;
    FOSJsonId jsonId = [_urlBinding.cmoBinding jsonIdFromJSON:json
                                                    forEntity:entity
                                                        error:&localError];

    if (localError == nil) {
        result = [[self class] cmoForEntity:entity
                                 withJsonId:jsonId
                               fromBindings:bindings
                  respectingPreviousLookups:respectPrevious];

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

                // Find all of the user-defined fields
                [entity enumerateAttributes:^BOOL(NSAttributeDescription *attrDesc) {

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

                    return YES; // Continue
                }];

                if (foundStringProp && matchPredStr.length > 0) {
                    NSPredicate *pred = [NSPredicate predicateWithFormat:matchPredStr
                                                           argumentArray:predVals];

                    NSArray *matched = [cmoClass fetchWithPredicate:pred];
                    
                    if (matched.count == 1) {
                        result = matched.lastObject;
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
                    blockSelf->_jsonId = fetchDataOp.jsonId;
                    blockSelf.json = (NSDictionary *)fetchDataOp.jsonResult;

                    // Also store the 'originalJson' in the bindings if we're the top-level
                    // data pull as it can have related-CMO data as well.
                    bindings[@"originalJsonResult"] = fetchDataOp.originalJsonResult;
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
                    FOSCachedManagedObject *cmo = [self cmoForEntity:_entity
                                                            withJson:json
                                                        fromBindings:_bindings
                                           respectingPreviousLookups:YES];
                    _managedObjectID = cmo.objectID;
                    if (_managedObjectID != nil) {
                        _bindings[_jsonId] = cmo.objectID;
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
    NSError *result = _error;
    if (result == nil) {
        result = [super error];
    }

    // FOSFetchEntityOperation_ItemDeletedLocally is a cancellation, not an error. Don't
    // let it escape.
    else if ([result.domain isEqualToString:@"FOSFetchEntityOperation_ItemDeletedLocally"]) {
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
    NSParameterAssert(jsonId != nil);

    _jsonId = jsonId;

    if (!self.isCancelled && self.error == nil) {

        __block FOSRetrieveCMOOperation *blockSelf = self;

        NSError *localError = nil;
        if (localError == nil) {

            // Can we find the JSON in _bindings???
            BOOL foundJson = [self _bindToJSONInBindings];

            // No need to pull the jsonData if we already have it
            if (!foundJson) {
                NSURLRequest *urlRequest = [_urlBinding urlRequestServerRecordOfType:self.entity
                                                                          withJsonId:jsonId
                                                                               error:&localError];

                // Fetch the data for entity with the given jsonId from the server
                FOSWebServiceRequest *jsonDataRequest =
                    [FOSWebServiceRequest requestWithURLRequest:urlRequest forURLBinding:_urlBinding];

                jsonDataRequest.willProcessHandler = /* (NSManagedObjectID *)(^)() */ ^{

                    NSManagedObjectID *result = nil;

                    // Can we FAST-TRACK to an existing object and skip pulling down this instance?
                    if (blockSelf->_allowFastTrack) {
                        result = blockSelf->_managedObjectID;

                        if (result == nil) {
                            FOSCachedManagedObject *cmo = [[self class] cmoForEntity:blockSelf->_entity
                                                                          withJsonId:jsonId
                                                                        fromBindings:blockSelf->_bindings
                                                           respectingPreviousLookups:NO];

                            result = cmo.objectID;
                        }
                    }

                    return result;
                };

                // Chain in an op that will add new dependencies to ourself after
                // they're determined from resolving the new FOSCachedManagedObject.  This
                // effectively creates a recursive structure for resolution.  Of course,
                // there hadn't better be any loops.
                FOSBackgroundOperation *queueSubOps = [FOSBackgroundOperation backgroundOperationWithRequest:^(BOOL isCancelled, NSError *error) {
                    if (!jsonDataRequest.isCancelled && jsonDataRequest.error == nil) {

                        // We got the object early! Woohoo!
                        if ([jsonDataRequest.jsonResult isKindOfClass:[NSManagedObjectID class]]) {
                            blockSelf->_managedObjectID = (NSManagedObjectID *)jsonDataRequest.jsonResult;

                            FOSCachedManagedObject *cmo = (FOSCachedManagedObject *)[self.managedObjectContext objectWithID:blockSelf->_managedObjectID];

                            NSAssert([(NSString *)blockSelf->_jsonId isEqualToString:(NSString *)cmo.jsonIdValue],
                                     @"Ids aren't the same?");

                            blockSelf->_json = cmo.originalJson;

                            FOSLogDebug(@"FOSFETCHENTITY - BEGIN (FASTRACK): %@ (%@)", blockSelf->_entity.name, blockSelf->_jsonId);

                            [self _updateReady];
                        }
                        else if (jsonDataRequest.jsonResult == nil) {
                            NSString *msg = NSLocalizedString(@"Received no data in response to the query '%@' for entity '%@'.", @"");

                            [NSException raise:@"FOSBadQuery" format:msg,
                             jsonDataRequest.endPoint, blockSelf->_entity.name];
                        }
                        else {
                            // This will call _updateReady
                            blockSelf.json = (NSDictionary *)jsonDataRequest.jsonResult;
                        }
                    }
                    else {
                        [self _updateReady];
                    }
                }];

                [queueSubOps addDependency:jsonDataRequest];
                [self addDependency:queueSubOps];
            }

            // If we've already been queued, then we need to queue these new ops
            if (self.isQueued) {
                NSAssert(!self.isFinished, @"We're already done executing and have new deps???");
                NSAssert(!self.isExecuting, @"We're already executing and have new deps???");

                // Requeue ourself so that we can find the begin op
                [self.restConfig.cacheManager requeueOperation:self];
            }
        }

        if (localError != nil) {
            _error = localError;
        }
    }
}

- (void)setJson:(id<NSObject>)json {
    _json = json;

    FOSCachedManagedObject *cmo = self.managedObject;
    NSError *localError = nil;

    // If we fast-tracked in, then there's no need to retrieve the references as
    // they're already taken care of.
    if ((!self.isCancelled && self.error == nil) && (cmo == nil)) {

        // Let's see if there's an updated jsonId in the given JSON
        FOSJsonId jsonId = [_urlBinding.cmoBinding jsonIdFromJSON:json
                                                        forEntity:self.entity
                                                            error:&localError];

        if (localError == nil) {
            if (jsonId != nil) {
                _jsonId = jsonId;
            }

            [self _resolveReferencesForJSON:_json
                                 withJsonOwnerId:_jsonId
                                  forEntity:_entity];

            // Queue subops, if we're already queued
            if (self.isQueued) {
                NSAssert(!self.isFinished, @"We're already done executing and have new deps???");
                NSAssert(!self.isExecuting, @"We're already executing and have new deps???");

                // We requeue ourself so that we can find the begin op
                [self.restConfig.cacheManager requeueOperation:self];
            }

        //    FOSLogDebug(@"FOSFETCHENTITY - BEGIN (setJson): %@ (%@)", _entity.name, _jsonId);
        }
    }

    if (localError != nil) {
        _error = localError;
    }

    [self _updateReady];
}

- (FOSCachedManagedObject *)managedObject {
    FOSCachedManagedObject *result = nil;

    if (_managedObjectID != nil && self.error == nil) {
        // This method can be called from various threads, so get the MOC of the
        // current thread.
        NSManagedObjectContext *moc = self.managedObjectContext;

        result = (FOSCachedManagedObject *)[moc objectWithID:_managedObjectID];
    }

    return result;
}

#pragma mark - Binding Methods

- (void)finishBinding {
    NSAssert(_managedObjectID != nil, @"Haven't finished loading the object yet???");

    // In graph resolution cycles, we might get called more than once, so cut off more than
    // the 1st attempt.
    if (!_finishedBinding && !self.isCancelled) {

        // Set at the beginning to skip cycles that might be triggered below
        _finishedBinding = YES;

        FOSCachedManagedObject *owner = self.managedObject;
        NSManagedObjectID *ownerID = owner.objectID;

        // Bind the to-one relationships
        BOOL encounteredErrors = NO;
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

            [_entity enumerateOnlyOwned:NO relationships:^BOOL(NSRelationshipDescription *relDesc) {
                if (!relDesc.isToMany && relDesc.isOptional) {

                    NSError *localError = nil;
                    FOSCMOBinding *cmoBinding = blockSelf->_urlBinding.cmoBinding;
                    FOSJsonId jsonRelId = [cmoBinding jsonIdFromJSON:blockSelf->_json
                                                           forEntity:blockSelf->_entity
                                                               error:&localError];

                    if (localError == nil) {
                        if (jsonRelId == nil) {
                            [owner setValue:nil forKey:relDesc.name];
                        }
                    }
                    else {
                        blockSelf->_error = localError;
                    }
                }

                return blockSelf->_error == nil;
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
        #ifndef NS_BLOCK_ASSERTIONS
                FOSCachedManagedObject *owner = self.managedObject;
                NSAssert(owner != nil, @"Unable to locate owner object!");
        #endif

                for (NSPropertyDescription *nextProp in _entity.properties) {
                    if ([nextProp isKindOfClass:[NSRelationshipDescription class]]) {
                        NSRelationshipDescription *relDesc = (NSRelationshipDescription *)nextProp;

                        if (relDesc.isOrdered && !relDesc.isOwnershipRelationship) {
                            FOSCachedManagedObject *owner = self.managedObject;
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
                }
            }
        }
    }
}

- (void)finishValidation {
    // Our subtree should now be valid
    if (!_finishedValidation && !self.isCancelled) {
        _finishedValidation = YES;

        BOOL encounteredErrors = (self.error != nil);

        if (!encounteredErrors) {
            NSError *error = nil;
            if (![self.managedObject validateForInsert:&error]) {
                _error = error;
                encounteredErrors = YES;
            }
        }

        if (!encounteredErrors) {
            // Traverse the owned hierarchy
            for (FOSRetrieveToManyRelationshipOperation *nextToManyOp in _toManyOps) {
                [nextToManyOp finishValidation];

                encounteredErrors = (nextToManyOp.error != nil);
                if (encounteredErrors) {
                    break;
                }
            }
        }
    }
}

- (void)finishCleanup:(BOOL)forceDestroy {
    if (!_finishedCleanup) {
        _finishedCleanup = YES;

        // Traverse the owned hierarchy
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
                FOSLogDebug(@"DISCARDING INSTANCE: The entity %@ (%@-%@) failed binding/ordering/validation and has been discarded: %@", self.entity.name, cmo.jsonIdValue, cmo.objectID.description,
                      _isTopLevelFetch ? self.error.description : @"");

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
        BOOL markClean = YES;
        if (_managedObjectID == nil) {
            NSError *localError = nil;

            id<FOSTwoWayRecordBinding> recordBinder = _urlBinding.cmoBinding;

            // Create the new entity
            FOSCachedManagedObject *newCMO = [self _objectFromJSON:_json
                                                        withJsonId:_jsonId
                                                         forEntity:_entity
                                                      withBindings:_bindings
                                                      twoWayBinder:recordBinder
                                                             error:&localError];
            if (localError == nil) {
                newCMO.hasRelationshipFaults = _createdFaults;

                if ([moc obtainPermanentIDsForObjects:@[ newCMO ] error:&localError]) {
                    _managedObjectID = newCMO.objectID;

                    // The jsonId and managed object's jsonId should now align
                    NSAssert([_jsonId isEqual:newCMO.jsonIdValue], @"Ids aren't the same???");

                    // Add to bindings dictionary
                    _bindings[newCMO.jsonIdValue] = _managedObjectID;
                }
                else {
                    _error = localError;
                }
            }
            else {
                _error = localError;
            }
        }

        // Update the existing object with the new data from the server
        else if (_json != nil) {

            id<FOSTwoWayRecordBinding> binder = _urlBinding.cmoBinding;

            NSError *error = nil;
            [binder updateCMO:self.managedObject
                     fromJSON:(NSDictionary *)_json
            forLifecyclePhase:FOSLifecyclePhaseRetrieveServerRecord
                        error:&error];
            _error = error;

            // updateWithJSONDictionary will mark the object clean (and thus remove
            // all modified properties), if there were not conflicts while updating.
            // If there were conflicts, then we still have modifications and are not
            // 'clean' w.r.t. the server.
            markClean = ![self.managedObject hasModifiedProperties];
        }

        if (_error == nil) {
            NSAssert(_bindings[_jsonId] != nil, @"Entity object missing from bindings???");
            NSAssert(![_bindings[_jsonId] isKindOfClass:[NSNull class]],
                     @"Entity object missing from bindings???");
#ifdef CONFIGURATION_Debug
            // This is expensive, so don't let it out into any other build type
            NSAssert([NSClassFromString(_entity.managedObjectClassName) fetchWithId:_jsonId] != nil,
                     @"Where's the instance in the DB???");
#endif

            // If we are the top-level fetch operation, then begin the binding process
            if (_isTopLevelFetch) {
                [self finishBinding];
                [self finishOrdering];
                [self finishValidation];
                [self finishCleanup:self.error != nil];
            }

            // We're now done binding the object, mark it as clean w.r.t. the server
            if (markClean && self.error == nil) {
                [self.managedObject markClean];
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

- (FOSCachedManagedObject *)_objectFromJSON:(id<NSObject>)json
                                 withJsonId:(FOSJsonId)jsonId
                                  forEntity:(NSEntityDescription *)entity
                               withBindings:(NSMutableDictionary *)bindings
                               twoWayBinder:(id<FOSTwoWayRecordBinding>)twoWayBinder
                                      error:(NSError **)error {
    NSParameterAssert(json != nil);
    NSParameterAssert(jsonId != nil);
    NSParameterAssert(entity != nil);
    NSParameterAssert(twoWayBinder != nil);

    FOSCachedManagedObject *result = nil;
    if (error != nil) {
        *error = nil;
    }

    @synchronized(self) {
        Class managedClass = NSClassFromString(entity.managedObjectClassName);

        // Let's see if we already know this managed object
        FOSCachedManagedObject *cmo = nil;
        NSError *localError = nil;

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
                    cmo = [[self class] cmoForEntity:entity
                                          withJsonId:jsonId
                                        fromBindings:bindings
                           respectingPreviousLookups:NO];
                }
                else {
                    NSAssert([localJsonId isEqual:jsonId], @"Why are these different???");

                    // We'll use the JSON form, if possible, to handle the case that we cannot
                    // find a local instance with the id set; then we can search using
                    // "data equality".
                    cmo = [self cmoForEntity:entity
                                    withJson:json
                                fromBindings:bindings
                   respectingPreviousLookups:NO];
                }
            }
        }

        if (localError == nil) {
            // Nope, create a new one
            if (cmo == nil) {
                cmo = [[managedClass alloc] initSkippingReadOnlyCheck];
                [cmo setJsonIdValue:jsonId];
            }

            // Bind the local vars to the json
            if ([twoWayBinder updateCMO:cmo
                               fromJSON:json
                      forLifecyclePhase:FOSLifecyclePhaseRetrieveServerRecord
                                  error:&localError]) {

                NSAssert([cmo.jsonIdValue isEqual:jsonId], @"Ids not equal???");

                result = cmo;
            }
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

- (void)_resolveReferencesForJSON:(id<NSObject>)json
                  withJsonOwnerId:(FOSJsonId)jsonOwnerId
                        forEntity:(NSEntityDescription *)entity {
    NSParameterAssert(json != nil);
    NSParameterAssert(entity != nil);

    NSMutableArray *toOneOps = [NSMutableArray array];
    NSMutableArray *toManyOps = [NSMutableArray array];

    for (NSPropertyDescription *nextProp in entity.properties) {
        if ([nextProp isKindOfClass:[NSRelationshipDescription class]]) {
            FOSOperation *nextOp = nil;

            NSRelationshipDescription *relDesc = (NSRelationshipDescription *)nextProp;

            // Process toOne relationships, optional relationships will be hooked up
            // at the last minute by FOSCachedManagedObject::willAccessValueForKey
            if (!relDesc.isToMany &&
                // Skip the inverse ownership relationship, as it will be resolved via finishBinding if
                // this isn't a topLevelFetch, otherwise, we'll have to go get it.
                ((!relDesc.isOptional &&
                  (!relDesc.inverseRelationship.isOwnershipRelationship || self.isTopLevelFetch)) ||
                 relDesc.jsonRelationshipForcePull == FOSForcePullType_Always)) {
                nextOp = [FOSRetrieveToOneRelationshipOperation fetchToOneRelationship:relDesc
                                                                       jsonFragment:json
                                                                       withBindings:_bindings];

                [toOneOps addObject:nextOp];
            }

            // Process toMany relationships, but only from the 'owner's' side
            else if (relDesc.isToMany &&
                     relDesc.isOwnershipRelationship) {

                // Let's see if we can short circuit out
                NSInteger childCount = -1; // -1 => unknown, need to fetch to see

                if ([json isKindOfClass:[NSDictionary class]]) {

                    // Don't check counts between static table classes and non-static table entities.
                    if (!entity.isStaticTableEntity || relDesc.destinationEntity.isStaticTableEntity) {
                        NSString *childCountKey = [NSString stringWithFormat:@"%@ChildCount_",
                                                   relDesc.name];
                        id childCountJson = ((NSDictionary *)json)[childCountKey];
                        if ([childCountJson isKindOfClass:[NSNumber class]]) {
                            childCount = ((NSNumber *)childCountJson).integerValue;
                        }
                    }
                    else {
                        childCount = 0;
                    }
                }

                // If we *know* that there are no children, we can skip trying to fetch them
                if ((childCount != 0 && relDesc.jsonRelationshipForcePull == FOSForcePullType_UseCount) ||
                    !relDesc.isOptional ||
                    relDesc.jsonRelationshipForcePull == FOSForcePullType_Always) {

                    // We don't auto-pull on optional relationships, unless they tell us to
                    // do so.
                    if (relDesc.isOptional && relDesc.jsonRelationshipForcePull == FOSForcePullType_Never) {

                        // Does the user want to auto-pull the relationship when it is
                        // crossed?
                        if (relDesc.destinationEntity.jsonAllowFault) {
                            NSPredicate *pred = [FOSRelationshipFault predicateForEntity:entity
                                                                                  withId:jsonOwnerId
                                                                    forRelationshipNamed:relDesc.name];
                            NSArray *relationshipFaults =
                                [self.restConfig.databaseManager fetchEntitiesNamed:@"FOSRelationshipFault"
                                                                      withPredicate:pred];

                            if (relationshipFaults.count == 0) {
                                FOSRelationshipFault *relFault = [[FOSRelationshipFault alloc] init];

                                relFault.jsonId = (NSString *)jsonOwnerId;
                                relFault.managedObjectClassName = entity.name;
                                relFault.relationshipName = relDesc.name;

                                _createdFaults = YES;
                            }
                        }
                    }

                    // Nope, must process many-to-one relationship now!
                    else if (!relDesc.inverseRelationship.isToMany) {
                        nextOp = [FOSRetrieveToManyRelationshipOperation fetchToManyRelationship:relDesc
                                                                                    ownerJson:json
                                                                                  ownerJsonId:jsonOwnerId
                                                                                 withBindings:_bindings];

                        [toManyOps addObject:nextOp];
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

            if (nextOp != nil) {
                [self addDependency:nextOp];
            }
        }
    }

    _toOneOps = toOneOps;
    _toManyOps = toManyOps;
}

- (BOOL)_bindToJSONInBindings {
    NSError *localError = nil;
    BOOL result = NO;

    // Can we find the json in bindings?
    id<NSObject> originalJson = _bindings[@"originalJsonResult"];
    if (originalJson != nil) {
        NSDictionary *context = @{ @"ENTITY" : self.entity };

        id<NSObject> unwrappedJson = [_urlBinding unwrapJSON:originalJson
                                                     context:context
                                                       error:&localError];

        // We expect an array of possibilities here. We'll look into
        // the array and attempt to match jsonId.
        if (unwrappedJson != nil && [unwrappedJson isKindOfClass:[NSArray class]]) {
            FOSCMOBinding *cmoBinding = _urlBinding.cmoBinding;

            FOSAttributeBinding *identityBinding = cmoBinding.identityBinding;

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
                localError = nil;
            }
        }
    }

    return result;
}

@end
