//
//  FOSKeyPathExpression.m
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

#import <FOSKeyPathExpression.h>
#import "FOSREST_Internal.h"

@implementation FOSKeyPathExpression

#pragma mark - Class Methods

+ (instancetype)keyPathExpressionWithLHS:(id<FOSExpression>)lhs andRHS:(id<FOSExpression>)rhs {
    FOSKeyPathExpression *result = [[FOSKeyPathExpression alloc] init];
    result.lhs = lhs;
    result.rhs = rhs;

    return result;
}

#pragma mark - FOSExpression Protocol Methods

- (id)evaluateWithContext:(NSDictionary *)context error:(NSError **)error {
    if (error != nil) { *error = nil; }
    id result = nil;

    NSError *localError = nil;

    if (self.lhs == nil) {
        NSString *msg = @"No lhs was provided.";

        localError = [NSError errorWithMessage:msg forAtom:self];
    }
    if (self.rhs == nil) {
        NSString *msg = @"No rhs was provided.";

        localError = [NSError errorWithMessage:msg forAtom:self];
    }

    if (localError == nil) {
        result = [self _evaluateWithContext:context error:&localError];
    }

    if (localError != nil) {
        if (error != nil) {
            *error = localError;
        }

        result = nil;
    }

    return result;
}

#pragma mark - Overrides

- (NSString *)description {
    return [NSString stringWithFormat:@"KeyPathExpression - LHS : %@ - RHS : %@",
            self.lhs.description, self.rhs.description ];
}

#pragma mark - Private Methods
- (id)_evaluateWithContext:(NSDictionary *)context error:(NSError **)error {
    NSParameterAssert(error != nil);
    id result = nil;

    id contextObj = [self.lhs evaluateWithContext:context error:error];
    if (contextObj != nil && *error == nil) {
        NSString *keyPath = [self.rhs evaluateWithContext:context error:error];

        if ([keyPath isKindOfClass:[NSString class]]) {
            if (keyPath.length > 0) {
                @try {
                    result = [contextObj valueForKeyPath:keyPath];
                }
                @catch (NSException *exception) {
                    *error = [NSError errorWithMessage:exception.description forAtom:self];
                }
            }
            else {
                NSString *msg = [NSString stringWithFormat:@"Received an empty keyPath expression."];

                *error = [NSError errorWithMessage:msg forAtom:self];
            }
        }
        else {
            NSString *msg = [NSString stringWithFormat:@"Expected NSString, got %@.",
                             NSStringFromClass([keyPath class])];

            *error = [NSError errorWithMessage:msg forAtom:self];
        }
    }

    return result;
}

@end
