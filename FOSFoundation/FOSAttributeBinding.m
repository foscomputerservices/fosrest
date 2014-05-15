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

+ (instancetype)bindingWithJsonKeyExpression:(id<FOSExpression>)jsonKeyExpression
                        cmoKeyPathExpression:(id<FOSExpression>)cmoKeyPathExpression
                          andPropertyMatcher:(FOSItemMatcher *)propertyMatcher {
    FOSAttributeBinding *result = [[self alloc] init];
    result.jsonKeyExpression = jsonKeyExpression;
    result.cmoKeyPathExpression = cmoKeyPathExpression;
    result.attributeMatcher = propertyMatcher;

    return result;
}

#pragma mark - FOSTwoWayPropertyBinding Methods

- (FOSJsonId)jsonIdFromJSON:(NSDictionary *)json
                withContext:(NSDictionary *)context
                      error:(NSError **)error {
    NSParameterAssert(json != nil);
    NSParameterAssert(context != nil);
    if (error != nil) { *error = nil; }

    FOSJsonId result = nil;
    NSError *localError = nil;

    if (self.isIdentityProperty) {

        NSString *jsonKeyPath = [self.jsonKeyExpression evaluateWithContext:context
                                                                      error:&localError];

        if (jsonKeyPath && localError == nil) {
            result = [json valueForKeyPath:jsonKeyPath];
        }
    }
    else {
        NSString *msg = @"Requested jsonIdFromJSON on non-identity attribute binding";

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

- (NSSet *)propertyDescriptionsForEntity:(NSEntityDescription *)entity {
    NSMutableSet *result = [NSMutableSet set];

    NSDictionary *context = @{ @"ENTITY" : entity };

    // Not sure, should the propertyMatcher be doing this filtering?
    for (NSAttributeDescription *attrDesc in [self.attributeMatcher matchedItems:entity.properties
                                                                   matchSelector:NSSelectorFromString(@"name")
                                                                         context:context]) {

        // Must not be a CMO Property
        if ([attrDesc isKindOfClass:[NSAttributeDescription class]] &&
            !((NSAttributeDescription *)attrDesc).isCMOProperty) {
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
    if (result && !self.isReadOnlyProperty) {
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
                                                     error:&localError];

                if (value == nil) { value = [NSNull null]; }

                // Udpate the JSON dictionary (handling nested dictionaries)
                if (localError == nil) {
                    [[self class] setValue:value ofJson:json forKeyPath:jsonKeyPath];
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
                id value = [json valueForKeyPath:jsonKeyPath];

                // NOTE: We should get NSNull when the object has been set to nil. Thus,
                //       nil indicates that the property wasn't in the JSON at at all.
                if (value != nil) {

                    // Allow the FOSRESTServiceAdapter to decode the value
                    value = [[self class] decodeJSONValueToCMO:value
                                                 ofType:(NSAttributeDescription *)propDesc
                                                  error:&localError];

                    // Update the CMO's value
                    if (localError == nil) {
                        result = [[self class] shouldUpdateValueForCMO:cmo
                                                     toNewValue:value
                                                     forKeyPath:cmoKeyPath
                                                    andProperty:propDesc];
                        if (result) {
                            NSAssert(!self.isIdentityProperty || value != nil,
                                     @"Why are we clearing out the identity property???");
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

    NSDictionary *context = @{ @"CMO" : cmo, @"ATTRDESC" : propDesc };

    if (![self.attributeMatcher itemIsIncluded:propDesc.name context:context]) {
        NSString *msg = [NSString stringWithFormat:@"The property %@ does not match any property descriptions for the property binding.", propDesc.name];

        *error = [NSError errorWithDomain:@"FOSFoundation" andMessage:msg];
        result = NO;
    }

    if (result) {

        NSSet *attributeDescriptions = [self.attributeMatcher matchedItems:cmo.entity.properties
                                                             matchSelector:NSSelectorFromString(@"name")
                                                                   context:context];
        NSArray *entityDescriptions = [attributeDescriptions valueForKey:@"entity"];

        if (![entityDescriptions containsObject:cmo.entity]) {
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