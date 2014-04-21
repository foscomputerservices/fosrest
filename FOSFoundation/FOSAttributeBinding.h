//
//  FOSAttributeBinding.h
//  FOSFoundation
//
//  Created by David Hunt on 3/15/14.
//  Copyright (c) 2014 FOS Computer Services. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol FOSExpression;
@class FOSItemMatcher;

#pragma mark - Properties

/*!
 * @class FOSAttributeBinding
 *
 * Describes the two-way binding between a JSON Dictionary and a CMO.
 */
@interface FOSAttributeBinding : FOSPropertyBinding<FOSTwoWayPropertyBinding>

/*!
 * @methodgroup Class Methods
 */
#pragma mark - Class Methods

/*!
 * @method bindingWithJsonKeyExpression:cmoKeyPathExpression:andPropertyMatcher:
 *
 */
+ (instancetype)bindingWithJsonKeyExpression:(id<FOSExpression>)jsonKeyExpression
                        cmoKeyPathExpression:(id<FOSExpression>)cmoKeyPathExpression
                          andPropertyMatcher:(FOSItemMatcher *)propertyMatcher;

/*!
 * @group Public Properties
 */
#pragma mark - Public Properties

/*!
 * @property isIdentityProperty
 *
 * The property that holds the Server Identity of the instance.
 */
@property (nonatomic, assign) BOOL isIdentityProperty;

/*!
 * @property isReadOnlyProperty
 *
 * Identifies that this property cannot be sent to the server, only
 * pulled down.
 */
@property (nonatomic, assign) BOOL isReadOnlyProperty;

/*!
 * @property jsonKeyExpression
 *
 * A FOSBindingExpression that, when evaluated, yields a keyPath string that
 * can be applied to the JSON to get/set a value.
 *
 * Setting this property is required;
 */
@property (nonatomic, strong) id<FOSExpression> jsonKeyExpression;

/*!
 * @property cmoKeyPathExpression
 *
 * A FOSBindingExpression that, when evaluated, yields a keyPath string that
 * can be applied to the CMO to get/set a value.
 *
 * Setting this property is required;
 */
@property (nonatomic, strong) id<FOSExpression> cmoKeyPathExpression;

/*!
 * @property attributeMatcher
 *
 * The matcher that describes the attributes that can be bound by this description
 *
 * Setting this property is required;
 */
@property (nonatomic, strong) FOSItemMatcher *attributeMatcher;

@end
