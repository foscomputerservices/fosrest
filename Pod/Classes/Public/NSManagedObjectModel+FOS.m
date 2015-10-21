//
//  NSManagedObjectModel+FOS.m
//  FOSRest
//
//  Created by David Hunt on 4/20/14.
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

#import <NSManagedObjectModel+FOS.h>

@interface NSEntityDescription (FOS_Merging)

+ (void)setPlaceholder:(NSString *)placeholder;
- (BOOL)isPlaceholder;
- (NSUInteger)depth;

@end

@implementation NSManagedObjectModel (FOS)

+ (nonnull NSManagedObjectModel *)modelByMergingModels:(nonnull NSArray<NSManagedObjectModel *> *)models
                                   ignoringPlaceholder:(nonnull NSString *)placeholder {
    return [self modelByMergingModels:models ignoringPlaceholder:placeholder typeNameSubstitutions:nil];
}

+ (nonnull NSManagedObjectModel *)modelByMergingModels:(nonnull NSArray<NSManagedObjectModel *> *)models
                                   ignoringPlaceholder:(nonnull NSString *)placeholder
                                 typeNameSubstitutions:(nullable NSDictionary<NSString *, NSString *> *)subs {
    NSManagedObjectModel *result = [[NSManagedObjectModel alloc] init];

    // Set placeholder
    [NSEntityDescription setPlaceholder:placeholder];

    NSArray *oldEntities = [self _orderedAndFilteredEntities:models typeNameSubstitutions:subs];
    NSDictionary *placeholderEntities = [self _placeholderEntities:models typeNameSubstitutions:subs];
    NSMutableDictionary *newEntities = [NSMutableDictionary dictionary];

    for (NSEntityDescription *oldParentEntity in oldEntities) {
        NSEntityDescription *newParentEntity = [oldParentEntity copy];

        // Merge the sub-entity lists of both 'old entity' and all placeholder entities
        NSMutableArray *allSubEntities =
            [NSMutableArray arrayWithArray:oldParentEntity.subentities];
        NSMutableArray *newSubEntities =
            [NSMutableArray arrayWithCapacity:oldParentEntity.subentities.count];

        NSArray *phEntities = placeholderEntities[oldParentEntity.name];
        if (phEntities != nil) {
            for (NSEntityDescription *phEntity in phEntities) {
                NSArray *phSubEntities = phEntity.subentities;
                [allSubEntities addObjectsFromArray:phSubEntities];
            }
        }

        // Repair superEntity<->subEntitiy relationships, if necessary
        for (NSEntityDescription *oldSubEntity in allSubEntities) {
            [newSubEntities addObject:newEntities[oldSubEntity.name]];
        }

        newParentEntity.subentities = newSubEntities;

        newEntities[oldParentEntity.name] = newParentEntity;
    }

    [result setEntities:newEntities.allValues];

    // Clear the placeholder
    [NSEntityDescription setPlaceholder:nil];

    result.localizationDictionary = [self _mergedLocalizationDictionaries:models];

    return result;
}

+ (NSArray *)_orderedAndFilteredEntities:(nonnull NSArray<NSManagedObjectModel *> *)models
                   typeNameSubstitutions:(nullable NSDictionary<NSString *, NSString *> *)subs {
    NSArray *mergedEntities = [self _mergedEntities:models typeNameSubstitutions:subs];

    NSPredicate *pred = [NSPredicate predicateWithFormat:@"isPlaceholder == NO"];
    NSArray *filteredEntities = [mergedEntities filteredArrayUsingPredicate:pred];

    return filteredEntities;
}

+ (NSDictionary *)_placeholderEntities:(nonnull NSArray<NSManagedObjectModel *> *)models
                 typeNameSubstitutions:(nullable NSDictionary<NSString *, NSString *> *)subs {
    NSArray *mergedEntities = [self _mergedEntities:models typeNameSubstitutions:subs];

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

+ (NSArray *)_mergedEntities:(nonnull NSArray<NSManagedObjectModel *> *)models
       typeNameSubstitutions:(nullable NSDictionary<NSString *, NSString *> *)subs {
    NSMutableArray *result = [NSMutableArray array];

    // Sort before filtering to get a true depth
    NSSortDescriptor *sortDesc = [NSSortDescriptor sortDescriptorWithKey:@"depth" ascending:NO];

    // The order acheieved here is exactly upside down.  That is we need or process from the
    // deepest level of the tree to the top.
    for (NSManagedObjectModel *model in [[models reverseObjectEnumerator] allObjects]) {
        NSArray *sortedEntities = [model.entities sortedArrayUsingDescriptors:@[ sortDesc ]];

        for (NSEntityDescription *entity in sortedEntities) {
            NSString *subType = subs[entity.managedObjectClassName];
            if (subType != nil) {
                entity.managedObjectClassName = subType;
            }

            [result addObject:entity];
        }
    }

    return result;
}

+ (NSDictionary *)_mergedLocalizationDictionaries:(nonnull NSArray<NSManagedObjectModel *> *)models {

    NSMutableDictionary *result = [NSMutableDictionary dictionary];

    for (NSManagedObjectModel *nextModel in models) {
        NSDictionary *locDict = nextModel.localizationDictionary;

        if (locDict != nil) {
            [result addEntriesFromDictionary:locDict];
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
    BOOL isPlaceHolder = [self.userInfo[_placeholder] boolValue];

    return isPlaceHolder;
}

- (NSUInteger)depth {
    NSUInteger result = self.isPlaceholder ? 10 : 1;
    NSEntityDescription *parent = self.superentity;

    while (parent != nil) {
        result += parent.isPlaceholder ? 10 : 1;

        parent = parent.superentity;
    }

    return result;
}

@end
