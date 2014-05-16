//
//  FOSKeyPathExpression.m
//  FOSFoundation
//
//  Created by David Hunt on 3/18/14.
//  Copyright (c) 2014 FOS Computer Services. All rights reserved.
//

#import "FOSKeyPathExpression.h"

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

        localError = [NSError errorWithDomain:@"FOSFoundation" andMessage:msg];
    }
    if (self.rhs == nil) {
        NSString *msg = @"No rhs was provided.";

        localError = [NSError errorWithDomain:@"FOSFoundation" andMessage:msg];
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
                    *error = [NSError errorWithDomain:@"FOSFoundation"
                                           andMessage:exception.description];
                }
            }
            else {
                NSString *msg = [NSString stringWithFormat:@"Received an empty keyPath expression."];

                *error = [NSError errorWithDomain:@"FOSFoundation" andMessage:msg];
            }
        }
        else {
            NSString *msg = [NSString stringWithFormat:@"Expected NSString, got %@.",
                             NSStringFromClass([keyPath class])];

            *error = [NSError errorWithDomain:@"FOSFoundation" andMessage:msg];
        }
    }

    return result;
}

@end
