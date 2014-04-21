//
//  Widget.h
//  FOSFoundation
//
//  Created by David Hunt on 2/5/13.
//  Copyright (c) 2013 FOS Computer Services. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "FOSParseCachedManagedObject.h"

@class User, WidgetInfo;

@interface Widget : FOSParseCachedManagedObject

@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSNumber * ordinal;
@property (nonatomic, retain) User *user;
@property (nonatomic, retain) WidgetInfo *widgetInfo;
@property (nonatomic, retain) NSSet *notes;
@end

@interface Widget (CoreDataGeneratedAccessors)

- (void)addNotesObject:(NSManagedObject *)value;
- (void)removeNotesObject:(NSManagedObject *)value;
- (void)addNotes:(NSSet *)values;
- (void)removeNotes:(NSSet *)values;

@end
