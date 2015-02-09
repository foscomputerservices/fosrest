//
//  FOSRelationshipFault.h
//  FOSFoundation
//
//  Created by David Hunt on 4/18/13.
//  Copyright (c) 2013 FOS Computer Services. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import <FOSFoundation/FOSManagedObject.h>


@interface FOSRelationshipFault : FOSManagedObject

@property (nonatomic, retain) NSString * jsonId;
@property (nonatomic, retain) NSString * managedObjectClassName;
@property (nonatomic, retain) NSString * relationshipName;

@end
