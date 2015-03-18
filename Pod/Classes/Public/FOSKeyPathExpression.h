//
//  FOSKeyPathExpression.h
//  FOSREST
//
//  Created by David Hunt on 3/18/14.
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
#import <FOSRest/FOSCompiledAtom.h>
#import <FOSRest/FOSExpression.h>

/*!
 * @class FOSKeyPathExpression
 *
 * An expression with two pieces: an lhs which provides context to the rhs.
 */
@interface FOSKeyPathExpression : FOSCompiledAtom<FOSExpression>

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
