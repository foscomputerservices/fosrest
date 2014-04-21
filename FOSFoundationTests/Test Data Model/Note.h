//
//  Note.h
//  FOSFoundation
//
//  Created by David Hunt on 2/5/13.
//  Copyright (c) 2013 FOS Computer Services. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "FOSParseCachedManagedObject.h"

@class Role, TestCreate, Widget;

@interface Note : FOSParseCachedManagedObject

@property (nonatomic, retain) NSString * note;
@property (nonatomic, retain) Widget *widget;
@property (nonatomic, retain) TestCreate *testCreate;
@property (nonatomic, retain) Role *role;

@end
