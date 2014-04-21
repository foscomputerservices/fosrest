//
//  NSManagedObjectModel+FOS.m
//  FOSFoundation
//
//  Created by David Hunt on 4/20/14.
//  Copyright (c) 2014 FOS Computer Services. All rights reserved.
//

#import "NSManagedObjectModel+FOS.h"

@interface NSEntityDescription (FOS_Merging)

+ (void)setPlaceholder:(NSString *)placeholder;
- (BOOL)isPlaceholder;
- (NSUInteger)depth;

@end

@implementation NSManagedObjectModel (FOS)

+ (NSManagedObjectModel *)modelByMergingModels:(NSArray *)models
                           ignoringPlaceholder:(NSString *)placeholder {
    NSManagedObjectModel *result = [[NSManagedObjectModel alloc] init];

    [NSEntityDescription setPlaceholder:placeholder];

    NSArray *oldEntities = [self _orderedAndFilteredEntities:models];
    NSDictionary *placeholderEntities = [self _placeholderEntities:models];
    NSMutableDictionary *newEntities = [NSMutableDictionary dictionary];

    for (NSEntityDescription *oldParentEntity in oldEntities) {
        NSEntityDescription *newParentEntity = [oldParentEntity copy];

        // Merge the sub-entity lists of both 'old entity' and all placeholder entities
        NSMutableArray *allSubentities =
            [NSMutableArray arrayWithArray:oldParentEntity.subentities];
        NSMutableArray *newSubEntities =
            [NSMutableArray arrayWithCapacity:oldParentEntity.subentities.count];

        NSArray *phEntities = placeholderEntities[oldParentEntity.name];
        if (phEntities != nil) {
            for (NSEntityDescription *phEntity in phEntities) {
                NSArray *phSubEntities = phEntity.subentities;
                [allSubentities addObjectsFromArray:phSubEntities];
            }
        }

        // Repair superentity<->subentitiy relationships, if necessary
        for (NSEntityDescription *oldSubEntity in allSubentities) {
            [newSubEntities addObject:newEntities[oldSubEntity.name]];
        }

        newParentEntity.subentities = newSubEntities;

        newEntities[oldParentEntity.name] = newParentEntity;
    }

    [result setEntities:newEntities.allValues];

    for (NSEntityDescription *newEntity in newEntities.allValues) {
        NSMutableString *logStr = [NSMutableString string];

        [logStr appendFormat:@"New Entity: %@ (%@) - ", newEntity.name,
         newEntity.superentity.name];

        NSLog(@"%@", logStr);
    }

    return result;
}

+ (NSArray *)_orderedAndFilteredEntities:(NSArray *)models {
    NSArray *mergedEntities = [self _mergedEntities:models];

    // Sort before filtering to get a true depth
    NSSortDescriptor *sortDesc = [NSSortDescriptor sortDescriptorWithKey:@"depth" ascending:NO];
    NSArray *sortedEntities = [mergedEntities sortedArrayUsingDescriptors:@[ sortDesc ]];

    NSPredicate *pred = [NSPredicate predicateWithFormat:@"isPlaceholder == NO"];
    NSArray *filteredEntities = [sortedEntities filteredArrayUsingPredicate:pred];

    return filteredEntities;
}

+ (NSDictionary *)_placeholderEntities:(NSArray *)models {
    NSArray *mergedEntities = [self _mergedEntities:models];

    NSPredicate *pred = [NSPredicate predicateWithFormat:@"isPlaceholder == YES"];
    NSArray *filteredEntities = [mergedEntities filteredArrayUsingPredicate:pred];

    NSMutableDictionary *result = [NSMutableDictionary dictionaryWithCapacity:filteredEntities.count];

    for (NSEntityDescription *placeHolderEntity in filteredEntities) {
        // There can be placeholders in multiple models, so we need an array of them
        NSMutableArray *placeHolderEntities = result[placeHolderEntity.name];

        if (placeHolderEntities == nil) {
            placeHolderEntities = [NSMutableArray array];
            result[placeHolderEntity.name] = placeHolderEntities;
        }

        [placeHolderEntities addObject:placeHolderEntity];
    }

    return result;
}

+ (NSArray *)_mergedEntities:(NSArray *)models {
    NSMutableArray *result = [NSMutableArray array];

    for (NSManagedObjectModel *model in models) {
        for (NSEntityDescription *entity in model.entities) {
            [result addObject:entity];
        }
    }

    return result;
}

@end

@implementation NSEntityDescription (FOS_Merging)

static NSString *_placeholder;

// NOTE: Doesn't support multithreading, but that's probably ok.
+ (void)setPlaceholder:(NSString *)placeholder {
    _placeholder = placeholder;
}

- (BOOL)isPlaceholder {
    BOOL isPlaceHolder = [[self.userInfo objectForKey:_placeholder] boolValue];

    return isPlaceHolder;
}

- (NSUInteger)depth {
    NSUInteger result = 0;
    NSEntityDescription *parent = self.superentity;

    while (parent != nil) {
        result += parent.isPlaceholder ? 10 : 1;

        parent = parent.superentity;
    }

    return result;
}

@end
