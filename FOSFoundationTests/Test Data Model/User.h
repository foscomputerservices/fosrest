//
//  User.h
//  FOSFoundation
//
//  Created by David Hunt on 12/2/13.
//  Copyright (c) 2013 FOS Computer Services. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "FOSParseUser.h"

@class Role, TestCreate, TestToMany, Widget;

@interface User : FOSParseUser

@property (nonatomic, retain) Role *role;
@property (nonatomic, retain) NSSet *testCreations;
@property (nonatomic, retain) NSSet *toManyTest;
@property (nonatomic, retain) NSOrderedSet *widgets;
@end

@interface User (CoreDataGeneratedAccessors)

- (void)addTestCreationsObject:(TestCreate *)value;
- (void)removeTestCreationsObject:(TestCreate *)value;
- (void)addTestCreations:(NSSet *)values;
- (void)removeTestCreations:(NSSet *)values;

- (void)addToManyTestObject:(TestToMany *)value;
- (void)removeToManyTestObject:(TestToMany *)value;
- (void)addToManyTest:(NSSet *)values;
- (void)removeToManyTest:(NSSet *)values;

- (void)insertObject:(Widget *)value inWidgetsAtIndex:(NSUInteger)idx;
- (void)removeObjectFromWidgetsAtIndex:(NSUInteger)idx;
- (void)insertWidgets:(NSArray *)value atIndexes:(NSIndexSet *)indexes;
- (void)removeWidgetsAtIndexes:(NSIndexSet *)indexes;
- (void)replaceObjectInWidgetsAtIndex:(NSUInteger)idx withObject:(Widget *)value;
- (void)replaceWidgetsAtIndexes:(NSIndexSet *)indexes withWidgets:(NSArray *)values;
- (void)addWidgetsObject:(Widget *)value;
- (void)removeWidgetsObject:(Widget *)value;
- (void)addWidgets:(NSOrderedSet *)values;
- (void)removeWidgets:(NSOrderedSet *)values;
@end
