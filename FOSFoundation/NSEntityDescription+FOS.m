//
//  NSEntityDescription+FOS.m
//  FOSFoundation
//
//  Created by David Hunt on 12/22/12.
//  Copyright (c) 2012 FOS Computer Services. All rights reserved.
//

#import "NSEntityDescription+FOS.h"

@implementation NSEntityDescription (FOS)

// Fot atomic create
+ (FOSRetrieveCMOOperation *)insertNewCMOForEntityForName:(NSString *)entityName
                                inManagedObjectContext:(NSManagedObjectContext *)moc
                                              withJSON:(id<NSObject>)json {
    NSParameterAssert(entityName.length > 0);
    NSParameterAssert(moc != nil);
    NSParameterAssert(json != nil);

    NSEntityDescription *entity = [NSEntityDescription entityForName:entityName
                                              inManagedObjectContext:moc];

    FOSAtomicCreateServerRecordOperation *createOp = [FOSAtomicCreateServerRecordOperation operationForEntity:entity
                                                                                withJSON:json];

    FOSRetrieveCMOOperation *result =
        [FOSRetrieveCMOOperation retrieveCMOUsingDataOperation:createOp
                                             forLifecyclePhase:FOSLifecyclePhaseRetrieveServerRecord];

    return result;
}

#pragma mark - Optional Data Model Properties

- (BOOL)jsonAllowFault {
    BOOL result = NO;

    if ([FOSRESTConfig sharedInstance].isFaultingEnabled) {
        NSString *jsonValue = [self _bindPropertyForSelector:_cmd throwIfMissing:NO];
        if (jsonValue != nil) {
            result = ([jsonValue caseInsensitiveCompare:@"YES"] == NSOrderedSame);
        }
    }

    return result;
}

- (BOOL)jsonCanValueMatch {
    BOOL result = NO;

    NSString *jsonValue = [self _bindPropertyForSelector:_cmd throwIfMissing:NO];
    if (jsonValue != nil) {
        result = ([jsonValue caseInsensitiveCompare:@"YES"] == NSOrderedSame);
    }

    return result;
}

- (BOOL)jsonIsStaticTableEntity {
    BOOL result = NO;

    NSString *jsonValue = [self _bindPropertyForSelector:_cmd throwIfMissing:NO];
    if (jsonValue != nil) {
        result = ([jsonValue caseInsensitiveCompare:@"YES"] == NSOrderedSame);
    }
    else {
        result = [self _isStaticTableEntityWithRestConfig:[FOSRESTConfig sharedInstance]];
    }

    return result;
}

- (NSString *)jsonAbstractRelationshipMaps {
    NSString *result = [self _bindPropertyForSelector:_cmd throwIfMissing:YES];

    return result;
}

#pragma mark - Inferred Properties

- (BOOL)hasOwner {
    __block BOOL result = NO;

    [self enumerateOnlyOwned:NO relationships:^BOOL(NSRelationshipDescription *relDesc) {
        result = relDesc.inverseRelationship.isOwnershipRelationship;

        return !result;
    }];

    return result;
}

- (BOOL)hasUserDefinedProperties {
    BOOL result = NO;

    for (NSPropertyDescription *propDesc in self.properties) {
        if (propDesc.userInfo != nil && propDesc.userInfo.count > 0) {
            result = YES;
            break;
        }
    }

    return result;
}

#pragma mark - Custom Enumeration Methods

- (void)enumerateAttributes:(FOSAttributeHandler)handler {
    NSParameterAssert(handler != nil);

    for (NSPropertyDescription *propDesc in self.properties) {
        if ([propDesc isKindOfClass:[NSAttributeDescription class]]) {
            NSAttributeDescription *attrDesc = (NSAttributeDescription *)propDesc;

            if (!attrDesc.isCMOProperty) {
                if (!handler(attrDesc)) {
                    break;
                }
            }
        }
    }
}

- (void)enumerateOnlyOwned:(BOOL)onlyOwned relationships:(FOSRelationshipHandler)handler {
    NSParameterAssert(handler != nil);

    for (NSPropertyDescription *propDesc in self.properties) {
        if ([propDesc isKindOfClass:[NSRelationshipDescription class]]) {
            NSRelationshipDescription *relDesc = (NSRelationshipDescription *)propDesc;

            if (!relDesc.isCMORelationship) {
                if (!onlyOwned || relDesc.isOwnershipRelationship) {
                    if (!handler(relDesc)) {
                        break;
                    }
                }
            }
        }
    }
}

- (void)enumerateOnlyNotOwned:(BOOL)onlyNotOwned relationships:(FOSRelationshipHandler)handler {
    NSParameterAssert(handler != nil);

    for (NSPropertyDescription *propDesc in self.properties) {
        if ([propDesc isKindOfClass:[NSRelationshipDescription class]]) {
            NSRelationshipDescription *relDesc = (NSRelationshipDescription *)propDesc;

            if (!relDesc.isCMORelationship) {
                if (!onlyNotOwned || !relDesc.isOwnershipRelationship) {
                    if (!handler(relDesc)) {
                        break;
                    }
                }
            }
        }
    }
}

#pragma mark - Private methods

- (NSString *)_bindPropertyForSelector:(SEL)aSel
                        throwIfMissing:(BOOL)throwIfMissing {
    NSString *result = [self _bindPropertyForSelector:aSel
                                            baseClass:NSClassFromString(self.managedObjectClassName)
                                       throwIfMissing:throwIfMissing
                                            topEntity:self];

    return result;
}

// NOTE: This method is an extremely *HIGH USE* method!  Its implementation is carefully
//       tuned to yield optimal performance!
- (NSString *)_bindPropertyForSelector:(SEL)aSel
                             baseClass:(Class)baseClass
                        throwIfMissing:(BOOL)throwIfMissing
                             topEntity:(NSEntityDescription *)topEntity {
    NSString *result = nil;
    NSString *selName = NSStringFromSelector(aSel);

    NSString *modelCacheKey = self.name;
    NSMutableDictionary *entityCache = [[FOSRESTConfig sharedInstance] modelCacheForModelKey:modelCacheKey];

    BOOL retrievedFromCache = NO;
    result = entityCache[selName];

    if (result == nil) {
        NSDictionary *userInfo = self.userInfo;
        if (userInfo.count > 0) {
            result = [userInfo objectForKey:selName];

            if (result != nil && result.length == 0) {
                result = nil;
            }
        }
    }
    else {
        retrievedFromCache = YES;

        if ([result isKindOfClass:[NSNull class]]) {
            result = nil;
        }
    }

    if (result == nil && !retrievedFromCache) {
        // If we've reached the 'FOS' area of the hierarchy, let's look to see
        // if the entity class implemented this selector.
        if ([self.superentity.name rangeOfString:@"FOS"].location == 0) {
            if ([baseClass respondsToSelector:aSel]) {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
                result = [baseClass performSelector:aSel];
#pragma clang diagnostic pop

                if (result != nil && result.length == 0) {
                    result = nil;
                }
            }
        }

        if (result == nil) {
            if (self.superentity != nil) {
                result = [self.superentity _bindPropertyForSelector:aSel
                                                          baseClass:baseClass
                                                     throwIfMissing:throwIfMissing
                                                          topEntity:topEntity];
            }
            else if (throwIfMissing) {
                NSString *selName = NSStringFromSelector(aSel);
                NSString *exceptionName = [NSString stringWithFormat:@"FOSMissing_%@", selName];
                NSString *msg = NSLocalizedString(@"Missing '%@' on entity '%@'.", @"");

                [NSException raise:exceptionName format:msg, selName, topEntity];
            }
        }
    }

    if (!retrievedFromCache && self.subentities.count == 0) {
        if (result.length == 0) {
            result = nil;
        }

        if (result == nil) {
            entityCache[selName] = [NSNull null];
        }
        else {
            entityCache[selName] = result;
        }
    }

    return result;
}

- (BOOL)_isStaticTableEntityWithRestConfig:(FOSRESTConfig *)restConfig {
    BOOL result = NO;

    NSString *modelCacheKey = self.name;
    NSMutableDictionary *entityCache = [restConfig modelCacheForModelKey:modelCacheKey];

    BOOL retrievedFromCache = NO;
    NSString *selName = NSStringFromSelector(_cmd);
    NSNumber *numResult = entityCache[selName];

    if (numResult != nil) {
        result = numResult.boolValue;
        retrievedFromCache = YES;
    }

    else {
        NSPredicate *ownerPropertyPred = [NSPredicate predicateWithBlock:^BOOL(NSPropertyDescription *property, NSDictionary *bindings) {

            BOOL result =
            [property isKindOfClass:[NSRelationshipDescription class]] &&
            !((NSRelationshipDescription *)property).isCMORelationship &&
            ((NSRelationshipDescription *)property).inverseRelationship.isOwnershipRelationship;

            return result;
        }];

        Class entityClass = NSClassFromString(self.managedObjectClassName);

        result =
        ![self isFOSEntityWithRestConfig:restConfig] &&
        ([entityClass isSubclassOfClass:[FOSCachedManagedObject class]]) &&
        (![entityClass isSubclassOfClass:[FOSUser class]]) &&
        (self.subentities.count == 0) &&
        ([self.properties filteredArrayUsingPredicate:ownerPropertyPred].count == 0);

        entityCache[selName] = result ? @YES : @NO;
    }
    
    return result;
}

@end
