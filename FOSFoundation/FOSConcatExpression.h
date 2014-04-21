//
//  FOSConcatExpression.h
//  FOSFoundation
//
//  Created by David Hunt on 3/17/14.
//  Copyright (c) 2014 FOS Computer Services. All rights reserved.
//

#import <Foundation/Foundation.h>

/*!
 * @class FOSConcatExpression
 *
 * A specialized expression evaluator that concatenates the string results of id<FOSExpression>
 * instances.
 */
@interface FOSConcatExpression : NSObject<FOSExpression>

/*!
 * @methodgroup Class Methods
 */
#pragma mark - Class Methods

+ (instancetype)concatExpressionWithExpressions:(NSArray *)expressions;

/*!
 * @group Public Properties
 */
#pragma mark - Public Properties

/*!
 * @property expressions
 *
 * An array of id<FOSExpression> instances.
 *
 */
@property (nonatomic, strong) NSArray *expressions;

@end
