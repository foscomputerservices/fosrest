//
//  FOSManagedObject+FOS_Internal.m
//  FOSFoundation
//
//  Created by David Hunt on 1/5/13.
//  Copyright (c) 2013 FOS Computer Services. All rights reserved.
//

#import "FOSManagedObject+FOS_Internal.h"

@implementation FOSManagedObject (FOS_Internal)

+ (NSEntityDescription *)entityDescriptionInManagedObjectContect:(NSManagedObjectContext *)moc {

    NSEntityDescription *result = [NSEntityDescription insertNewObjectForEntityForName:NSStringFromClass(self)
                                                                inManagedObjectContext:moc];
    if (result != nil) {
        result.managedObjectClassName = NSStringFromClass(self);
        result.properties = [self _properties];
        result.abstract = YES;
    }

    return result;
}

#pragma mark - Private Methods

+ (NSArray *)_properties {
    NSMutableArray *result = [NSMutableArray arrayWithCapacity:5];

    // Property: createdAt
    NSAttributeDescription *createdAt = [[NSAttributeDescription alloc] init];
    createdAt.indexed = NO;
    createdAt.name = @"createdAt";
    createdAt.optional = YES;
    createdAt.attributeType = NSDateAttributeType;
    [result addObject:createdAt];

    // Property: lastModifiedAT
    NSAttributeDescription *lastModifiedAt = [[NSAttributeDescription alloc] init];
    lastModifiedAt.indexed = NO;
    lastModifiedAt.name = @"lastModifiedAt";
    lastModifiedAt.optional = YES;
    lastModifiedAt.attributeType = NSDateAttributeType;
    [result addObject:lastModifiedAt];

    // Property: updatedWithServerAt
    NSAttributeDescription *updatedWithServerAt = [[NSAttributeDescription alloc] init];
    updatedWithServerAt.indexed = NO;
    updatedWithServerAt.name = @"updatedWithServerAt";
    updatedWithServerAt.optional = YES;
    updatedWithServerAt.attributeType = NSDateAttributeType;
    [result addObject:updatedWithServerAt];

    return result;
}

@end
