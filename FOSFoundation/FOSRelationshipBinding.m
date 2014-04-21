//
//  FOSRelationshipBinding.m
//  FOSFoundation
//
//  Created by David Hunt on 4/11/14.
//  Copyright (c) 2014 FOS Computer Services. All rights reserved.
//

#import "FOSRelationshipBinding.h"

@implementation FOSRelationshipBinding

#pragma mark - Class Methods

+ (instancetype)bindingWithJsonBindings:(NSArray *)jsonBindingExpressions
                jsonIdBindingExpression:(id <FOSExpression>)destCMOBindingExpression
                    relationshipMatcher:(FOSItemMatcher *)relationshipMatcher
                          entityMatcher:(FOSItemMatcher *)entityMatcher {
    NSParameterAssert(jsonBindingExpressions != nil);
    NSParameterAssert(destCMOBindingExpression != nil);
    NSParameterAssert(relationshipMatcher != nil);
    NSParameterAssert(entityMatcher != nil);

    FOSRelationshipBinding *result = [[self alloc] init];
    result.jsonBindingExpressions = jsonBindingExpressions;
    result.jsonIdBindingExpression = destCMOBindingExpression;
    result.relationshipMatcher = relationshipMatcher;
    result.entityMatcher = entityMatcher;

    return result;
}

#pragma mark - FOSTwoWayPropertyBinding Methods

- (NSSet *)propertyDescriptionsForEntity:(NSEntityDescription *)entity {
    NSMutableSet *result = [NSMutableSet set];
    NSDictionary *context = @{ @"ENTITY" : entity };

    for (NSPropertyDescription *propDesc in entity.properties) {

        // Also much match the relationshipMatcher
        if ([self.relationshipMatcher itemIsIncluded:propDesc.name context:context]) {
            if ([propDesc isKindOfClass:[NSRelationshipDescription class]]) {
                [result addObject:propDesc];
            }
        }
    }

    return result;
}

- (FOSJsonId)jsonIdFromJSON:(NSDictionary *)json
                withContext:(NSDictionary *)context
                      error:(NSError **)error {
    NSParameterAssert(json != nil);
    NSParameterAssert(context != nil);
    if (error != nil) { *error = nil; }

    FOSJsonId result = nil;
    NSError *localError = nil;

    if (self.jsonIdBindingExpression != nil) {

        NSString *jsonKeyPath = [self.jsonIdBindingExpression evaluateWithContext:context
                                                                            error:&localError];
        if (jsonKeyPath && localError == nil) {
            result = [json valueForKeyPath:jsonKeyPath];
        }
    }
    else {
        NSString *msg = @"Missing jsonIdBindingExpression";

        localError = [NSError errorWithDomain:@"FOSFoundation" andMessage:msg];
    }

    if (localError != nil) {
        if (error != nil) {
            *error = localError;
        }

        result = nil;
    }

    return result;
}

- (BOOL)updateJSON:(NSMutableDictionary *)json
           fromCMO:(FOSCachedManagedObject *)cmo
       forProperty:(NSPropertyDescription *)propDesc
 forLifecyclePhase:(FOSLifecyclePhase)lifecyclePhase
             error:(NSError **)error {
    NSParameterAssert(json != nil);
    NSParameterAssert(cmo != nil);
    NSParameterAssert(propDesc != nil);
    NSParameterAssert([propDesc isKindOfClass:[NSRelationshipDescription class]]);
    if (error != nil) { *error = nil; }

    NSError *localError = nil;

    BOOL result = [self _ensureCMO:cmo andProp:propDesc error:error];

    // TODO : Testing 'isToMany' doesn't seem quite right.  We're trying to ensure that
    //        we only place singleton keys into the JSON, but this test feels wrong.
    //        However, at the moment we're not supporting many-to-many right now...
    if (result && !((NSRelationshipDescription *)propDesc).isToMany) {
        NSDictionary *context = @{ @"CMO" : cmo, @"RELDESC" : propDesc };

        for (NSArray *jsonBindingExpr in self.jsonBindingExpressions) {

            id<FOSExpression> jsonKeyExpression = jsonBindingExpr[0];
            id<FOSExpression> cmoKeyPathExpression = jsonBindingExpr[1];

            BOOL addRelationValue = YES;

            if (lifecyclePhase == FOSLifecyclePhaseCreateServerRecord) {
                // Do we have a value for the relation at all? No reason to send nil
                // values for non-existent relatinoships during create phase.
                addRelationValue = ([cmo valueForKeyPath:propDesc.name] != nil);
            }

            if (addRelationValue) {

                // Evaluate the cmoKeyPath
                id value = [cmoKeyPathExpression evaluateWithContext:context error:&localError];
                if (value == nil) { value = [NSNull null]; }

                if (localError == nil) {

                    // Evaluate the jsonKeyPath
                    NSString *jsonKeyPath = [jsonKeyExpression evaluateWithContext:context
                                                                             error:&localError];
                    if (jsonKeyPath && localError == nil) {
                        // Udpate the JSON dictionary (handling nested dictionaries)
                        [[self class] setValue:value ofJson:json forKeyPath:jsonKeyPath];
                    }
                }
            }
        }
    }

    if (localError != nil) {
        if (error != nil) {
            *error = localError;
        }

        result = NO;
    }

    return result;
}

- (BOOL)updateCMO:(FOSCachedManagedObject *)cmo
         fromJSON:(NSDictionary *)json
      forProperty:(NSPropertyDescription *)propDesc
            error:(NSError **)error {
    NSParameterAssert(cmo != nil);
    NSParameterAssert(json != nil);
    NSParameterAssert(propDesc != nil);
    NSParameterAssert([propDesc isKindOfClass:[NSRelationshipDescription class]]);
    if (error != nil) { *error = nil; }

    NSError *localError = nil;

    BOOL result = [self _ensureCMO:cmo andProp:propDesc error:&localError];
    if (result) {
        NSDictionary *context = @{ @"CMO" : cmo, @"RELDESC" : propDesc };

        // TODO : Certianly these aren't always going to be the same, we'll
        //        need to add a json back binding as the forward won't always work either.
        id<FOSExpression> jsonKeyExpression = self.jsonIdBindingExpression;
        id<FOSExpression> cmoKeyPathExpression = self.jsonIdBindingExpression;

        // Evaluate the jsonKeyPath
        NSString *jsonKeyPath = [jsonKeyExpression evaluateWithContext:context error:&localError];
        if (jsonKeyPath && localError == nil) {

            // Evaluate the cmoKeyPath
            id cmoKeyPath = [cmoKeyPathExpression evaluateWithContext:context error:&localError];
            if (localError == nil) {

                // Bind the JSON value
                id value = [json valueForKeyPath:jsonKeyPath];

                // TODO : Review, this cannot be quite right as we cannot disconnect
                //        instances, but there's more to do here.

                if (value != nil) {

                    // Update the CMO's value
                    if (localError == nil) {
                        result = [[self class] shouldUpdateValueForCMO:cmo
                                                            toNewValue:value
                                                            forKeyPath:cmoKeyPath
                                                           andProperty:propDesc];
                        if (result) {
                            NSAssert([cmoKeyPath rangeOfString:@"objectId"].location == NSNotFound ||
                                     value != nil, @"Why are we setting the id to nil???");
                            [cmo setValue:value forKeyPath:cmoKeyPath];
                        }
                    }
                }
            }
        }
    }

    if (localError != nil) {
        if (error != nil) {
            *error =localError;
        }

        result = NO;
    }

    return result;
}

#pragma mark - Private Methods

- (BOOL)_ensureCMO:(FOSCachedManagedObject *)cmo
           andProp:(NSPropertyDescription *)propDesc
             error:(NSError **)error {
    NSParameterAssert(error != nil);
    BOOL result = YES;

    NSDictionary *context = @{ @"CMO" : cmo, @"RELDESC" : propDesc };

    if (![self.relationshipMatcher itemIsIncluded:propDesc.name context:context]) {
        NSString *msg = [NSString stringWithFormat:@"The relationship %@ does not match any relationship descriptions for the relationship binding.", propDesc.name];

        *error = [NSError errorWithDomain:@"FOSFoundation" andMessage:msg];
        result = NO;
    }

    if (![self.entityMatcher itemIsIncluded:cmo.entity.name context:context]) {
        NSString *msg = [NSString stringWithFormat:@"The CMO %@ does not match any entity descriptions for the relationship binding.", cmo.entity.name];

        *error = [NSError errorWithDomain:@"FOSFoundation" andMessage:msg];
        result = NO;
    }

    if (result) {
        if (![self.entityMatcher itemIsIncluded:cmo.entity.name context:context]) {
            if (error) {
                NSString *msg = [NSString stringWithFormat:@"The entity %@ does not match any property descriptions for the property binding.", cmo.entity.name];

                *error = [NSError errorWithDomain:@"FOSFoundation" andMessage:msg];
            }

            result = NO;
        }
    }

    return result;
}

@end
