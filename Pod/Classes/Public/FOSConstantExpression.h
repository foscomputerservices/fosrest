//
//  FOSConstantExpression.h
//  FOSFoundation
//
//  Created by David Hunt on 3/18/14.
//  Copyright (c) 2014 FOS Computer Services. All rights reserved.
//

#import <FOSFoundation/FOSCompiledAtom.h>
#import <FOSFoundation/FOSExpression.h>

/*!
 * @class FOSConstantExpression
 *
 * An expression that evaluates a single input.
 */
@interface FOSConstantExpression : FOSCompiledAtom<FOSExpression>

/*!
 * @methodgroup Class Methods
 */

+ (instancetype)constantExpressionWithValue:(id)value;

/*!
 * @group Public Properties
 */

/*!
 * @property value
 *
 * A value that will be returned by the expression.
 */
@property (nonatomic, strong) id value;

@end
