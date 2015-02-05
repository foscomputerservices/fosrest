//
//  FOSVariableExpression.m
//  FOSFoundation
//
//  Created by David Hunt on 3/17/14.
//  Copyright (c) 2014 FOS Computer Services. All rights reserved.
//

#import "FOSVariableExpression.h"
#import "FOSFoundation_Internal.h"

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
                              expectingType:[NSObject class]
                                      error:&localError];

        if (result == nil && localError == nil) {
            FOSCachedManagedObject *cmo = [self _retrieveCMO:&localError context:context];

            result = cmo.jsonIdValue;

            if (result == nil) {
                NSEntityDescription *cmoEntity = cmo.entity;
                if (cmoEntity == nil) {
                    cmoEntity = context[@"ENTITY"];
                }

                NSString *msgFmt = @"Unable to determine CMOID for entity %@ with CoreData id %@.";
                NSString *msg = [NSString stringWithFormat:msgFmt,
                                 cmoEntity.name, cmo.objectID.description];
                localError = [NSError errorWithMessage:msg forAtom:self];
            }
        }
        matched = YES;
    }
    else if ([ident isEqualToString:@"OWNERID"]) {
        result = [self _evaluateWithContext:context
                                 identifier:ident
                              expectingType:[NSObject class]
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
            result = [self.serviceAdapter valueForExpressionVariable:ident matched:&matched error:&localError];
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
                *error = [NSError errorWithMessage:msg forAtom:self];
            }
        }

        if (localError != nil || !matched) {
            result = nil;
        }
    }

    return result;
}

- (NSString *)description {
    return [NSString stringWithFormat:@"$%@", self.identifier];
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
        result = contextResult;
    }
    else if (contextResult != nil) {
        NSString *msg = [NSString stringWithFormat:@"Expected instance of type %@, got %@ for identifier %@.", NSStringFromClass(type), NSStringFromClass([contextResult class]), ident];

        *error = [NSError errorWithMessage:msg forAtom:self];
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
