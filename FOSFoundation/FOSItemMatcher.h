//
//  FOSItemMatcher.h
//  FOSFoundation
//
//  Created by David Hunt on 3/19/14.
//  Copyright (c) 2014 FOS Computer Services. All rights reserved.
//

#import <FOSFoundation/FOSCompiledAtom.h>

@protocol FOSExpression;

/*!
 * @typedef FOSItemMatch
 *
 * @constant FOSItemMatchAll  Ignores any items specified by the @link FOSItemMatcher/items %/link
 *                              property matching all entities in the data model.
 *
 * @constant FOSItemMatchAllExcept Matches all entities in the data model except for those that
 *                                   are listed in @link FOSItemMatcher/items %/link.
 *
 * @constant FOSItemMatchItems Matches only the entities listed in @link FOSItemMatcher/items %/link.
 */
typedef NS_ENUM(NSUInteger, FOSItemMatch) {
    FOSItemMatchAll = 0,
    FOSItemMatchAllExcept = 1,
    FOSItemMatchItems = 2
};

/*!
 * @class FOSItemMatcher
 *
 * Provides for the specification and matching against a list of instances (items).
 */
@interface FOSItemMatcher : FOSCompiledAtom

/*!
 * @methodgroup Class Methods
 */
#pragma mark - Class Methods

/*!
 * @method matcherMatchingAllItems
 */
+ (instancetype)matcherMatchingAllItems;

/*!
 * @method matcherMatchingItemExpression:
 */
+ (instancetype)matcherMatchingItemExpression:(id<FOSExpression>)itemExpression;

/*!
 * @method matcher:forItemExpression:
 */
+ (instancetype)matcher:(FOSItemMatch)match forItemExpression:(id<FOSExpression>)item;

/*!
 * @method matcher:forItemExpressions:
 */
+ (instancetype)matcher:(FOSItemMatch)match forItemExpressions:(NSSet *)itemExpressions;

/*!
 * @method matcher:forConstants:
 */
+ (instancetype)matcher:(FOSItemMatch)match forConstants:(NSSet *)constantValues;

/*!
 * @group Public Properties
 */
#pragma mark - Public Properties

/*!
 * @property itemMatch
 *
 * Describes how @link FOSItemMatcher/items %/link should be consulted during
 * the match process.
 *
 * See @link FOSItemMatch @/link for more information.
 */
@property (nonatomic, assign) FOSItemMatch itemMatch;

/*!
 * @property itemExpressions
 *
 * A list of expressions consulted during matching.
 */
@property (nonatomic, strong) NSSet *itemExpressions;

/*!
 * @methodgroup Public Methods
 */
#pragma mark - Public Methods

/*!
 * @method itemIsIncluded:context:
 *
 * Returns YES if the provided item is matched by the receiver's description.
 */
- (BOOL)itemIsIncluded:(id)item context:(NSDictionary *)context;

/*!
 * @method itemsAreIncluded:matchSelector:context:
 *
 * Returns YES if the provided items are all matched by the receiver's description.
 */
- (BOOL)itemsAreIncluded:(id<NSFastEnumeration>)items
                 context:(NSDictionary *)context;

/*!
 * @method matchedItems:matchSelector:context:
 *
 * Enumerates the subjectGroup of instances and all matches are returned.
 *
 * @discussion
 *
 * Selector is invoked on each item in subjectGroup to retrieve a value to compare
 * against the item matcher.
 */
- (NSSet *)matchedItems:(id<NSFastEnumeration>)subjectGroup
          matchSelector:(SEL)selector
                context:(NSDictionary *)context;

/*!
 * @method unmatchedItems:matchSelector:context
 *
 * Enumerates the subjectGroup of instances and all misses are returned.
 *
 * @discussion
 *
 * Selector is invoked on each item in subjectGroup to retrieve a value to compare
 * against the item matcher.
 */
- (NSSet *)unmatchedItems:(id<NSFastEnumeration>)subjectGroup
            matchSelector:(SEL)selector
                  context:(NSDictionary *)context;

@end
