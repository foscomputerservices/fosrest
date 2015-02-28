//
//  FOSConcatExpression.m
//  FOSFoundation
//
//  Created by David Hunt on 3/17/14.
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

#import <FOSConcatExpression.h>
#import "FOSFoundation_Internal.h"

@implementation FOSConcatExpression

#pragma mark - Class Methods

+ (instancetype)concatExpressionWithExpressions:(NSArray *)expressions {
    FOSConcatExpression *result = [[FOSConcatExpression alloc] init];
    result.expressions = expressions;

    return result;
}

#pragma mark - FOSExpression Protocol Methods

- (id)evaluateWithContext:(NSDictionary *)context error:(NSError **)error {
    if (error != nil) { *error = nil; }

    NSString *result = [self _bindMultipleWithContext:context error:error];

    return result;
}

#pragma mark - Overrides

- (NSString *)description {
    NSMutableString *result = [NSMutableString string];

    for (id<FOSExpression> nextExpr in self.expressions) {
        [result appendString:result.length == 0 ? @"( " : @" + "];

        [result appendString:nextExpr.description];
    }

    [result appendString:@" )"];

    return result;
}

#pragma mark - Private Methods

- (NSString *)_bindMultipleWithContext:(NSDictionary *)context error:(NSError **)error {
    NSString *result = nil;

    NSUInteger exprCount = self.expressions.count;
    NSMutableString *mutableBuffer = nil;

    NSError *localError = nil;
    for (id <FOSExpression> nextExpr in self.expressions) {

        NSString *exprResult = nil;

        if (![nextExpr conformsToProtocol:@protocol(FOSExpression)]) {
            NSString *msg = [NSString stringWithFormat:@"The class %@ does not conform to FOSExpression and thus cannot be concatenated.",
                             NSStringFromClass([nextExpr class])];
            localError = [NSError errorWithMessage:msg forAtom:self];
        }
        else {
            exprResult = [nextExpr evaluateWithContext:context error:&localError];
        }

        if (exprResult != nil && localError == nil) {

            if ([exprResult isKindOfClass:[NSNumber class]]) {
                exprResult = ((NSNumber *)exprResult).description;
            }

            // Only strings can be realized if there are multiple expressions
            if (![exprResult isKindOfClass:[NSString class]]) {
                NSString *msg = [NSString stringWithFormat:@"Received type %@ during evaluation of concatenating expressions; only NSString types are allowed.",
                                 NSStringFromClass([exprResult class])];

                localError = [NSError errorWithMessage:msg forAtom:self];

                break;
            }
            else {
                NSString *exprStr = exprResult;

                if (mutableBuffer == nil) {

                    // Short cut out, for singleton. No need to create an mutable instance.
                    if (exprCount == 1) {
                        result = (NSMutableString *)exprStr;
                    }

                    // Create the mutable buffer for concatenation
                    else {
                        mutableBuffer = [NSMutableString stringWithCapacity:exprStr.length + 64];
                        result = mutableBuffer;
                    }
                }

                if (mutableBuffer != nil) {
                    [mutableBuffer appendString:exprStr];
                }
            }
        }
        else if (localError != nil) {
            break;
        }
    }

    if (localError != nil) {
        if (error != nil) {
            *error = localError;
        }
        result = nil;
    }
    
    return result;
}

@end
