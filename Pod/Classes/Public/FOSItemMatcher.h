//
//  FOSItemMatcher.h
//  FOSRest
//
//  Created by David Hunt on 3/19/14.
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

@import Foundation;
#import "FOSCompiledAtom.h"
#import "FOSItemMatch.h"

@protocol FOSExpression;

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
