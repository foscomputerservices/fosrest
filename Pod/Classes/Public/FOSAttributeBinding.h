//
//  FOSAttributeBinding.h
//  FOSRest
//
//  Created by David Hunt on 3/15/14.
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

#import "FOSPropertyBinding.h"
#import "FOSTwoWayPropertyBinding.h"

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
 * @method constantBindingWithJsonKeyExpression:cmoKeyPathExpression
 *
 */
+ (instancetype)sendOnlyBindingWithJsonKeyExpression:(id<FOSExpression>)jsonKeyExpression
                                cmoKeyPathExpression:(id<FOSExpression>)cmoKeyPathExpression;

/*!
 * @method bindingWithJsonKeyExpression:cmoKeyPathExpression:andAttributeMatcher:
 *
 */
+ (instancetype)bindingWithJsonKeyExpression:(id<FOSExpression>)jsonKeyExpression
                        cmoKeyPathExpression:(id<FOSExpression>)cmoKeyPathExpression
                         andAttributeMatcher:(FOSItemMatcher *)attributeMatcher;

/*!
 * @group Public Properties
 */
#pragma mark - Public Properties

/*!
 * @property isIdentityAttribute
 *
 * The property that holds the Server Identity of the instance.
 */
@property (nonatomic, assign) BOOL isIdentityAttribute;

/*!
 * @property isReceiveOnlyAttribute
 *
 * Identifies that this property cannot be sent to the server, only
 * pulled down.
 *
 * @discussion
 *
 * Both isReceiveOnlyAttribute and isSendOnlyAttribute cannot be true.
 */
@property (nonatomic, assign) BOOL isReceiveOnlyAttribute;

/*!
 * @property isSendOnlyAttribute
 *
 * Identifies that this property cannot be received from the server, only
 * sent to it.
 *
 * @discussion
 *
 * Both isReceiveOnlyAttribute and isSendOnlyAttribute cannot be true.
 */
@property (nonatomic, assign) BOOL isSendOnlyAttribute;

/*!
 * @property jsonKeyExpression
 *
 * A FOSBindingExpression that, when evaluated, yields a keyPath string that
 * can be applied to the JSON to get/set a value.
 *
 * Setting this property is required.
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
 * Setting this property is required, unless isSendOnlyAttribute is true.  In this
 * case, setting attributeMatcher to nil indicates that the value is a constant.
 */
@property (nonatomic, strong) FOSItemMatcher *attributeMatcher;

@end
