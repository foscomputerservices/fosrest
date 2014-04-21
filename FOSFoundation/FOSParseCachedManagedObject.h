//
//  FOSParseCachedManagedObject.h
//  FOSFoundation
//
//  Created by David Hunt on 12/29/12.
//  Copyright (c) 2012 FOS Computer Services. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "FOSCachedManagedObject.h"


@interface FOSParseCachedManagedObject : FOSCachedManagedObject

@property (nonatomic, retain) NSString * objectId;

@end
