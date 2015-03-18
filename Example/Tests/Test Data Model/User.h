//
//  User.h
//  FOSREST
//
//  Created by David Hunt on 12/2/13.
//
//  The MIT License (MIT)
//
//  Copyright (c) 2015 FOS Services, LLC
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in all
//  copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
//  SOFTWARE.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import <FOSREST/FOSParseUser.h>

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
