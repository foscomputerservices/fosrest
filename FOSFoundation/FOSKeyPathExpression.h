//
//  FOSKeyPathExpression.h
//  FOSFoundation
//
//  Created by David Hunt on 3/18/14.
//  Copyright (c) 2014 FOS Computer Services. All rights reserved.
//

#import <Foundation/Foundation.h>

/*!
 * @class FOSKeyPathExpression
 *
 * An expression with two pieces: an lhs which provides context to the rhs.
 */
@interface FOSKeyPathExpression : NSObject<FOSExpression>

/*!
 * @methodgroup Class Methods
 */
#pragma mark - Class Methods

+ (instancetype)keyPathExpressionWithLHS:(id<FOSExpression>)lhs andRHS:(id<FOSExpression>)rhs;

/*!
 * @group Public Properties
 */
#pragma mark - Public Properties

/*!
 * @property lhs
 *
 * An expression that provides a context object on which @link rhs @/link is invoked.
 */
@property (nonatomic, strong) id<FOSExpression> lhs;

/*!
 * @property rhs
 *
 * An id<FOSExpression> instance that yields an NSString that defines a keyPath to
 * be applied to lhs.
 */
@property (nonatomic, strong) id<FOSExpression> rhs;

@end
