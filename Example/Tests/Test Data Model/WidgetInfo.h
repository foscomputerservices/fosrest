//
//  WidgetInfo.h
//  FOSFoundation
//
//  Created by David Hunt on 2/5/13.
//  Copyright (c) 2013 FOS Computer Services. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import <FOSFoundation/FOSParseCachedManagedObject.h>

@class Widget;

@interface WidgetInfo : FOSParseCachedManagedObject

@property (nonatomic, retain) id color;
@property (nonatomic, retain) NSString * info;
@property (nonatomic, retain) NSSet *widgets;
@end

@interface WidgetInfo (CoreDataGeneratedAccessors)

- (void)addWidgetsObject:(Widget *)value;
- (void)removeWidgetsObject:(Widget *)value;
- (void)addWidgets:(NSSet *)values;
- (void)removeWidgets:(NSSet *)values;

@end
