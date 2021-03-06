//
//  FOSCachedManagedObject.m
//  FOSRest
//
//  Created by David Hunt on 12/22/12.
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

#import <FOSCachedManagedObject.h>
#import "FOSREST_Internal.h"

typedef void (^FOSReferenceResolutionHandler)(NSDictionary *resolutions, NSError *error);

@interface FOSCachedManagedObject (PrimitiveAccessors)

- (void)setPrimitiveIsFaultObject:(NSNumber *)isFaultObject;
- (void)setPrimitiveIsLocalOnly:(NSNumber *)isLocalOnly;

@end

static NSMutableDictionary *_processingFaults = nil;

@implementation FOSCachedManagedObject {
    // NOTE: _modifiedPropertiesCache *must* be cleared whenever hasModifiedProperties is modified!!!
    NSArray *_modifiedPropertiesCache;

    NSMutableDictionary *_associatedValues;
}

#pragma mark - DB Properties
@dynamic updatedWithServerAt;
@dynamic markedClean;
@dynamic hasRelationshipFaults;
@dynamic hasModifiedProperties;
@dynamic isFaultObject;
@dynamic isLocalOnly;
@dynamic isSendOnly;
@dynamic originalJsonData;

@synthesize isDirty;
@synthesize skipNextReset;

#pragma mark - Public Properties

- (BOOL)hasLocalOnlyParent {
    BOOL result = NO;

    for (NSRelationshipDescription *relDesc in self.entity.cmoRelationships) {
        // If we're not the owner ** and ** the inverse is the owner (otherwise
        // this relationship is a graph reference that can be ignored)
        if ((!relDesc.isOwnershipRelationship &&
             relDesc.inverseRelationship.isOwnershipRelationship)) {
            id relObj = [self valueForKey:relDesc.name];

            if ([relObj isKindOfClass:[FOSCachedManagedObject class]]) {
                FOSCachedManagedObject *parentCMO = (FOSCachedManagedObject *)relObj;
                result = parentCMO.isLocalOnly || parentCMO.hasLocalOnlyParent;
            }

            // The owner *is* (by definition) local, as it's not an FOSCachedManagedObject
            else {
                result = YES;
            }

            break;
        }
    }

    return result;
}

- (NSSet *)faultedRelationships {
    NSPredicate *pred = [NSPredicate predicateWithFormat:@"managedObjectClassName == %@ && jsonId == %@",
                         self.entity.name, self.jsonIdValue];
    NSArray *faults = [[FOSRESTConfig sharedInstance].databaseManager fetchEntitiesNamed:@"FOSRelationshipFault"
                                                                           withPredicate:pred];

    NSSet *result = nil;
    if (faults.count > 0) {
        result = [NSSet setWithArray:faults];
    }

    return result;
}

- (BOOL)isSubTreeDirty {
    __block BOOL result = self.isDirty;

    if (!result) {
        for (NSRelationshipDescription *relDesc in self.entity.cmoOwnedRelationships) {
            if (!relDesc.isToMany) {
                FOSCachedManagedObject *cmo = [self primitiveValueForKey:relDesc.name];

                result = cmo.isSubTreeDirty;
            }
            else {
                id<NSFastEnumeration> relCMOs = [self primitiveValueForKey:relDesc.name];

                for (FOSCachedManagedObject *nextCMO in relCMOs) {
                    result = nextCMO.isSubTreeDirty;

                    if (result) {
                        break;
                    }
                }
            }

            return !result;
        }
    }

    return result;
}

- (FOSRESTConfig *)restConfig {
    // TODO : Hook this up on create so that we're not using the 'sharedInstance'
    return [FOSRESTConfig sharedInstance];
}

- (BOOL)isUploadable {
    BOOL result = !self.isLocalOnly && !self.isReadOnly;

    return result;
}

- (FOSOperation *)prepareForSendOperation {
    return nil;
}

- (BOOL)skipServerDelete {
    FOSRESTConfig *restConfig = [FOSRESTConfig sharedInstance];
    FOSCacheManager *cacheMgr = restConfig.cacheManager;

    return [cacheMgr shouldSkipServerDeletionOfId:self.jsonIdValue];
}

- (void)setSkipServerDelete:(BOOL)skipServerDelete {
    FOSRESTConfig *restConfig = [FOSRESTConfig sharedInstance];
    FOSCacheManager *cacheMgr = restConfig.cacheManager;

    // Changes made to an NSManagedObject that is scheduled for
    // deletion are not saved and so we need a side-band mechanism.
    [cacheMgr skipServerDeletetionForId:self.jsonIdValue];
    [self _setSkipServerDeleteTree];
}

- (void)_setSkipServerDeleteTree {
    for (NSRelationshipDescription *relDesc in self.entity.cmoRelationships) {
        // Do we own this/these child/children?
        if (relDesc.isOwnershipRelationship) {
            if (!relDesc.isToMany) {
                FOSCachedManagedObject *childCMO = [self primitiveValueForKey:relDesc.name];
                childCMO.skipServerDelete = YES;
            }
            else {
                id<NSFastEnumeration> children = [self primitiveValueForKey:relDesc.name];

                for (FOSCachedManagedObject *childCMO in children) {
                    childCMO.skipServerDelete = YES;
                }
            }
        }
    }
}

- (FOSCachedManagedObject *)owner {
    __block FOSCachedManagedObject *result = nil;

    for (NSRelationshipDescription *relDesc in self.entity.cmoRelationships) {
        // Does the inverse of this rel own us?
        if (relDesc.inverseRelationship.isOwnershipRelationship) {
            if (relDesc.isToMany) {
                FOSLogCritical(@"INVALID DATA MODEL CONFIGURATION: Entity %@ has a to-Many relationship '%@' that is set as being an owner (Delete Rule = Cascade|Deny) of this entity.  This delete rule should be 'Nullify or No Action'", self.entity.name, relDesc.name);
            }

            result = [self valueForKey:relDesc.name];

            // We're done if we found an id, otherwise we might have
            // multiple potential owners.
            if (result != nil) {
                break;
            }
        }
    }

    return result;
}

#pragma mark - Class methods

+ (void)initialize {
    if (_processingFaults == nil) {
        _processingFaults = [[NSMutableDictionary alloc] init];
    }
}

+ (BOOL)idIsInDatabase:(FOSJsonId)jsonId {
    BOOL result = NO;

    if (jsonId != nil) {
        NSEntityDescription *entity = [self entityDescription];
        NSString *cmoKeyPath = [self _cmoIdentityKeyPath:[FOSRESTConfig sharedInstance]];

        NSPredicate *pred = [NSPredicate predicateWithFormat:@"%K == %@",
                             cmoKeyPath, jsonId];

        NSUInteger count = [[FOSRESTConfig sharedInstance].databaseManager countOfEntities:entity
                                                                         matchingPredicate:pred];

        result = (count > 0);
    }

    return result;
}

+ (BOOL)canHaveDuplicateJsonIds {
    return NO;
}

+ (instancetype)fetchWithId:(FOSJsonId)jsonId {
    id result = nil;

    if (jsonId != nil) {
        NSString *cmoKeyPath = [self _cmoIdentityKeyPath:[FOSRESTConfig sharedInstance]];
        NSPredicate *pred = [NSPredicate predicateWithFormat:@"%K == %@", cmoKeyPath, jsonId];

        NSString *entityName = [self entityName];
        NSArray *entities = [[FOSRESTConfig sharedInstance].databaseManager fetchEntitiesNamed:entityName
                                                                                 withPredicate:pred];

        if (entities.count > 0) {
            // See: http://fosmain.foscomputerservices.com:8080/browse/FF-12
            NSAssert([[self class] canHaveDuplicateJsonIds] || entities.count == 1,
                     @"Fetched more than one %@ with the same id (%@)",
                     entityName, jsonId);

            result = entities.lastObject;
        }
    }
    
    return result;
}

+ (instancetype _Nullable)fetchWithId:(FOSJsonId)jsonId
               inManagedObjectContext:(NSManagedObjectContext *)moc {
    id result = nil;

    if (jsonId != nil) {
        NSString *cmoKeyPath = [self _cmoIdentityKeyPath:[FOSRESTConfig sharedInstance]];
        NSPredicate *pred = [NSPredicate predicateWithFormat:@"%K == %@", cmoKeyPath, jsonId];

        NSString *entityName = [self entityName];
        NSError *localError = nil;
        NSArray *entities = [[FOSRESTConfig sharedInstance].databaseManager fetchEntitiesNamed:entityName
                                                                                 withPredicate:pred
                                                                           withSortDescriptors:nil
                                                                             withObjectContext:moc
                                                                                         error:&localError];

        if (entities == nil && localError != nil) {
            NSDictionary *userInfo = @{ @"error" : localError };
            NSString *msg = [NSString stringWithFormat:@"Error fetching %@: %@",
                             entityName, localError.description];

            @throw [NSException exceptionWithName:@"DBError"
                                           reason:msg
                                         userInfo:userInfo];
        }

        else if (entities.count > 0) {
            // See: http://fosmain.foscomputerservices.com:8080/browse/FF-12
            NSAssert([[self class] canHaveDuplicateJsonIds] || entities.count == 1,
                     @"Fetched more than one %@ with the same id (%@)",
                     entityName, jsonId);

            result = entities.lastObject;
        }
    }
    
    return result;
}

+ (NSSet *)fetchWithIds:(id<NSFastEnumeration>)jsonIds {
    NSSet *result = nil;

    NSString *cmoKeyPath = [self _cmoIdentityKeyPath:[FOSRESTConfig sharedInstance]];
    NSPredicate *pred = [NSPredicate predicateWithFormat:@"%K IN %@", cmoKeyPath, jsonIds];

    NSString *entityName = [self entityName];
    NSArray *entities = [[FOSRESTConfig sharedInstance].databaseManager fetchEntitiesNamed:entityName
                                                                             withPredicate:pred];

    result = [NSSet setWithArray:entities];

    return result;
}

+ (NSSet *)fetchWithRelId:(FOSJsonId)jsonRelId forJsonRelation:(NSString *)jsonRelation {
    NSSet *result = nil;

    if (jsonRelId != nil && jsonRelation != nil) {
        NSPredicate *pred = [NSPredicate predicateWithFormat:@"%K == %@",
                             jsonRelation, jsonRelId];

        NSString *entityName = [self entityName];
        NSArray *entities = [[FOSRESTConfig sharedInstance].databaseManager fetchEntitiesNamed:entityName
                                                                                 withPredicate:pred];

        result = [NSSet setWithArray:entities];
    }

    return result;
}

+ (NSArray *)fetchAll {
    return [self fetchWithPredicate:nil withSortDescriptors:nil];
}

+ (NSArray *)fetchWithPredicate:(NSPredicate *)pred {
    return [self fetchWithPredicate:pred withSortDescriptors:nil];
}

+ (NSArray *)fetchWithPredicate:(NSPredicate *)pred withSortDescriptors:(NSArray *)sortDescriptors {
    NSArray *result = [[FOSRESTConfig sharedInstance].databaseManager fetchEntitiesNamed:[self entityName]
                                                                           withPredicate:pred
                                                                     withSortDescriptors:sortDescriptors];
    return result;
}

+ (NSUInteger)count {
    NSUInteger result = [self countWithPredicate:nil];

    return result;
}

+ (NSUInteger)countWithPredicate:(NSPredicate *)pred {
    NSUInteger result = 0;

    if (pred != nil) {
        result = [[FOSRESTConfig sharedInstance].databaseManager countOfEntities:[self entityDescription]
                                                               matchingPredicate:pred];
    }

    return result;
}

#pragma mark - FOSLifecyclePhase Methods

- (FOSSendServerRecordOperation *)sendServerRecordWithLifecycleStyle:(NSString *)lifecycleStyle {
    return [self sendServerRecordWithLifecycleStyle:lifecycleStyle parentSentIDs:nil];
}

- (FOSSendServerRecordOperation *)sendServerRecordWithLifecycleStyle:(NSString *)lifecycleStyle
                                                       parentSentIDs:(NSSet *)parentSentIDs {
    FOSSendServerRecordOperation *result = nil;

    if (!self.hasBeenUploadedToServer) {
        result = [FOSCreateServerRecordOperation createOperationForCMO:self
                                                    withLifecycleStyle:lifecycleStyle];
    }
    else {
        result = [FOSUpdateServerRecordOperation updateOperationForCMO:self
                                                    withLifecycleStyle:lifecycleStyle];
    }

    result.parentSentIDs = parentSentIDs;

    return result;
}

+ (FOSRetrieveCMOOperation *)retrieveCMOForJsonId:(FOSJsonId)jsonId {
    NSParameterAssert(jsonId != nil);

    NSEntityDescription *entity = [self entityDescription];
    FOSRetrieveCMOOperation *fetchOp = [FOSRetrieveCMOOperation retrieveCMOForEntity:entity
                                                                              withId:jsonId];

    return fetchOp;
}

+ (FOSSearchOperation *)retrieveCMOsWithDSLQuery:(NSString *)dslQuery {
    FOSSearchOperation *result = [[FOSSearchOperation alloc] init];

    NSString *managedClassName = [self entityDescription].managedObjectClassName;
    result.managedClass = NSClassFromString(managedClassName);
    result.dslQuery = dslQuery;

    return result;
}

+ (FOSRetrieveCMOOperation *)createAndRetrieveServerRecordWithJSON:(id<NSObject>)json {
    NSParameterAssert(json != nil);

    NSManagedObjectContext *context = [FOSRESTConfig sharedInstance].databaseManager.currentMOC;

    FOSRetrieveCMOOperation *result = [NSEntityDescription insertNewCMOForEntityForName:[self entityName]
                                                                 inManagedObjectContext:context
                                                                               withJSON:json];

    return result;
}

#pragma mark - Associated Values

- (void)associateValue:(id _Nonnull)value toPropertyNamed:(NSString * _Nonnull)propName {
    if (_associatedValues == nil) {
        _associatedValues = [NSMutableDictionary dictionary];
    }

    _associatedValues[propName] = value;
}

- (id)associatedValueForProperty:(NSString * _Nonnull)propName {
    return _associatedValues[propName];
}

- (void)resetAssociatedValues {
    if (!self.skipNextReset) {
        _associatedValues = nil;
    }
}

#pragma mark - Overrides

- (void)awakeFromFetch {
    [super awakeFromFetch];

    [self _awake];
}

- (void)awakeFromInsert {
    [super awakeFromInsert];

    // We're a fault object until properties are set
    if (self.createdAt == nil) {
        [self setPrimitiveIsFaultObject:@YES];
    }

    [self _awake];
}

- (id)init {
    // Must call 'super init' to get the entity assigned
    if ((self = [super init]) != nil) {
        [self _assertModifiable];
    }

    return self;
}

- (BOOL)isDirty {
    // markedClean always trumps!
    if (self.markedClean || self.isFaultObject || !self.isUploadable) {
        return NO;
    }

    // This method gets called *a lot* any performance hits *will* be impactful!!!
    // jsonIdValue will return NSNull if there was no identity property specified.
    if (self.jsonIdValue == nil) {
        return YES;
    }

    // We replace our super class's impl here as we don't need to compare
    // timestamps, but instead have a list of data that is out of date.
    BOOL dirty = self.hasChanges || self.hasModifiedProperties;

    return dirty;
}

- (void)markClean {
    if (!self.isFaultObject && self.isUploadable) {
        // If we've got a primary key, then we've been uploaded and we're
        // no longer a fault object.
        //
        // REVIEW: This may not be necessary as after we upload an instance,
        //         we generally call updateWithJSONDictionary:, which clears
        //         this flag too.  And is it possible that 'markClean' is
        //         called just to keep instance from being uploaded?
        if (self.jsonIdValue != nil && self.isFaultObject) {
            self.isFaultObject = NO;
        }

        self.markedClean = YES;
    }

    [self _deleteModifiedProperties];
}

- (void)willSave {
    @autoreleasepool {
        if (!self.entity.isStaticTableEntity) {
            NSDate *startLastModifiedAt = [self primitiveValueForKey:@"lastModifiedAt"];
            BOOL saveRecursed = self.willSaveHasRecursed;
            [super willSave];

            NSDate *endLastModifiedAt = [self primitiveValueForKey:@"lastModifiedAt"];
            BOOL updatedLMA =
                (startLastModifiedAt != endLastModifiedAt) ||
                [startLastModifiedAt isEqual:endLastModifiedAt];

            // Setting properties can cause this method to be called subsequent times, so block them
            if (!saveRecursed) {

                if (self.isDeleted) {
                    [self _deleteModifiedProperties];
                }
                else if (self.isDirty) {

                    [self _assertModifiable];

                    // Record the properties that have been modified
                    [self _recordModifiedProperties];

                    // Update parent's lastModifiedAt
                    if (updatedLMA) {
                        [self _updateParentsLastModifiedAt];
                    }
                }

                // If this round marked the entry as clean, then update that
                // timestamp to be the same as 'lastModifiedAt', so that isDirty
                // will report correctly.
                else if (self.markedClean) {
                    self.updatedWithServerAt = self.lastModifiedAt;
                    self.markedClean = NO;
                }
            }
        }
        else {
            [super willSave];
        }
    }
}

#ifndef NS_BLOCK_ASSERTIONS
- (void)didSave {
    [super didSave];

    // NOTE: One reason that we get here is that by default if an identity is of type NSNumber,
    //       the CoreData UI automatically defaults the value of the id to '0' instead of nil.
    //       If the user doesn't manually turn that off, then we'll assert here.
    //
    //       Thus, we'll also accept '0' as 'nil' for the id, if it's of type NSNumber, which
    //       makes this assert a bit heavy, but oh well...
    //
    //       There are also some records that don't have an id at all and jsonIdValue == [NSNull null]
    NSAssert(((self.jsonIdValue != nil || self.jsonIdValue == [NSNull null]) && self.updatedWithServerAt != nil) ||
             ((self.jsonIdValue == nil || self.jsonIdValue == [NSNull null] ||
               ([self.jsonIdValue isKindOfClass:[NSNumber class]] && ((NSNumber *)self.jsonIdValue).integerValue == 0)) &&
              self.updatedWithServerAt == nil) ||
             !self.isUploadable ||
             self.entity.isStaticTableEntity,
             @"jsonIdValue & updatedWithServerAt are out of sync!");
}
#endif

- (void)addObserver:(NSObject *)observer
         forKeyPath:(NSString *)keyPath
            options:(NSKeyValueObservingOptions)options
            context:(void *)context {

    [super addObserver:observer forKeyPath:keyPath options:options context:context];

    // TODO : This *does* work, but it's **extremely** expensive on data sets of
    //        any size as it forces the entire tree into memory.  Much better to
    //        store isSubTreeDirty in the DB and bubble up the value throught the DB.
    if ([keyPath isEqualToString:@"isSubTreeDirty"]) {

        // Look to 'lastModifiedAt' for 'isDirty', as 'isDirty' is not
        // KVO-compliant
        [self addObserver:self forKeyPath:@"lastModifiedAt" options:0 context:nil];

        for (NSRelationshipDescription *relDesc in self.entity.cmoOwnedRelationships) {
            if (!relDesc.isToMany) {
                FOSCachedManagedObject *cmo = [self primitiveValueForKey:relDesc.name];

                [cmo addObserver:self forKeyPath:@"isSubTreeDirty" options:0 context:nil];
            }

            else {
                id<NSFastEnumeration> relObjs = [self primitiveValueForKey:relDesc.name];

                for (FOSCachedManagedObject *cmo in relObjs) {
                    [cmo addObserver:self forKeyPath:@"isSubTreeDirty" options:0 context:nil];
                }
            }
        }
    }
}

- (void)willAccessValueForKey:(NSString *)key {
    [super willAccessValueForKey:key];

    FOSRESTConfig *restConfig = [FOSRESTConfig sharedInstance];

    // Ignore when pushing updates into main thread by cache manager
    // Ignore our own 'internal' keys
    //
    // NOTE: Perform isCMOPoperty check 1st, so that at startup internal properties
    // can be accessed before FOSRESTConfig is fully initialized.
    if ([NSThread isMainThread] &&
        ![NSAttributeDescription isFOSAttribute:key] &&
        restConfig.isFaultingEnabled &&
        !restConfig.cacheManager.updatingMainThreadMOC &&
        restConfig.networkStatus != FOSNetworkStatusNotReachable) {

        NSAssert(NO, @"TODO : Faulting");

#ifdef later

        __block FOSCachedManagedObject *blockSelf = self;

        // Let's see if this is a relationship fault
        NSDictionary *rels = self.entity.relationshipsByName;
        NSRelationshipDescription *relDesc = [rels objectForKey:key];
        if (relDesc != nil && relDesc.jsonRelationshipIdProp != nil) {

            // Handle 'toOne' faults
            if (!relDesc.isToMany) {
                // Calling primitiveValueForKey: keeps away from an infinite loop!
                FOSCachedManagedObject *propVal = [self primitiveValueForKey:key];

                // Attempt fault resolution if...
                //   1) The current property value is a fault object
                //   2) All of the following:
                //      a) The relationship is optional (not auto-pulled during original pull)
                //      b) The current value is nil
                if (propVal.isFaultObject || (relDesc.isOptional && propVal == nil)) {

                    NSSet *leafEntities = relDesc.destinationEntity.leafEntities;
                    NSMutableArray *resolvers = [NSMutableArray arrayWithCapacity:leafEntities.count];
                    NSMutableArray *finalOps = [NSMutableArray arrayWithCapacity:leafEntities.count];

                    BOOL found = NO;
                    for (NSEntityDescription *destEntity in leafEntities) {
                        FOSJsonId destId = propVal.jsonIdValue;

                        if (destId == nil) {

                            id<FOSRESTServiceAdapter> adapter = restConfig.restServiceAdapter;
                            FOSURLBinding *urlBinding = [adapter urlBindingForLifecyclePhase:FOSLifecyclePhaseRetrieveServerRecord
                                                                             forRelationship:nil
                                                                               forEntity:destEntity];
                            id<FOSTwoWayRecordBinding> recordBinding = urlBinding.cmoBinding;

                            // See if we can get it out of the original JSON
                            if (self.originalJsonData != nil) {
                                destId = [recordBinding jsonIdFromJSON:self.originalJson
                                                             forEntity:destEntity
                                                                 error:nil];
                            }
                        }

                        // It's possible that the caller is setting this property.  In this
                        // case, we won't yet have a destination id.
                        if (destId != nil) {

                            // Can we resolve this immediately?
                            Class class = NSClassFromString(destEntity.managedObjectClassName);
                            FOSCachedManagedObject *cmo = [class fetchWithId:destId];

                            if (cmo != nil) {
                                // We don't need to fire faults as this is the first
                                // 'look' at it.  Also, it would cause an endless loop.
                                [self setPrimitiveValue:cmo forKey:key];
                                found = YES;
                                break;
                            }

                            // Hit up the server
                            else {
                                FOSRetrieveCMOOperation *resolver =
                                    [FOSRetrieveCMOOperation retrieveCMOForEntity:destEntity
                                                                                  withId:destId
                                                                 andParentOperation:nil];

                                FOSBackgroundOperation *finalOp = [FOSBackgroundOperation backgroundOperationWithRequest:^(BOOL cancelled, NSError *error) {
                                    if (!cancelled && error == nil) {
                                        // We're in a different MOC, so we need to pull 'self' in this MOC
                                        NSManagedObjectID *selfID = blockSelf.objectID;
                                        NSManagedObjectContext *moc = restConfig.databaseManager.currentMOC;

                                        // Make sure we're still in the db
                                        NSError *error = nil;
                                        if ([moc existingObjectWithID:selfID error:&error]) {
                                            FOSCachedManagedObject *localSelf =
                                                (FOSCachedManagedObject *)[moc objectWithID:selfID];

                                            NSAssert([self.jsonIdValue isEqual:localSelf.jsonIdValue], @"Ids not equal?");

                                            [localSelf setValue:resolver.managedObject forKey:key];
                                        }
                                        else {
                                            FOSLogError(@"*** Unable to fulfill to-one request 'self' (%@) no longer exists??? (%@)", selfID.description, error.description);
                                        }
                                    }
                                }];

                                [resolvers addObject:resolver];
                                [finalOps addObject:finalOp];
                            }
                        }
                    }

                    // If we didn't find anything, then hit up the server, but not
                    // if the destination entity is a static entity, because we've
                    // got all of those instances locally.
                    if (!found &&
                        !relDesc.destinationEntity.jsonIsStaticTableEntity) {
                        for (NSUInteger i = 0; i < resolvers.count; i++) {
                            FOSOperation *resolver = resolvers[i];
                            FOSOperation *finalOp = finalOps[i];

                            NSString *msg = [NSString stringWithFormat:@"Pull entity: %@",
                                             [self entityName]];
                            [restConfig.cacheManager queueOperation:resolver
                                            withCompletionOperation:finalOp
                                                      withGroupName:msg];
                        }
                    }
                }
            }

            // Handle 'toMany' faults
            else if (restConfig.isFaultingEnabled) {
                if (self.hasRelationshipFaults) {
                    FOSJsonId sourceId = self.jsonIdValue;

                    // It's possible that the caller is setting this property.  In this
                    // case, we won't yet have a destination id.
                    if (sourceId != nil) {
                        BOOL processing = NO;

                        @synchronized(_processingFaults) {
                            NSMutableArray *faults = _processingFaults[self.objectID];

                            processing = [faults containsObject:key];

                            if (!processing) {
                                if (faults == nil) {
                                    faults = [NSMutableArray array];
                                    _processingFaults[self.objectID] = faults;
                                }

                                [faults addObject:key];
                            }
                        }

                        if (!processing) {
                            // Begin fault resolution
                            // TODO : Inheritance???

                            id<NSObject> ownerJson = self.originalJsonData;
                            NSMutableDictionary *emptyBindings = [NSMutableDictionary dictionary];
                            FOSRetrieveToManyRelationshipOperation *faultResolutionOp =
                                [FOSRetrieveToManyRelationshipOperation fetchToManyRelationship:relDesc
                                                                                   ownerJson:ownerJson
                                                                                 ownerJsonId:self.jsonIdValue
                                                                                withBindings:emptyBindings andParentFetchOperation:nil];

                            FOSBackgroundOperation *finalOp = [FOSBackgroundOperation backgroundOperationWithRequest:^(BOOL cancelled, NSError *error) {

                                // Now bind the pulled instances to ourself
                                [faultResolutionOp bindToOwner:self.objectID];

                                @synchronized(_processingFaults) {
                                    [_processingFaults removeObjectForKey:blockSelf.objectID];
                                }

                                [[blockSelf class] _clearObjectFaultForEntity:blockSelf.entity
                                                        withRelationshipNamed:key
                                                                       withId:blockSelf.jsonIdValue];
                            }];

                            // We *want* the finalOp to run *inside* the save operation, so it's
                            // *not* a completion operation
                            [finalOp addDependency:faultResolutionOp];

                            FOSBackgroundOperation *checkOp = nil;
#ifdef DEBUG
                            checkOp = [FOSBackgroundOperation backgroundOperationWithRequest:^(BOOL cancelled, NSError *error) {
                                if (!cancelled && error == nil) {
                                    dispatch_sync(dispatch_get_main_queue(), ^{
                                        BOOL isFaulted = [[self class] _hasObjectFaultForEntity:blockSelf.entity
                                                                          withRelationshipNamed:key
                                                                                         withId:blockSelf.jsonIdValue];
                                        NSAssert(!isFaulted, @"A fault object still exists!");

                                        FOSDatabaseManager *dbm = restConfig.databaseManager;
                                        NSManagedObjectContext *moc = dbm.currentMOC;
                                        NSPredicate *pred = [FOSRelationshipFault predicateForInstance:self
                                                                                  forRelationshipNamed:nil];
                                        NSEntityDescription *relEntity = [NSEntityDescription entityForName:@"FOSRelationshipFault"
                                                                                     inManagedObjectContext:moc];
                                        NSUInteger count = [dbm countOfEntities:relEntity
                                                              matchingPredicate:pred
                                                                inObjectContext:moc];
                                        BOOL countFound = (count > 0);
                                        NSAssert(self.hasRelationshipFaults == countFound,
                                                 @"FOSRelationshipFault instances doesn't match entity's 'hasRelationshipFaults' status.");
                                    });
                                }
                            }];
#endif

                            NSString *msg = [NSString stringWithFormat:@"Relationship fault %@{%@}.%@",
                                              [self entityName],
                                             self.jsonIdValue,
                                             key];
                            [restConfig.cacheManager queueOperation:finalOp
                                            withCompletionOperation:checkOp
                                                      withGroupName:msg];
                        }
                    }
                }
            }
        }
#endif
    }
}

- (NSString *)description {

//    _inhibitFaultResolution = YES;

    NSString *result = [super description];

    // Sometimes we're gone from the DB by the time that errors are invoked
    if ([self.managedObjectContext existingObjectWithID:self.objectID error:nil]) {
        result = [NSString stringWithFormat:@"{ { base = %@ }, createdAt = %@, lastModifiedAt = %@, updatedWithServerAt = %@, isDirty = %@ (_markedClean = %@) }",
                  [super description],
                  [self primitiveValueForKey:@"createdAt"],
                  [self primitiveValueForKey:@"lastModifiedAt"],
                  [self primitiveValueForKey:@"updatedWithServerAt"],
                  self.isDirty ? @"YES" : @"NO",
                  [[self primitiveValueForKey:@"markedClean"] boolValue] ? @"YES" : @"NO"];
    }

//    _inhibitFaultResolution = NO;

    return result;
}

#pragma mark - KVO Methods

- (void)observeValueForKeyPath:(NSString *)keyPath
                      ofObject:(id)object
                        change:(NSDictionary *)change
                       context:(void *)context {

    if ([keyPath isEqualToString:@"isSubTreeDirty"] ||
        [keyPath isEqualToString:@"lastModifiedAt"]) {
        [self willChangeValueForKey:@"isSubTreeDirty"];
        [self didChangeValueForKey:@"isSubTreeDirty"];
    }
    else {
        // We're no longer a fault if we have changed values
        if (self.isFaultObject && ![NSAttributeDescription isFOSAttribute:keyPath]) {
            [self _removeObservers];

            // 'NO' is not really an object
            [self setPrimitiveIsFaultObject:@NO];
        }
    }
}

#pragma mark - Public properties

- (FOSJsonId)jsonIdValue {
    // REVIEW : I'm not positive that this is the best way to accomplish this...
    // NOTE: Not all entities are going to have identities.  Some may be send only, for example.
    NSString *idProp = [[self class] _cmoIdentityKeyPath:[FOSRESTConfig sharedInstance]
                                              notFoundOK:YES];

    FOSJsonId result = [NSNull null];

    if (idProp != nil) {
        result = [self primitiveValueForKey:idProp];
    }

    return result;
}

- (void)setJsonIdValue:(FOSJsonId)jsonIdValue {
    NSParameterAssert(jsonIdValue != nil);

    NSString *idProp = [[self class] _cmoIdentityKeyPath:[FOSRESTConfig sharedInstance]];
    [self setValue:jsonIdValue forKeyPath:idProp];

    [self setPrimitiveIsFaultObject:@NO];
}

#ifdef DEBUG
- (BOOL)_debugReferencesGraph {
    BOOL result = YES;

    // All relationships that are *not* owned by this type must be uploaded
    // before we can be uploaded
    for (NSRelationshipDescription *relDesc in self.entity.cmoToOneRelationships) {
        if (!relDesc.isOwnershipRelationship) {
            FOSCachedManagedObject *relObj = [self valueForKey:relDesc.name];

            if (relObj != nil && !relObj.hasBeenUploadedToServer) {
                result = NO;

                FOSLogError(@"%@ NOT UPLOADED because %@ NOT UPLOADED via RELATIONSHIP %@",
                      [[self class] description],
                      [[relObj class] description],
                      relDesc.name);

                [relObj _debugReferencesGraph];
            }
        }
    }

    return result;
}
#endif

#pragma mark - Public methods


- (id<NSObject>)originalJson {
    NSDictionary *result = nil;

    if (self.originalJsonData != nil) {
        result = [NSJSONSerialization JSONObjectWithData:self.originalJsonData
                                                 options:0
                                                   error:nil];
    }

    return result;
}

- (BOOL)hasBeenUploadedToServer {
    FOSJsonId jsonIdValue = self.jsonIdValue;

    BOOL uploaded =
        (jsonIdValue != nil) &&
        (![jsonIdValue isKindOfClass:[NSNumber class]] ||
         ((NSNumber *)jsonIdValue).integerValue != 0) &&
        ((self.updatedWithServerAt != nil) ||
         self.markedClean);

    // This method is called while updating properties, so inconsistencies might occur
//    NSAssert(self.updatedWithServerAt == nil || self.jsonIdValue != nil,
//             @"How'd we upload to the server, but not have an id???");

    return uploaded;
}

- (NSSet *)propertiesModifiedSinceLastUpload {
    NSArray *modProps = [self _modifiedProperties];
    NSMutableSet *result = modProps ? [NSMutableSet setWithArray:modProps] : nil;

    return result;
}

#pragma mark - Refresh methods

- (void)refreshWithHandler:(FOSBackgroundRequest)handler {
    FOSRetrieveCMOOperation *retrieveCMOOp =
        [FOSRetrieveCMOOperation retrieveCMOForEntity:self.entity
                                               withId:self.jsonIdValue];

    FOSBackgroundOperation *finalOp = [FOSBackgroundOperation backgroundOperationWithMainThreadRequest:^(BOOL cancelled, NSError *error) {
        handler(cancelled, error);
    }];

    [self.restConfig.cacheManager queueOperation:retrieveCMOOp
                         withCompletionOperation:finalOp
                                   withGroupName:@"Refresh CMO"];
}

- (void)refreshRelationshipNamed:(NSString * _Nonnull)relName
                        dslQuery:(NSString * _Nullable)dslQuery
                         handler:(FOSBackgroundRequest _Nullable)handler {
    return [self refreshRelationshipNamed:relName
                                 dslQuery:dslQuery
                             mergeResults:NO
                                  handler:handler];
}

- (void)refreshRelationshipNamed:(NSString * _Nonnull)relName
                        dslQuery:(NSString * _Nullable)dslQuery
                    mergeResults:(BOOL)mergeResults
                         handler:(FOSBackgroundRequest _Nullable)handler {
    NSParameterAssert(relName != nil);

    // Nothing to refresh on localOnly instances
    if (!self.isLocalOnly) {
        id<FOSExpression> expr = [FOSConstantExpression constantExpressionWithValue:relName];
        NSMutableSet *exprs = [NSMutableSet setWithObject:expr];

        FOSItemMatcher *relMatcher = [FOSItemMatcher matcher:FOSItemMatchItems
                                          forItemExpressions:exprs];

        FOSRetrieveRelationshipUpdatesOperation *relUpdatesOp =
            [FOSRetrieveRelationshipUpdatesOperation retrieveRealtionshipUpdatesForCMO:self
                                                                              dslQuery:dslQuery
                                                                          mergeResults:mergeResults
                                                                              matching:relMatcher];

        FOSBackgroundOperation *finalOp = nil;
        if (handler != nil) {
            finalOp = [FOSBackgroundOperation backgroundOperationWithMainThreadRequest:handler];
        }

        NSString *groupName = [NSString stringWithFormat:@"Refresh relationship: %@", relName];

        [self.restConfig.cacheManager queueOperation:relUpdatesOp
                             withCompletionOperation:finalOp
                                       withGroupName:groupName];
    }
    else if (handler != nil) {
        handler(NO, nil);
    }
}

- (void)refreshAllRelationshipsNamed:(id<NSFastEnumeration>)relNames
                             handler:(FOSBackgroundRequest)handler {
    NSParameterAssert(relNames != nil);

    // Nothing to refresh on localOnly instances
    if (!self.isLocalOnly) {
        NSMutableSet *exprs = [NSMutableSet set];
        for (NSString *relName in relNames) {
            id<FOSExpression> expr = [FOSConstantExpression constantExpressionWithValue:relName];
            [exprs addObject:expr];
        }

        FOSItemMatcher *relMatcher = [FOSItemMatcher matcher:FOSItemMatchItems
                                          forItemExpressions:exprs];

        FOSRetrieveRelationshipUpdatesOperation *relUpdatesOp =
            [FOSRetrieveRelationshipUpdatesOperation retrieveRealtionshipUpdatesForCMO:self
                                                                              dslQuery:nil
                                                                          mergeResults:NO
                                                                              matching:relMatcher];

        FOSBackgroundOperation *finalOp = nil;
        if (handler != nil) {
            finalOp = [FOSBackgroundOperation backgroundOperationWithMainThreadRequest:handler];
        }

        NSMutableString *groupName = [@"Refresh relationships: " mutableCopy];
        BOOL first = YES;
        for (NSString *nextName in relNames) {
            if (first) {
                first = NO;
            }
            else {
                [groupName appendString:@", "];
            }
            [groupName appendString:nextName];
        }

        [self.restConfig.cacheManager queueOperation:relUpdatesOp
                             withCompletionOperation:finalOp
                                       withGroupName:groupName];
    }
    else if (handler != nil) {
        handler(NO, nil);
    }
}

- (void)refreshAllRelationships:(FOSBackgroundRequest)handler {
    NSArray *ownerRelationshipNames =
        [self.entity.ownerRelationships valueForKeyPath:@"name"];

    if (ownerRelationshipNames != nil) {
        [self refreshAllRelationshipsNamed:ownerRelationshipNames
                                   handler:handler];
    }
}

#pragma mark - Override Points

+ (id)objectForAttribute:(NSAttributeDescription *)attrDesc forJsonValue:(id)jsonValue {
    id jsonVal = [jsonValue isKindOfClass:[NSNull class]] ? nil : jsonValue;
    id result = jsonVal;

    if (jsonVal != nil && attrDesc.attributeType == NSTransformableAttributeType) {
        NSValueTransformer *transformer =
            [NSValueTransformer valueTransformerForName:attrDesc.valueTransformerName];

        result = [transformer reverseTransformedValue:jsonVal];
    }
    else if (attrDesc.attributeType == NSDateAttributeType && jsonVal != nil) {
        NSAssert([jsonVal isKindOfClass:[NSNumber class]], @"Expected a number!");

        NSNumber *number = (NSNumber *)jsonVal;
        result = [NSDate dateWithTimeIntervalSince1970:number.integerValue];
    }
    else if (attrDesc.attributeType == NSBinaryDataAttributeType && jsonVal != nil) {
        NSAssert([jsonVal isKindOfClass:[NSString class]], @"Expected an NSData object!");

        NSString *str = (NSString *)jsonVal;
        result = [NSData dataFromBase64String:str];
    }

    return result;
}

+ (id)jsonValueForObject:(id)objValue forAttribute:(NSAttributeDescription *)attrDesc {
    id result = objValue;

    if (objValue != nil && attrDesc.attributeType == NSTransformableAttributeType) {
        NSValueTransformer *transformer =
            [NSValueTransformer valueTransformerForName:attrDesc.valueTransformerName];

        result = [transformer transformedValue:objValue];
    }
    else if (objValue != nil && [result isKindOfClass:[NSDate class]]) {
        NSDate *date = (NSDate *)objValue;

        result = @(date.timeIntervalSince1970);
    }
    else if (objValue != nil && [result isKindOfClass:[NSData class]]) {
        NSData *data = (NSData *)objValue;

        result = [data base64EncodedString];
    }
    
    return result;
}

#pragma mark - JSON Methods

+ (NSString *)_trimObjectRef:(NSString *)objectRef
              fromJsonObject:(NSString *)jsonObject {

    NSString *jsonObjectRef = [NSString stringWithFormat:@"\"%@\":",
                               objectRef];
    NSRange trimStart = [jsonObject rangeOfString:jsonObjectRef];
    NSAssert(trimStart.location != NSNotFound,
             @"Didn't find objectRef: %@", jsonObjectRef);

    NSUInteger trimStartPos = trimStart.length + trimStart.location;
    NSRange innerRange = NSMakeRange(trimStartPos, jsonObject.length - trimStartPos - 1);
    NSString *jsonFragment = [jsonObject substringWithRange:innerRange];

    return jsonFragment;
}

#pragma mark - Private methods

+ (NSString *)_cmoIdentityKeyPath:(FOSRESTConfig *)restConfig {
    return [self _cmoIdentityKeyPath:restConfig notFoundOK:NO];
}

// NOTE: Not all entities are going to have identities.  Some may be send only, for example.
+ (NSString *)_cmoIdentityKeyPath:(FOSRESTConfig *)restConfig notFoundOK:(BOOL)notFoundOK {
    NSParameterAssert(restConfig != nil);

    NSString *result = nil;

    NSEntityDescription *entity = [self entityDescription];

    NSMutableDictionary *context = [@{ @"ENTITY" : entity } mutableCopy];

    id<FOSRESTServiceAdapter> adapter = restConfig.restServiceAdapter;
    FOSURLBinding *urlBinding =
        [adapter urlBindingForLifecyclePhase:FOSLifecyclePhaseRetrieveServerRecord
                              forLifecycleStyle:nil
                             forRelationship:nil
                                   forEntity:entity];

    // Any errors encountered by this method are yielded as exceptions as they're something
    // very wrong with the adapter's configuration.
    // FF-8 TODO : We need to do a better job of finding the correct lifecycle while retrieving the
    //             identity as it's not required to have RETRIEVE_SERVER_RECORD if the only way
    //             to get a CMO is through a relationship.
    if (urlBinding == nil && !notFoundOK) {
        NSString *msgFmt = @"Missing URL_BINDING for the RETRIEVE_SERVER_RECORD lifecycle of entity '%@' managed by %@.";
        NSString *msg = [NSString stringWithFormat:msgFmt,
                         entity.name, NSStringFromClass([adapter class])];
        NSException *e = [NSException exceptionWithName:@"FOSREST" reason:msg userInfo:nil];

        @throw e;
    }

    FOSCMOBinding *cmoBinding = urlBinding.cmoBinding;

    if (cmoBinding == nil && !notFoundOK) {
        NSString *msgFmt = @"Missing CMO_BINDING for entity '%@' managed by %@.";
        NSString *msg = [NSString stringWithFormat:msgFmt,
                         entity.name, NSStringFromClass([adapter class])];
        NSException *e = [NSException exceptionWithName:@"FOSREST" reason:msg userInfo:nil];

        @throw e;
    }

    FOSAttributeBinding *identityBinding = cmoBinding.identityBinding;

    if (identityBinding == nil && !notFoundOK) {
        NSString *msgFmt = @"Missing ID_ATTRIBUTE in the ATTRIBUTE_BINDINGS for entity '%@' managed by %@.";
        NSString *msg = [NSString stringWithFormat:msgFmt,
                         entity.name, NSStringFromClass([adapter class])];
        NSException *e = [NSException exceptionWithName:@"FOSREST" reason:msg userInfo:nil];

        @throw e;
    }

    if (identityBinding != nil) {
        NSDictionary *propsByName = entity.propertiesByName;
        NSArray *propNames = propsByName.allKeys;
        NSSet *identNames = [[identityBinding attributeMatcher] matchedItems:propNames
                                                               matchSelector:nil
                                                                     context:context];
        context[@"ATTRDESC"] = propsByName[identNames.anyObject];

        id<FOSExpression> expr = identityBinding.cmoKeyPathExpression;
        NSError *localError = nil;
        result =  [expr evaluateWithContext:context error:&localError];

        if (localError != nil) {
            NSString *msgFmt = @"Error evaluating the ID_ATTRIBUTE's CMO expression for entity '%@' managed by the %@ adapter: %@";
            NSString *msg = [NSString stringWithFormat:msgFmt,
                             entity.name, NSStringFromClass([adapter class]), localError.description];
            NSException *e = [NSException exceptionWithName:@"FOSREST" reason:msg userInfo:nil];

            @throw e;
        }
    }

    return result;
}

+ (NSSet *)_mappedRelationshipNames:(FOSRESTConfig *)restConfig
                     idRelationship:(NSString **)idRelKeyPath {
    NSParameterAssert(restConfig != nil);
    NSParameterAssert(idRelKeyPath != nil);
    *idRelKeyPath = nil;

    NSEntityDescription *entity = [self entityDescription];
    NSMutableDictionary *context = [@{ @"ENTITY" : entity } mutableCopy];

    id<FOSRESTServiceAdapter> adapter = restConfig.restServiceAdapter;
    FOSURLBinding *urlBinding = [adapter urlBindingForLifecyclePhase:FOSLifecyclePhaseRetrieveServerRecord
                                                      forLifecycleStyle:nil
                                                     forRelationship:nil
                                                           forEntity:entity];

    NSSet *relBindings = urlBinding.cmoBinding.relationshipBindings;
    NSMutableSet *result = [NSMutableSet set];

    for (NSRelationshipDescription *relDesc in entity.cmoRelationships) {
        context[@"RELDESC"] = relDesc;

        // Find the binding that matches this relationship
        for (FOSRelationshipBinding *relBinding in relBindings) {
            if ([relBinding.entityMatcher itemIsIncluded:relDesc.destinationEntity context:context] &&
                [relBinding.relationshipMatcher itemIsIncluded:relDesc.name context:context]) {

                [result addObject:relDesc.name];

                // If we've not captured the idKeyPath yet, do so now
                if (*idRelKeyPath == nil) {
                    id<FOSExpression> keyPathExpr = relBinding.jsonIdBindingExpression;

                    NSError *localError = nil;
                    *idRelKeyPath = [keyPathExpr evaluateWithContext:context
                                                               error:&localError];

                    // Incorrect binding description
                    if (localError != nil) {
                        NSException *e = [NSException exceptionWithName:@"FOSREST"
                                                                 reason:localError.description
                                                               userInfo:localError.userInfo];
                        @throw e;
                    }
                }
            }
        }
    }

    return result;
}

+ (NSSet *)_mappedPropertyNames:(FOSRESTConfig *)restConfig {
    NSParameterAssert(restConfig != nil);

    NSMutableSet *result = [NSMutableSet set];
    NSEntityDescription *entity = [self entityDescription];

    id<FOSRESTServiceAdapter> adapter = restConfig.restServiceAdapter;
    FOSURLBinding *urlBinding =
        [adapter urlBindingForLifecyclePhase:FOSLifecyclePhaseRetrieveServerRecord
                              forLifecycleStyle:nil
                             forRelationship:nil
                                   forEntity:entity];
    NSSet *attrBindings = urlBinding.cmoBinding.attributeBindings;

    NSMutableDictionary *context = [@{ @"ENTITY" : entity} mutableCopy];

    for (NSAttributeDescription *attrDesc in entity.cmoAttributes) {
        context[@"ATTRDESC"] = attrDesc;

        for (FOSAttributeBinding *attrBinding in attrBindings) {
            if (!attrBinding.isIdentityAttribute &&
                [attrBinding.attributeMatcher itemIsIncluded:attrDesc.name
                                                     context:context]) {
                [result addObject:attrDesc.name];
            }
        }
    }

    return result;
}

- (void)_assertModifiable {
    NSAssert(self.entity != nil, @"Cannot test yet, entity needs to be assigned!");

    if (self.isReadOnly) {

        NSString *msg = [NSString stringWithFormat:@"%@ is a static table instance and cannot be created/modified as FOSRESTConfig.allowStaticTableModifications == NO.",
                         NSStringFromClass([self class])];
        NSException *e = [NSException exceptionWithName:@"FOSREST" reason:msg userInfo:nil];

        @throw e;
    }
}

- (void)_awake {
    if (self.isFaultObject) {
        for (NSAttributeDescription *attrDesc in self.entity.cmoAttributes) {
            [self addObserver:self forKeyPath:attrDesc.name options:0 context:nil];
        }

        for (NSRelationshipDescription *relDesc in self.entity.cmoRelationships) {
            [self addObserver:self forKeyPath:relDesc.name options:0 context:nil];
        }
    }
}

- (void)_removeObservers {
    for (NSAttributeDescription *attrDesc in self.entity.cmoAttributes) {
        [self removeObserver:self forKeyPath:attrDesc.name];
    }

    for (NSRelationshipDescription *relDesc in self.entity.cmoRelationships) {
        [self removeObserver:self forKeyPath:relDesc.name];
    }
}

- (NSPredicate *)_modifiedPropertiesPredicate {
    NSPredicate *result = [NSPredicate predicateWithFormat:@"propertyObjectId == %@",
                           self.objectID.URIRepresentation.absoluteString];

    return result;
}

- (BOOL)_hasAtLeastOneOwnerDefined {
    // TODO : Fill this in.  It's really only a consistency check, so we can skip it for now.
    // The idea is to make sure that, if we have mulitple possibilities for owner relationships,
    // that at least one of them has a defined owner.
    return YES;
}

- (BOOL)_hasModifiedProperties_Slow {
    BOOL result = NO;

    if (self.isUploadable) {
        NSPredicate *pred = self._modifiedPropertiesPredicate;
        FOSDatabaseManager *dba = [FOSRESTConfig sharedInstance].databaseManager;
        NSEntityDescription *modifiedPropEntity = [NSEntityDescription entityForName:@"FOSModifiedProperty"
                                                              inManagedObjectContext:self.managedObjectContext];

        NSUInteger modPropCount = [dba countOfEntities:modifiedPropEntity
                                     matchingPredicate:pred
                                       inObjectContext:self.managedObjectContext];

        result = modPropCount > 0;
    }

    return result;
}

- (NSArray *)_modifiedProperties {
    NSArray *result = nil;

    NSAssert(self.isUploadable || !self.hasModifiedProperties,
             @"Why do we have modified properties for a non-uploadable instance???");

    if (self.isUploadable && self.hasModifiedProperties) {
        if (_modifiedPropertiesCache == nil) {
            NSPredicate *pred = self._modifiedPropertiesPredicate;

            FOSDatabaseManager *dba = [FOSRESTConfig sharedInstance].databaseManager;
            _modifiedPropertiesCache = [dba fetchEntitiesNamed:@"FOSModifiedProperty" withPredicate:pred];
        }

        result = _modifiedPropertiesCache;
    }

    return result;
}

- (void)_deleteModifiedProperties {
    NSAssert(self.isUploadable || !self.hasModifiedProperties,
             @"Why do we have modified properties for a non-uploadable instance???");

    if (self.isUploadable && self.hasModifiedProperties) {
        NSArray *modifiedProperties = self._modifiedProperties;

        for (FOSModifiedProperty *nextProp in modifiedProperties) {
            if (![nextProp isDeleted]) {
                [nextProp.managedObjectContext deleteObject:nextProp];
            }
        }

        _modifiedPropertiesCache = nil;
        self.hasModifiedProperties = NO;
    }

    // This code is *very* expensive
#ifdef needed
    NSAssert(self.hasModifiedProperties == [self _hasModifiedProperties_Slow],
             @"Modified property status out of sync!");
#endif
}

- (void)_recordModifiedProperties {
    NSAssert(self.isUploadable, @"Saving modified properties on a non-uploadable instance???");
    NSAssert(!self.isReadOnly, @"Saving modified properties on a read-only instance???");

    // Record FOSModifiedProperty records for all changed values
    NSMutableDictionary *changedVals = [self.changedValues mutableCopy];
    NSManagedObjectContext *moc = self.managedObjectContext;

    for (NSString *nextKey in changedVals) {
        if ([NSAttributeDescription isFOSAttribute:nextKey] &&
            ![NSAttributeDescription isUploadableFOSProperty:nextKey]) {
            [changedVals removeObjectForKey:nextKey];
        }
    }

    if (self.objectID.isTemporaryID) {
        [moc obtainPermanentIDsForObjects:@[ self ] error:nil];
    }
    
    NSAssert(!self.objectID.isTemporaryID, @"We should have a real id by now!");
    NSString *objIdStr = self.objectID.URIRepresentation.absoluteString;

    NSSet *knownObjectPropNames = [[self class] _mappedPropertyNames:[FOSRESTConfig sharedInstance]];
    NSString *idRelationshipKeyPath = nil;
    NSSet *knownRelNames = [[self class] _mappedRelationshipNames:[FOSRESTConfig sharedInstance]
                                                   idRelationship:&idRelationshipKeyPath];
    NSString *primaryKey = [[self class] _cmoIdentityKeyPath:[FOSRESTConfig sharedInstance]
                                                  notFoundOK:YES];

    // Remember which properties have been modified
    for (NSString *nextProp in changedVals) {

        // Skip the primary key, as you cannot update the PK on the server,
        // so the only reason it would change is syncing from the server.
        if ([nextProp isEqual:primaryKey]) {
            continue;
        }

        // Is the change an attribute that we sync with the web server?
        if ([knownObjectPropNames containsObject:nextProp]) {
            [self _createModifiedPropertyForObjId:objIdStr propertyName:nextProp];
        }

        // Is the change a relationship that we sync with the
        // web server?
        else if ([knownRelNames containsObject:nextProp]) {
            NSRelationshipDescription *relDesc = self.entity.propertiesByName[nextProp];
            NSAssert(relDesc != nil, @"No relDesc, how'd we get here???");

            // Only need modified properties for toOne relationships
            if (!relDesc.isToMany) {
                [self _createModifiedPropertyForObjId:objIdStr propertyName:nextProp];
            }

            // We also need to maintain the local attribute associated
            // with this FK relationships on toMany relationships
            else {
                // Find the attribute corresponding to the json property
                for (NSAttributeDescription *attrDesc in self.entity.cmoAttributes) {
                    if ([idRelationshipKeyPath isEqualToString:attrDesc.name]) {
                        NSString *objProp = attrDesc.name;
                        id newValue = changedVals[nextProp];

                        [self setValue:newValue forKey:objProp];
                    }
                }
            }
        }
    }
}

- (void)_createModifiedPropertyForObjId:(NSString *)objId
                           propertyName:(NSString *)propertyName {

    NSManagedObjectContext *moc = self.managedObjectContext;
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"FOSModifiedProperty"
                                              inManagedObjectContext:moc];

    FOSModifiedProperty *nextModProp = [[FOSModifiedProperty alloc] initWithEntity:entity
                                                    insertIntoManagedObjectContext:moc];

    nextModProp.propertyObjectId = objId;
    nextModProp.propertyName = propertyName;

    _modifiedPropertiesCache = nil;
    self.hasModifiedProperties = YES;

    FOSLogPedantic(@"Entity modified: %@::%@!", self.entity.name, propertyName);
}

- (void)_updateParentsLastModifiedAt {
    FOSCachedManagedObject *ownerCMO = self.owner;
    [ownerCMO setValue:[NSDate utcDate] forKey:@"lastModifiedAt"];
}

+ (NSPredicate *)_faultPredicateForEntity:(NSEntityDescription *)entity
                    withRelationshipNamed:(NSString *)relName
                                   withId:(FOSJsonId)jsonId {
    NSPredicate *pred = [FOSRelationshipFault predicateForEntity:entity
                                                          withId:jsonId
                                            forRelationshipNamed:relName];


    return pred;
}

+ (FOSRelationshipFault *)_faultForEntity:(NSEntityDescription *)entity
                    withRelationshipNamed:(NSString *)relName
                                   withId:(FOSJsonId)jsonId {

    FOSRelationshipFault *result = nil;
    if (jsonId != nil) {
        FOSDatabaseManager *dbm = [FOSRESTConfig sharedInstance].databaseManager;
        NSPredicate *pred = [self _faultPredicateForEntity:entity
                                     withRelationshipNamed:relName
                                                    withId:jsonId];
        NSArray *faults = [dbm fetchEntitiesNamed:@"FOSRelationshipFault" withPredicate:pred];
        NSAssert(faults.count <= 1, @"Too many fault objects for relationship: %@", relName);

        result = (faults.count == 0 ? nil : faults.lastObject);
    }

    return result;
}

+ (BOOL)_hasObjectFaultForEntity:(NSEntityDescription *)entity
           withRelationshipNamed:(NSString *)relName
                          withId:(FOSJsonId)jsonId {
    NSParameterAssert(entity != nil);
    NSParameterAssert(jsonId != nil);

    FOSDatabaseManager *dbm = [FOSRESTConfig sharedInstance].databaseManager;
    NSManagedObjectContext *moc = dbm.currentMOC;
    NSPredicate *pred = [self _faultPredicateForEntity:entity
                                 withRelationshipNamed:relName
                                                withId:jsonId];
    NSEntityDescription *faultEntity = [NSEntityDescription entityForName:@"FOSRelationshipFault"
                                                   inManagedObjectContext:moc];

    NSUInteger faultCount = [dbm countOfEntities:faultEntity
                               matchingPredicate:pred
                                 inObjectContext:moc];

    return faultCount > 0;
}

+ (void)_clearObjectFaultForEntity:(NSEntityDescription *)entity
             withRelationshipNamed:(NSString *)relName
                            withId:(FOSJsonId)jsonId {
    FOSRelationshipFault *fault = [self _faultForEntity:entity
                                  withRelationshipNamed:relName
                                                 withId:jsonId];
    
    if (fault != nil) {
        FOSDatabaseManager *dbm = [FOSRESTConfig sharedInstance].databaseManager;
        NSPredicate *pred = [FOSRelationshipFault predicateForEntity:entity
                                                              withId:jsonId
                                                forRelationshipNamed:nil];
        NSArray *faults = [dbm fetchEntitiesNamed:@"FOSRelationshipFault" withPredicate:pred];

        NSUInteger deletedCount = 0;
        for (FOSRelationshipFault *nextFault in faults) {
            if ([nextFault.relationshipName isEqualToString:relName]) {
                [nextFault.managedObjectContext deleteObject:nextFault];
                deletedCount += 1;
            }
        }

        Class class = NSClassFromString(entity.managedObjectClassName);
        FOSCachedManagedObject *cmo = [class fetchWithId:jsonId];
        BOOL faultsRemain = (faults.count - deletedCount) > 0;
        cmo.hasRelationshipFaults = faultsRemain;

        NSAssert([self _hasObjectFaultForEntity:entity withRelationshipNamed:nil withId:jsonId] == cmo.hasRelationshipFaults, @"Fault status out of sync!");
    }
}

@end
