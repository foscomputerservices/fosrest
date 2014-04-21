//
//  TestToManyDestMax.h
//  FOSFoundation
//
//  Created by David Hunt on 12/2/13.
//  Copyright (c) 2013 FOS Computer Services. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "FOSParseCachedManagedObject.h"

@class TestToMany;

@interface TestToManyDestMax : FOSParseCachedManagedObject

@property (nonatomic, retain) TestToMany *toManyOwner;

@end
