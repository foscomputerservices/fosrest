//
//  FOSAttributeBinding.m
//  FOSFoundation
//
//  Created by David Hunt on 3/15/14.
//  Copyright (c) 2014 FOS Computer Services. All rights reserved.
//

#import "FOSAttributeBinding.h"

@implementation FOSAttributeBinding

#pragma mark - Class Methods

+ (instancetype)sendOnlyBindingWithJsonKeyExpression:(id<FOSExpression>)jsonKeyExpression
                                cmoKeyPathExpression:(id<FOSExpression>)cmoKeyPathExpression {
    NSParameterAssert(jsonKeyExpression != nil);
    NSParameterAssert(cmoKeyPathExpression != nil);

    FOSAttributeBinding *result = [[self alloc] init];
    result.jsonKeyExpression = jsonKeyExpression;
    result.cmoKeyPathExpression = cmoKeyPathExpression;
    result.isReceiveOnlyAttribute = NO;
    result.isSendOnlyAttribute = YES;

    return result;
}

+ (instancetype)bindingWithJsonKeyExpression:(id<FOSExpression>)jsonKeyExpression
                        cmoKeyPathExpression:(id<FOSExpression>)cmoKeyPathExpression
                          andAttributeMatcher:(FOSItemMatcher *)attributeMatcher {
    NSParameterAssert(jsonKeyExpression != nil);
    NSParameterAssert(cmoKeyPathExpression != nil);
    NSParameterAssert(attributeMatcher != nil);

    FOSAttributeBinding *result = [[self alloc] init];
    result.jsonKeyExpression = jsonKeyExpression;
    result.cmoKeyPathExpression = cmoKeyPathExpression;
    result.attributeMatcher = attributeMatcher;

    return result;
}

#pragma mark - FOSTwoWayPropertyBinding Methods

- (FOSJsonId)jsonIdFromJSON:(id<NSObject>)json
                withContext:(NSDictionary *)context
                      error:(NSError **)error {
    NSParameterAssert(json != nil);
    NSParameterAssert(context != nil);
    if (error != nil) { *error = nil; }

    FOSJsonId result = nil;
    NSError *localError = nil;

    if (self.isIdentityAttribute) {

        NSString *jsonKeyPath = [self.jsonKeyExpression evaluateWithContext:context
                                                                      error:&localError];

        if (jsonKeyPath && localError == nil) {
            result = [(NSObject *)json valueForKeyPath:jsonKeyPath];

            // FF-10 TODO: Decode this value correctly
            if ([result isKindOfClass:[NSNull class]]) {
                result = nil;
            }
        }
    }
    else {
        NSString *msg = @"Requested jsonIdFromJSON on non-identity attribute binding";

        localError = [NSError errorWithMessage:msg forAtom:self];
    }

    if (localError != nil) {
        if (error != nil) {
            *error = localError;
        }

        result = nil;
    }

    return result;
}

- (NSSet *)propertyDescriptionsForEntity:(NSEntityDescription *)entity {
    NSMutableSet *result = [NSMutableSet set];

    NSDictionary *context = @{ @"ENTITY" : entity };

    // Not sure, should the propertyMatcher be doing this filtering?
    for (NSAttributeDescription *attrDesc in [self.attributeMatcher matchedItems:entity.properties
                                                                   matchSelector:NSSelectorFromString(@"name")
                                                                         context:context]) {

        // Must not be a CMO Property
        if ([attrDesc isKindOfClass:[NSAttributeDescription class]] && !attrDesc.isFOSAttribute) {
            [result addObject:attrDesc];
        }
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
    NSParameterAssert([propDesc isKindOfClass:[NSAttributeDescription class]]);
    if (error != nil) { *error = nil; }

    NSError *localError = nil;

    BOOL result = [self _ensureCMO:cmo andProp:propDesc error:error];
    if (result &&
        !self.isReceiveOnlyAttribute &&
        // Don't push the identity property on create, there won't be one...
        !(lifecyclePhase == FOSLifecyclePhaseCreateServerRecord && self.isIdentityAttribute)) {
        NSDictionary *context = @{ @"CMO" : cmo, @"ATTRDESC" : propDesc };

        // Evaluate the cmoKeyPath
        id cmoKeyPath = [self.cmoKeyPathExpression evaluateWithContext:context error:&localError];
        if (localError == nil) {

            // Evaluate the jsonKeyPath
            NSString *jsonKeyPath = [self.jsonKeyExpression evaluateWithContext:context
                                                                          error:&localError];
            if (jsonKeyPath && localError == nil) {

                // Bind the CMO value
                id value = [cmo valueForKeyPath:cmoKeyPath];

                // Allow the FOSRESTServiceAdapter to encode the value
                value = [[self class] encodeCMOValueToJSON:value
                                                    ofType:(NSAttributeDescription *)propDesc
                                        withServiceAdapter:self.serviceAdapter
                                                     error:&localError];

                // Update the JSON dictionary (handling nested dictionaries)
                if (localError == nil) {
                    // Don't set nil values on create
                    if (!(lifecyclePhase == FOSLifecyclePhaseCreateServerRecord &&
                          value == [NSNull null])) {
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
         fromJSON:(id<NSObject>)json
      forProperty:(NSPropertyDescription *)propDesc
            error:(NSError **)error {
    NSParameterAssert(cmo != nil);
    NSParameterAssert(json != nil);
    if (error != nil) { *error = nil; }

    NSError *localError = nil;

    BOOL result = [self _ensureCMO:cmo andProp:propDesc error:&localError];
    if (result) {
        NSDictionary *context = @{ @"CMO" : cmo, @"ATTRDESC" : propDesc };

        // Evaluate the jsonKeyPath
        NSString *jsonKeyPath = [self.jsonKeyExpression evaluateWithContext:context error:&localError];
        if (jsonKeyPath && localError == nil) {

            // Evaluate the cmoKeyPath
            id cmoKeyPath = [self.cmoKeyPathExpression evaluateWithContext:context error:&localError];
            if (localError == nil) {

                // Bind the JSON value
                // TODO : valueForKeyPath will throw if a dotted key path is provided that
                //        doesn't exist in the json.  Probably need to build our own... :(
                id value = [(id)json valueForKeyPath:jsonKeyPath];

                // NOTE: We should get NSNull when the object has been set to nil. Thus,
                //       nil indicates that the property wasn't in the JSON at at all.
                if (value != nil) {

                    // Allow the FOSRESTServiceAdapter to decode the value
                    value = [[self class] decodeJSONValueToCMO:value
                                                        ofType:(NSAttributeDescription *)propDesc
                                            withServiceAdapter:self.serviceAdapter
                                                  error:&localError];

                    // Update the CMO's value
                    if (localError == nil) {
                        result = [[self class] shouldUpdateValueForCMO:cmo
                                                     toNewValue:value
                                                     forKeyPath:cmoKeyPath
                                                    andProperty:propDesc];
                        if (result) {
                            NSAssert(!self.isIdentityAttribute || value != nil,
                                     @"Why are we clearing out the identity property???");

                            // It's not required that the CMO implement all keys that
                            // might be received from the server.
                            @try {
                                [cmo setValue:value forKeyPath:cmoKeyPath];
                            }
                            @catch (NSException *e) {
                                if (e != nil) {
                                    NSString *msgFmt = @"The CMO doesn't implement the specified CMO KeyPath: '%@' in the mapping from JSON Key: %@. (Error: %@)";
                                    NSString *msg = [NSString stringWithFormat:msgFmt,
                                                     cmoKeyPath, jsonKeyPath, e.description];

                                    localError = [NSError errorWithMessage:msg forAtom:self];
                                }
                            }
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

    if (self.attributeMatcher != nil) {
        NSDictionary *context = @{ @"CMO" : cmo, @"ATTRDESC" : propDesc };

        if (![self.attributeMatcher itemIsIncluded:propDesc.name context:context]) {
            NSString *msg = [NSString stringWithFormat:@"The property %@ does not match any property descriptions for the property binding.", propDesc.name];

            *error = [NSError errorWithMessage:msg forAtom:self];
            result = NO;
        }

        if (result) {

            NSSet *attributeDescriptions = [self.attributeMatcher matchedItems:cmo.entity.properties
                                                                 matchSelector:NSSelectorFromString(@"name")
                                                                       context:context];
            NSArray *entityDescriptions = [attributeDescriptions valueForKey:@"entity"];

            if (![entityDescriptions containsObject:cmo.entity]) {
                NSString *msg = [NSString stringWithFormat:@"The entity %@ does not match any property descriptions for the property binding.", cmo.entity.name];

                *error = [NSError errorWithMessage:msg forAtom:self];

                result = NO;
            }
        }
    }

    return result;
}

@end
