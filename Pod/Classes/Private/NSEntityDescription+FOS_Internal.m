//
//  NSEntityDescription+FOS_Internal.m
//  FOSFoundation
//
//  Created by David Hunt on 12/28/12.
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

#import "NSEntityDescription+FOS_Internal.h"
#import "FOSFoundation_Internal.h"

@implementation NSEntityDescription (FOS_Internal)

#pragma mark - Class Methods

+ (NSString *)entityNameForClass:(Class)class {
    NSString *entityName = NSStringFromClass(class);

    // Handle Swift classes
    NSRange dotRange = [entityName rangeOfString:@"."];
    if (dotRange.location != NSNotFound) {
        entityName = [entityName substringFromIndex:dotRange.location + 1];
    }

    return entityName;
}

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

    NSString *selName = NSStringFromSelector(_cmd);
    result = entityCache[selName];

    if (result == nil) {
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

    NSString *selName = NSStringFromSelector(_cmd);
    result = entityCache[selName];

    if (result == nil) {
        result = [NSMutableSet set];

        NSEntityDescription *nextEntity = self;
        do {
            [result unionSet:nextEntity.cmoRelationships];

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

    NSString *selName = NSStringFromSelector(_cmd);
    NSNumber *numResult = entityCache[selName];

    if (numResult != nil) {
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

    NSString *selName = NSStringFromSelector(_cmd);
    result = entityCache[selName];

    if (result == nil) {
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

    NSString *selName = NSStringFromSelector(_cmd);
    result = entityCache[selName];

    if (result == nil) {
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

    NSString *selName = NSStringFromSelector(_cmd);
    NSNumber *numResult = entityCache[selName];

    if (numResult != nil) {
        result = numResult.boolValue;
    }

    else {
        NSPredicate *ownerPropertyPred = [NSPredicate predicateWithBlock:^BOOL(NSPropertyDescription *property, NSDictionary *bindings) {

            BOOL result =
                [property isKindOfClass:[NSRelationshipDescription class]] &&
                !((NSRelationshipDescription *)property).isFOSRelationship &&
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
