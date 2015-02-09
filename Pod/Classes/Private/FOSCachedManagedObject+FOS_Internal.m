//
//  FOSCachedManagedObject+FOS_Internal.m
//  FOSFoundation
//
//  Created by David Hunt on 12/29/12.
//  Copyright (c) 2012 FOS Computer Services. All rights reserved.
//

#import "FOSCachedManagedObject+FOS_Internal.h"
#import "FOSRESTConfig.h"
#import "FOSFoundation_Internal.h"

@implementation FOSCachedManagedObject(FOS_Internal)

#pragma mark - Class Methods

+ (NSString *)entityName {
    NSString *entityName = [NSEntityDescription entityNameForClass:[self class]];

    return entityName;
}

+ (NSEntityDescription *)entityDescription {
    NSString *entityName = [self entityName];
    NSEntityDescription  *result = nil;

    NSManagedObjectContext *context = [FOSRESTConfig sharedInstance].databaseManager.currentMOC;
    if (context != nil) {
        result = [NSEntityDescription entityForName:entityName inManagedObjectContext:context];
    }
    else {
        NSManagedObjectModel *model = [FOSRESTConfig sharedInstance].databaseManager.storeCoordinator.managedObjectModel;

        result  = [model entitiesByName][entityName];

    }
    NSAssert(result != nil, @"Unable to find an entity description for entity: %@",
             entityName);

    return result;
}

- (id)initSkippingReadOnlyCheck {
    return [super init];
}

@end
