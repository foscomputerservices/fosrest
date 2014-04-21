//
//  NSRelationshipDescription+FOS_Internal.h
//  FOSFoundation
//
//  Created by David Hunt on 12/28/12.
//  Copyright (c) 2012 FOS Computer Services. All rights reserved.
//

#import <CoreData/CoreData.h>

@interface NSRelationshipDescription (FOS_Internal)

@property (nonatomic, readonly) BOOL isCMORelationship;
@property (nonatomic, readonly) BOOL isOwnershipRelationship;

@end
