//
//  FOSVariableExpression.m
//  FOSFoundation
//
//  Created by David Hunt on 3/17/14.
//  Copyright (c) 2014 FOS Computer Services. All rights reserved.
//

#import "FOSVariableExpression.h"

@implementation FOSVariableExpression

#pragma mark - Class Methods

+ (instancetype)variableExpressionWithIdentifier:(NSString *)identifier {
    FOSVariableExpression *result = [[FOSVariableExpression alloc] init];
    result.identifier = identifier;

    return result;
}

#pragma mark - FOSExpression Protocol Methods

- (id)evaluateWithContext:(NSDictionary *)context error:(NSError **)error {
    id result = nil;
    if (error != nil) { *error = nil; }

    NSError *localError = nil;
    BOOL matched = NO;

    NSString *ident = self.identifier;

    if (ident == nil || [ident isEqualToString:@"CMO"]) {
        result = [self _retrieveCMO:&localError context:context];

        matched = YES;
    }
    else if ([ident isEqualToString:@"ENTITY"]) {
        result = [self _evaluateWithContext:context
                                 identifier:ident
                              expectingType:[NSEntityDescription class]
                                      error:&localError];

        if (result == nil && localError == nil) {
            FOSCachedManagedObject *cmo = [self _retrieveCMO:&localError context:context];

            result = cmo.entity;
        }
        matched = YES;
    }
    else if ([ident isEqualToString:@"CMOID"]) {
        result = [self _evaluateWithContext:context
                                 identifier:ident
                              expectingType:[NSString class]
                                      error:&localError];

        if (result == nil && localError == nil) {
            FOSCachedManagedObject *cmo = [self _retrieveCMO:&localError context:context];

            result = cmo.jsonIdValue;
        }
        matched = YES;
    }
    else if ([ident isEqualToString:@"OWNERID"]) {
        result = [self _evaluateWithContext:context
                                 identifier:ident
                              expectingType:[NSString class]
                                      error:&localError];

        if (result == nil && localError == nil) {
            FOSCachedManagedObject *cmo = [self _retrieveCMO:&localError context:context];

            result = cmo.owner.jsonIdValue;
        }
        matched = YES;
    }
    else if ([ident isEqualToString:@"ATTRDESC"] ||
             [ident isEqualToString:@"RELDESC"]) {
        result = [self _evaluateWithContext:context
                                 identifier:ident
                              expectingType:[NSPropertyDescription class]
                                      error:&localError];
        matched = result != nil;;
    }
    else {
        result = context[ident];

        // Try to find the identifier directly in the context
        if (result == nil) {
            // Try FOSRestServiceAdapter
            id<FOSRESTServiceAdapter> adapter = [FOSRESTConfig sharedInstance].restServiceAdapter;

            result = [adapter valueForExpressionVariable:ident matched:&matched error:&localError];
        }
    }

    if ([result isKindOfClass:[NSNull class]]) {
        result = nil;
    }

    else if (result == nil || localError != nil) {
        if (error != nil) {
            if (localError != nil) {
                *error = localError;
            }
            else if (!matched) {
                NSString *msg = [NSString stringWithFormat:@"Unknown identifier: %@.", ident];
                *error = [NSError errorWithDomain:@"FOSFoundation" andMessage:msg];
            }
        }

        if (localError != nil || !matched) {
            result = nil;
        }
    }

    return result;
}

#pragma mark - Private Methods

- (id)_evaluateWithContext:(NSDictionary *)context
                identifier:(NSString *)ident
             expectingType:(Class)type
                     error:(NSError **)error {
    NSParameterAssert(error != nil);
    id result = nil;

    id contextResult = context[ident];

    if ([contextResult isKindOfClass:type]) {
        // Cast really isn't necessary, but it demonstrates what we're expecting
        result = (NSRelationshipDescription *)contextResult;
    }
    else if (contextResult != nil && error != nil) {
        NSString *msg = [NSString stringWithFormat:@"Expected instance of type %@, got %@ for identifier %@.", NSStringFromClass(type), NSStringFromClass([contextResult class]), ident];

        *error = [NSError errorWithDomain:@"FOSFoundation" andMessage:msg];
    }

    return result;
}

- (id)_retrieveCMO:(NSError **)error context:(NSDictionary *)context {
    id result = [self _evaluateWithContext:context
                                identifier:@"CMO"
                             expectingType:[FOSCachedManagedObject class]
                                     error:error];

    return result;
}

@end