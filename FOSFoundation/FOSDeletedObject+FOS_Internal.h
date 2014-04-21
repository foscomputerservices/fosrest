//
//  FOSDeletedObject+FOS_Internal.h
//  FOSFoundation
//
//  Created by David Hunt on 9/17/13.
//  Copyright (c) 2013 FOS Computer Services. All rights reserved.
//

#import "FOSDeletedObject.h"

@interface FOSDeletedObject (FOS_Internal)

+ (BOOL)existsDeletedObjectWithId:(FOSJsonId)jsonId andType:(Class)type;

@end
