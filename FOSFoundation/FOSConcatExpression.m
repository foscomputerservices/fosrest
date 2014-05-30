//
//  FOSConcatExpression.m
//  FOSFoundation
//
//  Created by David Hunt on 3/17/14.
//  Copyright (c) 2014 FOS Computer Services. All rights reserved.
//

#import "FOSConcatExpression.h"
#import "FOSVariableExpression.h"

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

            // Only strings can be realized if there are multiple expressions
            if (![exprResult isKindOfClass:[NSString class]]) {
                NSString *msg = [NSString stringWithFormat:@"Received type %@ during evaluation of concatenating expressions.  Only NSString types are allowed.",
                                 NSStringFromClass([exprResult class])];

                localError = [NSError errorWithMessage:msg forAtom:self];

                break;
            }
            else {
                NSString *exprStr = (NSString *)exprResult;

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
