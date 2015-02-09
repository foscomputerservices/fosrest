//
//  FOSRelationshipFault+FOS_Internal.h
//  FOSFoundation
//
//  Created by David Hunt on 4/19/13.
//  Copyright (c) 2013 FOS Computer Services. All rights reserved.
//

#import "FOSRelationshipFault.h"
#import "FOSCachedManagedObject.h"

@interface FOSRelationshipFault (FOS_Internal)

+ (NSPredicate *)predicateForEntity:(NSEntityDescription *)entity
                             withId:(FOSJsonId)jsonId
               forRelationshipNamed:(NSString *)relName;
+ (NSPredicate *)predicateForInstance:(FOSCachedManagedObject *)cmo
               forRelationshipNamed:(NSString *)relName;

@end
