//
//  FOSConstantExpression.h
//  FOSFoundation
//
//  Created by David Hunt on 3/18/14.
//  Copyright (c) 2014 FOS Computer Services. All rights reserved.
//

#import <Foundation/Foundation.h>

/*!
 * @class FOSConstantExpression
 *
 * An expression that evaluates a single input.
 */
@interface FOSConstantExpression : NSObject<FOSExpression>

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
