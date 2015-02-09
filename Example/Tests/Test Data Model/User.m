//
//  User.m
//  FOSFoundation
//
//  Created by David Hunt on 12/2/13.
//  Copyright (c) 2013 FOS Computer Services. All rights reserved.
//

#import "User.h"
#import "Role.h"
#import "TestCreate.h"
#import "TestToMany.h"
#import "Widget.h"


@implementation User

@dynamic role;
@dynamic testCreations;
@dynamic toManyTest;
@dynamic widgets;

// Work around for Apple bug
// http://stackoverflow.com/questions/7385439/exception-thrown-in-nsorderedset-generated-accessors
- (void)addWidgetsObject:(Widget *)value {
    NSMutableOrderedSet* tempSet = [self mutableOrderedSetValueForKey:@"widgets"];
    [tempSet addObject:value];
}

@end
