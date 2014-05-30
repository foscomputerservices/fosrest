//
//  FOSConstantExpression.m
//  FOSFoundation
//
//  Created by David Hunt on 3/18/14.
//  Copyright (c) 2014 FOS Computer Services. All rights reserved.
//

#import "FOSConstantExpression.h"

@implementation FOSConstantExpression

#pragma mark - Class Methods

+ (instancetype)constantExpressionWithValue:(id)value {
    FOSConstantExpression *result = [[FOSConstantExpression alloc] init];
    result.value = value;

    return result;
}

#pragma mark - FOSExpression Protocol Methods

- (id)evaluateWithContext:(NSDictionary *)context error:(NSError **)error {
    if (error != nil) { *error = nil; }

    id result = self.value;

    // Constants should not be expressions
    if ([result conformsToProtocol:@protocol(FOSExpression)]) {
        if (error != nil) {
            NSString *msg = [NSString stringWithFormat:@"Constant values should not be expressions."];

            *error = [NSError errorWithMessage:msg forAtom:self];
        }

        result = nil;
    }

    return result;
}

#pragma mark - Overrides

- (NSString *)description {
    return [self.value description];
}

@end
