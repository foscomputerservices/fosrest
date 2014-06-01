//
//  NSEntityDescription+FOS_Internal.m
//  FOSFoundation
//
//  Created by David Hunt on 12/28/12.
//  Copyright (c) 2012 FOS Computer Services. All rights reserved.
//

#import "NSEntityDescription+FOS_Internal.h"
#import "FOSRetrieveCMODataOperation.h"
#import "FOSRetrieveCMOOperation.h"
#import "FOSUser.h"

@implementation NSEntityDescription (FOS_Internal)

#pragma mark - Class Methods

#pragma mark - Public Properties

- (BOOL)isFOSEntity {
    return [self isFOSEntityWithRestConfig:[FOSRESTConfig sharedInstance]];
}

- (BOOL)isFOSEntityWithRestConfig:(FOSRESTConfig *)restConfig {
    BOOL result = NO;

    NSString *modelCacheKey = self.name;
    NSMutableDictionary *entityCache = [restConfig modelCacheForModelKey:modelCacheKey];

    NSString *selName = NSStringFromSelector(_cmd);
    NSNumber *numResult = entityCache[selName];

    if (numResult != nil) {
        result = numResult.boolValue;
    }

    else  {
        result =
            [self.managedObjectClassName isEqualToString:@"FOSParseCachedManagedObject"] ||
            [self.managedObjectClassName isEqualToString:@"FOSCachedManagedObject"] ||
            [self.managedObjectClassName isEqualToString:@"FOSManagedObject"] ||
            [self.managedObjectClassName isEqualToString:@"FOSParseUser"] ||
            [self.managedObjectClassName isEqualToString:@"FOSUser"] ||
            [self.managedObjectClassName isEqualToString:@"FOSRelationshipFault"] ||
            [self.managedObjectClassName isEqualToString:@"FOSDeletedObject"] ||
            [self.managedObjectClassName isEqualToString:@"FOSModifiedProperty"];

        entityCache[selName] = result ? @YES : @NO;
    }

    return result;
}

- (NSSet *)leafEntities {
    NSSet *result = nil;

    NSString *modelCacheKey = self.name;
    NSMutableDictionary *entityCache = [[FOSRESTConfig sharedInstance] modelCacheForModelKey:modelCacheKey];

    BOOL retrievedFromCache = NO;
    NSString *selName = NSStringFromSelector(_cmd);
    result = entityCache[selName];

    if (result != nil) {
        retrievedFromCache = YES;
    }

    else {
        if (self.subentities.count == 0) {
            result = [NSSet setWithObject:self];
        }
        else {
            NSMutableSet *mutableSet = [NSMutableSet set];

            for (NSEntityDescription *nextSubEntity in self.subentities) {
                [mutableSet unionSet:nextSubEntity.leafEntities];
            }

            result = mutableSet;
        }

        entityCache[selName] = result;
    }

    return result;
}

- (NSSet *)flattenedRelationships {
    NSMutableSet *result = nil;

    NSString *modelCacheKey = self.name;
    NSMutableDictionary *entityCache = [[FOSRESTConfig sharedInstance] modelCacheForModelKey:modelCacheKey];

    BOOL retrievedFromCache = NO;
    NSString *selName = NSStringFromSelector(_cmd);
    result = entityCache[selName];

    if (result != nil) {
        retrievedFromCache = YES;
    }

    else {
        result = [NSMutableSet set];

        NSEntityDescription *nextEntity = self;
        do {

            for (NSPropertyDescription *nextProp in nextEntity.properties) {
                if ([nextProp isKindOfClass:[NSRelationshipDescription class]] &&
                    ![(NSRelationshipDescription *)nextProp isCMORelationship]) {
                    [result addObject:nextProp];
                }
            }

            nextEntity = nextEntity.superentity;
        } while (nextEntity != nil && !nextEntity.isFOSEntity);

        entityCache[selName] = result;
    }

    return result;
}

- (BOOL)hasMultipleOwnerRelationships {
    BOOL result = NO;

    NSString *modelCacheKey = self.name;
    NSMutableDictionary *entityCache = [[FOSRESTConfig sharedInstance] modelCacheForModelKey:modelCacheKey];

    BOOL retrievedFromCache = NO;
    NSString *selName = NSStringFromSelector(_cmd);
    NSNumber *numResult = entityCache[selName];

    if (numResult != nil) {
        retrievedFromCache = YES;
        result = numResult.boolValue;
    }

    else {
        NSInteger count = 0;

        for (NSRelationshipDescription *nextRel in self.flattenedRelationships) {
            if (nextRel.inverseRelationship.isOwnershipRelationship) {
                count += 1;
                if (count > 1) {
                    result = YES;
                    break;
                }
            }
        }

        entityCache[selName] = result ? @YES : @NO;
    }

    return result;
}

- (NSSet *)ownerRelationships {
    NSMutableSet *result = nil;

    NSString *modelCacheKey = self.name;
    NSMutableDictionary *entityCache = [[FOSRESTConfig sharedInstance] modelCacheForModelKey:modelCacheKey];

    BOOL retrievedFromCache = NO;
    NSString *selName = NSStringFromSelector(_cmd);
    result = entityCache[selName];

    if (result != nil) {
        retrievedFromCache = YES;
    }

    else {
        result = [NSMutableSet setWithCapacity:3];

        for (NSRelationshipDescription *nextRel in self.flattenedRelationships) {
            if (nextRel.inverseRelationship.isOwnershipRelationship) {
                [result addObject:nextRel];
            }
        }

        entityCache[selName] = result;
    }

    return result;
}

- (NSSet *)flattenedOwnershipRelationships {
    NSMutableSet *result = nil;

    NSString *modelCacheKey = self.name;
    NSMutableDictionary *entityCache = [[FOSRESTConfig sharedInstance] modelCacheForModelKey:modelCacheKey];

    BOOL retrievedFromCache = NO;
    NSString *selName = NSStringFromSelector(_cmd);
    result = entityCache[selName];

    if (result != nil) {
        retrievedFromCache = YES;
    }

    else {
        result = [NSMutableSet set];

        for (NSRelationshipDescription *ownerRel in self.ownerRelationships) {
            [result addObject:ownerRel];
            [result unionSet:ownerRel.destinationEntity.flattenedOwnershipRelationships];
        }

        entityCache[selName] = result;
    }

    return result;
}

- (BOOL)isStaticTableEntity {
    return [self isStaticTableEntityWithRestConfig:[FOSRESTConfig sharedInstance]];
}

- (BOOL)isStaticTableEntityWithRestConfig:(FOSRESTConfig *)restConfig {
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
            !self.jsonIgnoreAsStaticTableEntity &&
            !self.isAbstract &&
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
