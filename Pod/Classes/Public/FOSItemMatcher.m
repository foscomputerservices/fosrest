//
//  FOSItemMatcher.m
//  FOSFoundation
//
//  Created by David Hunt on 3/19/14.
//  Copyright (c) 2014 FOS Computer Services. All rights reserved.
//

#import <FOSItemMatcher.h>
#import "FOSFoundation_Internal.h"

@implementation FOSItemMatcher

#pragma mark - Class Methods

+ (instancetype)matcherMatchingAllItems {
    FOSItemMatcher *result = [[self alloc] init];
    result.itemMatch = FOSItemMatchAll;

    return result;
}

+ (instancetype)matcherMatchingItemExpression:(id<FOSExpression>)itemExpression {
    return [self matcher:FOSItemMatchItems forItemExpressions:[NSSet setWithObject:itemExpression]];
}

+ (instancetype)matcher:(FOSItemMatch)match forItemExpression:(id<FOSExpression>)itemExpression {
    return [self matcher:match forItemExpressions:[NSSet setWithObject:itemExpression]];
}

+ (instancetype)matcher:(FOSItemMatch)match forItemExpressions:(NSSet *)itemExpressions {
    NSParameterAssert(itemExpressions != nil);
    NSParameterAssert([itemExpressions isKindOfClass:[NSSet class]]);

    FOSItemMatcher *result = [[self alloc] init];
    result.itemMatch = match;
    result.itemExpressions = itemExpressions;

    return result;
}

+ (instancetype)matcher:(FOSItemMatch)match forConstants:(NSSet *)constantValues {
    NSParameterAssert(constantValues != nil);
    NSParameterAssert([constantValues isKindOfClass:[NSSet class]]);

    NSMutableSet *exprs = [NSMutableSet setWithCapacity:constantValues.count];

    for (id value in constantValues) {
        [exprs addObject:[FOSConstantExpression constantExpressionWithValue:value]];
    }

    return [self matcher:match forItemExpressions:exprs];
}

#pragma mark - Public methods

- (BOOL)itemIsIncluded:(id)item context:(NSDictionary *)context {
    BOOL result = NO;

    switch (self.itemMatch) {
        case FOSItemMatchAll:
            result = YES;
            break;

        case FOSItemMatchAllExcept:
            result = ![[self _itemsForContext:context ] containsObject:item];
            break;

        case FOSItemMatchItems:
            result = [[self _itemsForContext:context] containsObject:item];
            break;
    }

    return result;
}

- (BOOL)itemsAreIncluded:(id<NSFastEnumeration>)items
                 context:(NSDictionary *)context {
    BOOL result = YES;

    for (id item in items) {
        if (![self itemIsIncluded:item context:context]) {
            result = NO;
            break;
        }
    }

    return result;
}

- (NSSet *)matchedItems:(id<NSFastEnumeration>)subjectGroup
          matchSelector:(SEL)selector
                context:(NSDictionary *)context {
    return [self _fileterItems:subjectGroup match:YES matchSelector:selector context:context];
}

- (NSSet *)unmatchedItems:(id<NSFastEnumeration>)subjectGroup
            matchSelector:(SEL)selector
                  context:(NSDictionary *)context {
    return [self _fileterItems:subjectGroup match:NO matchSelector:selector context:context];
}

#pragma mark - Overrides

- (NSString *)description {
    NSMutableString *result = [NSMutableString string];

    NSString *matchType = nil;
    switch (self.itemMatch) {
        case FOSItemMatchAll:
            matchType = @"MATCH_ALL";
            break;
        case FOSItemMatchAllExcept:
            matchType = @"MATCH_ALL_EXCEPT";
            break;
        case FOSItemMatchItems:
            matchType = @"MATCH_ITEMS";
            break;
    }
    [result appendString:matchType];

    [result appendString:@" ("];
    for (id<FOSExpression> expr in self.itemExpressions) {
        [result appendFormat:@" %@,", [expr description]];
    }
    [result appendString:@" )"];

    return result;
}

#pragma mark - Private Methods

- (NSSet *)_itemsForContext:(NSDictionary *)context {
    NSMutableSet *result = [NSMutableSet setWithCapacity:self.itemExpressions.count];

    for (id<FOSExpression> expr in self.itemExpressions) {
        id item = [expr evaluateWithContext:context error:nil];

        if (item != nil) {
            [result addObject:item];
        }
    }

    return result;
}

- (NSSet *)_fileterItems:(id)subjectGroup
                   match:(BOOL)match
           matchSelector:(SEL)matchSelector
                 context:(NSDictionary *)context {
    NSMutableSet *result = [NSMutableSet set];

    for (id item in subjectGroup) {
        id itemMatch = item;

        if (matchSelector != nil) {
            // This allows for dynamic invoke of a selector w/o ARC problems
            // http://stackoverflow.com/questions/7017281/performselector-may-cause-a-leak-because-its-selector-is-unknown
            IMP imp = [item methodForSelector:matchSelector];
            id (*func)(id, SEL) = (void *)imp;
            itemMatch = func(item, matchSelector);
        }

        if ([self itemIsIncluded:itemMatch context:context] == match) {
            [result addObject:item];
        }
    }

    return result;
}

@end
