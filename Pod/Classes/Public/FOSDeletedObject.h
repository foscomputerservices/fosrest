//
//  FOSDeletedObject.h
//  FOSFoundation
//
//  Created by David Hunt on 4/19/14.
//  Copyright (c) 2014 FOS Computer Services. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface FOSDeletedObject : NSManagedObject

@property (nonatomic, retain) NSString * deletedJsonId;
@property (nonatomic, retain) NSString * deletedEntityName;

@end
