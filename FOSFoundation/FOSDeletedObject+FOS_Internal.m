//
//  FOSDeletedObject+FOS_Internal.m
//  FOSFoundation
//
//  Created by David Hunt on 9/17/13.
//  Copyright (c) 2013 FOS Computer Services. All rights reserved.
//

#import "FOSDeletedObject+FOS_Internal.h"

@implementation FOSDeletedObject (FOS_Internal)

+ (BOOL)existsDeletedObjectWithId:(FOSJsonId)jsonId andType:(Class)type {
    NSParameterAssert(jsonId != nil);
    NSParameterAssert(((NSString *)jsonId).length > 0);
    NSParameterAssert(type != nil);

    NSString *typeStr = NSStringFromClass(type);
    NSPredicate *pred = [NSPredicate predicateWithFormat:@"deletedJsonId = %@ && deletedEntityName == %@",
                         jsonId, typeStr];

    NSManagedObjectContext *moc = [FOSRESTConfig sharedInstance].databaseManager.currentMOC;

    NSFetchRequest *fetchReq = [NSFetchRequest fetchRequestWithEntityName:@"FOSDeletedObject"];
    fetchReq.predicate = pred;

    NSError *error = nil;
    NSUInteger matchCount = [moc countForFetchRequest:fetchReq error:&error];
    if (matchCount == NSNotFound) {
        NSException *e = [NSException exceptionWithName:@"FOSDeletedObjectError"
                                                 reason:error.description
                                               userInfo:@{ @"error" : error }];
        @throw e;
    }

    return matchCount > 0;
}

@end
