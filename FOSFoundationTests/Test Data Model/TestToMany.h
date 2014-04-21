//
//  TestToMany.h
//  FOSFoundation
//
//  Created by David Hunt on 12/2/13.
//  Copyright (c) 2013 FOS Computer Services. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "FOSParseCachedManagedObject.h"

@class TestToManyDestMax, TestToManyDestMin, User;

@interface TestToMany : FOSParseCachedManagedObject

@property (nonatomic, retain) NSString * testType;
@property (nonatomic, retain) NSSet *toManyMax;
@property (nonatomic, retain) NSSet *toManyMin;
@property (nonatomic, retain) User *user;
@end

@interface TestToMany (CoreDataGeneratedAccessors)

- (void)addToManyMaxObject:(TestToManyDestMax *)value;
- (void)removeToManyMaxObject:(TestToManyDestMax *)value;
- (void)addToManyMax:(NSSet *)values;
- (void)removeToManyMax:(NSSet *)values;

- (void)addToManyMinObject:(TestToManyDestMin *)value;
- (void)removeToManyMinObject:(TestToManyDestMin *)value;
- (void)addToManyMin:(NSSet *)values;
- (void)removeToManyMin:(NSSet *)values;

@end
