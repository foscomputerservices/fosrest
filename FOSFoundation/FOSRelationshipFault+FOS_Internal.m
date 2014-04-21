//
//  FOSRelationshipFault+FOS_Internal.m
//  FOSFoundation
//
//  Created by David Hunt on 4/19/13.
//  Copyright (c) 2013 FOS Computer Services. All rights reserved.
//

#import "FOSRelationshipFault+FOS_Internal.h"

@implementation FOSRelationshipFault (FOS_Internal)

+ (NSPredicate *)predicateForEntity:(NSEntityDescription *)entity
                             withId:(FOSJsonId)jsonId
               forRelationshipNamed:(NSString *)relName {

    NSParameterAssert(entity != nil);
    NSParameterAssert(jsonId != nil);

    NSPredicate *result = nil;
    if (relName.length > 0) {
        result = [NSPredicate predicateWithFormat:@"jsonId == %@ && managedObjectClassName == %@ && relationshipName == %@",
                  jsonId, entity.name, relName];
    }
    else {
        result = [NSPredicate predicateWithFormat:@"jsonId == %@ && managedObjectClassName == %@",
                  jsonId, entity.name];
    }

    return result;
}

+ (NSPredicate *)predicateForInstance:(FOSCachedManagedObject *)cmo
               forRelationshipNamed:(NSString *)relName {

    NSParameterAssert(cmo != nil);
    NSParameterAssert(cmo.jsonIdValue != nil);

    NSString *jsonId = (NSString *)cmo.jsonIdValue;

    NSPredicate *result = [self predicateForEntity:cmo.entity
                                            withId:jsonId
                              forRelationshipNamed:relName];

    return result;
}

@end
