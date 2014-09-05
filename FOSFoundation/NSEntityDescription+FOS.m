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
                                             forLifecyclePhase:FOSLifecyclePhaseRetrieveServerRecord
                                             forLifecycleStyle:nil];

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

- (BOOL)jsonIgnoreAsStaticTableEntity {
    BOOL result = NO;

    NSString *jsonValue = [self _bindPropertyForSelector:_cmd throwIfMissing:NO];
    if (jsonValue != nil) {
        result = ([jsonValue caseInsensitiveCompare:@"YES"] == NSOrderedSame);
    }

    return result;
}

- (NSString *)jsonAbstractRelationshipMaps {
    NSString *result = [self _bindPropertyForSelector:_cmd throwIfMissing:YES];

    return result;
}

#pragma mark - Computed Attribute & Relationship Properties

- (NSSet *)cmoAttributes {
    NSArray *props = self.properties;
    NSMutableSet *result = [NSMutableSet setWithCapacity:props.count];

    for (NSPropertyDescription *nextProp in props) {
        if ([nextProp isKindOfClass:[NSAttributeDescription class]] &&
            !((NSAttributeDescription *)nextProp).isFOSAttribute) {
            [result addObject:nextProp];
        }
    }

    return result;
}

// TODO: Below the algorithms could be optimized a bit as they build on one
//       another, which generates temporary garbage.
//
//       This implementaiton was chosen for the following reasons:
//         1) Reduce the likeliness that errors will get in
//            if things were to change in the future
//
//         2) Show the true cost of iterating the properties, where as
//            previously the cost was spread across the entire framework
//            in different areas
//
//       Probably the best way to optimize this would be to cache the results
//       in a static dictionary keyed by entity name, if this becomes too
//       expensive.

- (NSSet *)cmoRelationships {
    NSArray *props = self.properties;
    NSMutableSet *result = [NSMutableSet setWithCapacity:props.count];

    for (NSPropertyDescription *nextProp in props) {
        if ([nextProp isKindOfClass:[NSRelationshipDescription class]] &&
            !((NSRelationshipDescription *)nextProp).isFOSRelationship) {
            [result addObject:nextProp];
        }
    }

    return result;
}

- (NSSet *)cmoToOneRelationships {
    NSSet *cmoRels = self.cmoRelationships;
    NSMutableSet *result = [NSMutableSet setWithCapacity:cmoRels.count];

    for (NSRelationshipDescription *relDesc in cmoRels) {
        if (!relDesc.isToMany) {
            [result addObject:relDesc];
        }
    }

    return result;
}

- (NSSet *)cmoToManyRelationships {
    NSSet *cmoRels = self.cmoRelationships;
    NSMutableSet *result = [NSMutableSet setWithCapacity:cmoRels.count];

    for (NSRelationshipDescription *relDesc in cmoRels) {
        if (relDesc.isToMany) {
            [result addObject:relDesc];
        }
    }

    return result;
}

- (NSSet *)cmoOwnedRelationships {
    NSSet *cmoRels = self.cmoRelationships;
    NSMutableSet *result = [NSMutableSet setWithCapacity:cmoRels.count];

    for (NSRelationshipDescription *relDesc in cmoRels) {
        if (relDesc.isOwnershipRelationship) {
            [result addObject:relDesc];
        }
    }

    return result;
}

- (NSSet *)cmoOwnedToManyRelationships {
    NSSet *cmoRels = self.cmoOwnedRelationships;
    NSMutableSet *result = [NSMutableSet setWithCapacity:cmoRels.count];

    for (NSRelationshipDescription *relDesc in cmoRels) {
        if (relDesc.isToMany) {
            [result addObject:relDesc];
        }
    }
    
    return result;
}

#pragma mark - Inferred Properties

- (BOOL)hasOwner {
    BOOL result = NO;

    for (NSRelationshipDescription *relDesc in self.cmoRelationships) {
        result = relDesc.inverseRelationship.isOwnershipRelationship;

        if (result) {
            break;
        }
    }

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

#pragma mark - Localization Properties

- (NSString *)localizedName {
    NSString *result = nil;

    NSManagedObjectModel *mom = self.managedObjectModel;
    NSDictionary *locDict = mom.localizationDictionary;
    NSString *dictKey = [NSString stringWithFormat:@"Entity/%@", self.name];

    result = locDict[dictKey];

    if (result == nil) {
        FOSLogPedantic(@"Missing translation for entity: %@", self.name);
    }

    return result;
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
            result = userInfo[selName];

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

@end
