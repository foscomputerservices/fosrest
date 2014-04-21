//
//  FOSModifiedProperty.h
//  FOSFoundation
//
//  Created by David Hunt on 8/29/12.
//  Copyright (c) 2012 FOS Computer Services. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface FOSModifiedProperty : NSManagedObject

@property (nonatomic, retain) NSString * propertyName;
@property (nonatomic, retain) NSString * propertyObjectId;

@end
