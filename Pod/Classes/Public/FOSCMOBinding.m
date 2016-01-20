//
//  FOSCMOBinding.m
//  FOSRest
//
//  Created by David Hunt on 3/15/14.
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

#import <FOSCMOBinding.h>
#import "FOSREST_Internal.h"

@implementation FOSCMOBinding

#pragma mark - Class Methods

+ (instancetype)bindingWithAttributeBindings:(NSSet *)attributeBindings
                        relationshipBindings:(NSSet *)relationshipBindings
                           andEntityMatcher:(FOSItemMatcher *)entityMatcher {
    NSParameterAssert(attributeBindings != nil);
    NSParameterAssert(entityMatcher != nil);

    FOSCMOBinding *result = [[self alloc] init];
    result.attributeBindings = attributeBindings;
    result.relationshipBindings = relationshipBindings;
    result.entityMatcher = entityMatcher;

    return result;
}

#pragma mark - Public Property Overrides

- (void)setAttributeBindings:(NSSet *)attributeBindings {
    [self willChangeValueForKey:@"attributeBindings"];
    [self willChangeValueForKey:@"identityBinding"];

    _attributeBindings = attributeBindings;

    NSPredicate *pred = [NSPredicate predicateWithFormat:@"isIdentityAttribute == YES"];
    NSSet *identityProps = [_attributeBindings filteredSetUsingPredicate:pred];

    // TODO : This should be a compilation error
    NSAssert(identityProps.count <= 1, @"Multiple identity properties???");

    _identityBinding = identityProps.anyObject;

    [self didChangeValueForKey:@"identityBinding"];
    [self didChangeValueForKey:@"attributeBindings"];
}

#pragma mark - FOSTwoWayRecordBinding Methods

- (FOSJsonId)jsonIdFromJSON:(id<NSObject>)json
                  forEntity:(NSEntityDescription *)entity
                      error:(NSError **)error {
    NSParameterAssert(json != nil);
    NSParameterAssert(entity != nil);
    if (error != nil) { *error = nil; }

    FOSJsonId result = nil;
    NSError *localError = nil;

    FOSAttributeBinding *identityBinding = self.identityBinding;

    if (identityBinding != nil) {
        NSMutableDictionary *context = [@{ @"ENTITY" : entity } mutableCopy];

        NSDictionary *propsByName = entity.propertiesByName;
        NSArray *propNames = propsByName.allKeys;
        NSSet *identNames = [[identityBinding attributeMatcher] matchedItems:propNames
                                                               matchSelector:nil
                                                                     context:context];

        if (identNames.count == 0) {
            NSString *msgFmt = @"No property for entity '%@' matches the specification.";
            NSString *msg = [NSString stringWithFormat:msgFmt, entity.name];

            localError = [NSError errorWithMessage:msg forAtom:identityBinding];
        }
        else {
            context[@"ATTRDESC"] = propsByName[identNames.anyObject];

            id<NSObject> unwrappedJson = [self _unwrappedJSON:json context:context error:&localError];
            if (unwrappedJson && localError == nil) {
                result = [identityBinding jsonIdFromJSON:unwrappedJson
                                             withContext:context
                                                   error:&localError];

                if ([result isKindOfClass:[NSDictionary class]] ||
                    [result isKindOfClass:[NSArray class]]) {
                    NSString *msgFmt = @"Unexpected type '%@' received while binding ID_ATTRIBUTE for entity of type '%@'. Expected a value type from unwrapped JSON: %@ {wrapped JSON: %@}";
                    NSString *msg = [NSString stringWithFormat:msgFmt,
                                     NSStringFromClass([result class]), entity.name, unwrappedJson, json];

                    localError = [NSError errorWithMessage:msg
                                                   forAtom:identityBinding];
                }
            }
        }
    }
    else {
        NSString *msg = @"Missing identity binding!";

        localError = [NSError errorWithMessage:msg forAtom:self];
    }
    

    if (localError != nil) {
        if (error != nil) { *error = localError; }

        result = nil;
    }

    return result;
}

- (FOSJsonId)jsonIdFromJSON:(id<NSObject>)json
            forRelationship:(NSRelationshipDescription *)relDesc
                      error:(NSError **)error {
    NSParameterAssert(json != nil);
    NSParameterAssert(relDesc != nil);
    if (error != nil) { *error = nil; }

    FOSJsonId result = nil;
    NSError *localError = nil;
    BOOL foundRelBinding = NO;

    id<FOSTwoWayPropertyBinding> identityBinding = nil;
    NSDictionary *context = @{ @"ENTITY" : relDesc.destinationEntity, @"RELDESC" : relDesc };

    for (FOSRelationshipBinding *relBinding in self.relationshipBindings) {
        if ([relBinding.relationshipMatcher itemIsIncluded:relDesc.name context:context]) {
            foundRelBinding = YES;
            identityBinding = relBinding;
            break;
        }
    }

    if (identityBinding != nil) {
        json = [self _unwrappedJSON:json context:context error:&localError];
        if (json && localError == nil) {
            result = [identityBinding jsonIdFromJSON:json
                                         withContext:context
                                               error:&localError];
        }
    }
    else {
        NSString *msg = nil;

        if (foundRelBinding) {
            NSString *msgFmt = @"Missing JSON_ID_BINDING in RELATIONSHIP_BINDING for Entity '%@', a destination entity of relationship '%@' with parent Entity '%@'.";
            msg = [NSString stringWithFormat:msgFmt,
                   relDesc.destinationEntity.name,
                   relDesc.name,
                   relDesc.entity.name];
        }
        else {
            NSString *msgFmt = @"Missing RELATIONSHIP_BINDING from Entity '%@' to Entity '%@' across relationship '%@'.";
            msg = [NSString stringWithFormat:msgFmt,
                   relDesc.entity.name,
                   relDesc.destinationEntity.name,
                   relDesc.name];
        }

        localError = [NSError errorWithMessage:msg forAtom:self];
    }


    if (localError != nil) {
        if (error != nil) { *error = localError; }

        result = nil;
    }
    
    return result;
}

- (BOOL)updateJson:(NSMutableDictionary *)json
           fromCMO:(FOSCachedManagedObject *)cmo
 forLifecyclePhase:(FOSLifecyclePhase)lifecyclePhase
             error:(NSError **)error {
    NSError *localError = nil;

    BOOL result = [self _ensureCMO:cmo error:&localError];
    if (result) {
        NSSet *modifiedProps = nil;

        if (lifecyclePhase == FOSLifecyclePhaseUpdateServerRecord) {
            modifiedProps = cmo.propertiesModifiedSinceLastUpload;
        }

        NSDictionary *context = @{ @"CMO" : cmo };
        if (localError == nil && self.jsonBindingExpressions != nil) {
            for (NSArray *jsonBindingExpr in self.jsonBindingExpressions) {
                id<FOSExpression> jsonKeyExpression = jsonBindingExpr[0];
                id<FOSExpression> jsonValueExpression = jsonBindingExpr[1];

                // Evaluate the jsonValue
                id value = [jsonValueExpression evaluateWithContext:context error:&localError];

                if (localError == nil) {
                    // Evaluate the jsonKeyPath
                    NSString *jsonKeyPath = [jsonKeyExpression evaluateWithContext:context
                                                                             error:&localError];
                    if (jsonKeyPath && localError == nil) {
                        // Update the JSON dictionary (handling nested dictionaries)
                        [[FOSPropertyBinding class] setValue:value ofJson:json forKeyPath:jsonKeyPath];
                    }
                }

                if (localError != nil) {
                    break;
                }
            }
        }

        if (localError == nil) {
            json = [self _wrapJSON:json context:context error:&localError];
        }
        
        if (localError == nil) {
            // Use all property bindings
            for (id<FOSTwoWayPropertyBinding> propBinding in [self _propertyBindings]) {

                NSSet *propDescriptions = [propBinding propertyDescriptionsForEntity:cmo.entity];
                for (NSPropertyDescription *propDesc in propDescriptions) {

                    // We always add the property during creation, but we only want
                    // to add changed props on updates
                    BOOL addProp = (lifecyclePhase == FOSLifecyclePhaseCreateServerRecord);

                    if (lifecyclePhase == FOSLifecyclePhaseUpdateServerRecord) {
                        // Let's see if this property actually changed
                        for (FOSModifiedProperty *modProp in modifiedProps) {
                            if ([modProp.propertyName isEqualToString:propDesc.name]) {
                                addProp = YES;
                                break;
                            }
                        }
                    }

                    // Bind the property
                    if (addProp) {
                        result = [propBinding updateJSON:json
                                                 fromCMO:cmo
                                             forProperty:propDesc
                                       forLifecyclePhase:lifecyclePhase
                                                   error:&localError];
                    }

                    if (!result || localError != nil) {
                        break;
                    }
                }

                if (localError == nil) {
                    // Handle constant attribute descriptions
                    if ([propBinding isKindOfClass:[FOSAttributeBinding class]] &&
                        ((FOSAttributeBinding *)propBinding).isSendOnlyAttribute) {

                    }
                }
                else {
                    break;
                }
            }
        }

        if (localError == nil) {
            // There's one extra special property on FOSUser...the password.
            // We don't store this in the data model as we don't want to store
            // the password in the database, so we'll handle it manually.

            // 1st let's see if there is an attribute binding for 'password'.
            //
            // TODO : Investigate why we don't use $PASSWORD from the context instead
            //        of retrieving the property straight from the CMO.

            // Does this type have this attribute?
            // [cmo isKindOfClass:[FOSUser class]] doesn't seem to work all of the time, we'll
            // test for a set of selectors.
            if ([cmo respondsToSelector:@selector(password)] && [cmo respondsToSelector:@selector(isLoginUser)]) {
                for (FOSAttributeBinding *nextBinding in self.attributeBindings) {
                    if ([[nextBinding attributeMatcher] itemIsIncluded:@"password" context:nil]) {

                        id<FOSExpression> keyExpr = nextBinding.jsonKeyExpression;

                        NSString *attrName = [keyExpr evaluateWithContext:@{ @"ATTRDESC" : nextBinding } error:&localError];

                        if (localError == nil) {
                            id passwordVal = [cmo valueForKey:@"password"];

                            if (passwordVal != nil) {
                                json[attrName] = passwordVal;
                            }
                        }
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
forLifecyclePhase:(FOSLifecyclePhase)lifecyclePhase
            error:(NSError **)error {
    NSError *localError = nil;

    BOOL result = [self _ensureCMO:cmo error:&localError];
    if (result) {
        NSDictionary *context = @{ @"CMO" : cmo };
        id<NSObject> unwrappedJson = [self _unwrappedJSON:json context:context error:&localError];

        if (localError == nil) {
            // Use all property bindings
            for (id<FOSTwoWayPropertyBinding> propBinding in [self _propertyBindings]) {

                // Bind all properties
                NSSet *propertyDescriptions = [propBinding propertyDescriptionsForEntity:cmo.entity];
                for (NSPropertyDescription *propDesc in propertyDescriptions) {

                    // Bind the property, but only the id & read-only properties on non-retrieve phases.
                    // In other phases, the JSON may be missing values, which would cause them
                    // to be cleared.
                    if (lifecyclePhase & FOSLifecycleDirectionRetrieve ||
                        ([propBinding isKindOfClass:[FOSAttributeBinding class]] &&
                         (((FOSAttributeBinding *)propBinding).isIdentityAttribute ||
                          ((FOSAttributeBinding *)propBinding).isReceiveOnlyAttribute)
                        )) {
                        result = [propBinding updateCMO:cmo
                                               fromJSON:unwrappedJson
                                            forProperty:propDesc
                                                  error:&localError];
                    }

                    if (!result || localError != nil) {
                        break;
                    }
                }

                if (localError != nil) {
                    break;
                }
            }

            if (localError == nil) {
                id updatedJson = json;

                if (cmo.originalJson != nil) {
                    // Maybe it's not the best thing to assume that originalJson is a dictionary...not sure...
                    NSMutableDictionary *mergedDict = [((NSDictionary *)cmo.originalJson) mutableCopy];

                    // The problem here is that we might not get a *full* json dictionary back from
                    // the server, but only a parital one.  So we cannot just replace the original
                    // JSON with the new json.
                    for (id nextKey in ((NSDictionary *)json).allKeys) {
                        mergedDict[nextKey] = ((NSDictionary *)json)[nextKey];
                    }

                    updatedJson = mergedDict;
                }

                cmo.originalJsonData = [NSJSONSerialization dataWithJSONObject:updatedJson
                                                                       options:0
                                                                         error:&localError];
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

#pragma mark - Private Methods

- (NSSet *)_propertyBindings {
    NSMutableSet *attrBindings = [self.attributeBindings mutableCopy];
    [attrBindings unionSet:self.relationshipBindings];

    return attrBindings;
}

- (NSMutableSet *)_propertyDescriptionsForCMO:(FOSCachedManagedObject *)cmo {
    NSMutableSet *result = [NSMutableSet setWithCapacity:20];


    for (id<FOSTwoWayPropertyBinding> propBinding in [self _propertyBindings]) {
        NSSet *attributeDescriptions = [propBinding propertyDescriptionsForEntity:cmo.entity];

        [result unionSet:attributeDescriptions];
    }

    return result;
}

- (BOOL)_ensureCMO:(FOSCachedManagedObject *)cmo
             error:(NSError **)error {
    NSParameterAssert(error != nil);
    BOOL result = YES;

    NSDictionary *context = @{ @"CMO" : cmo };

    // Verify propertyDescriptions match entityDescriptions
    NSMutableSet *attrEntityDescriptions =
        [[self _propertyDescriptionsForCMO:cmo] valueForKeyPath:@"entity.name"];

    if (![self.entityMatcher itemsAreIncluded:attrEntityDescriptions context:context]) {
        NSString *msgFmt = @"The ATTRIBUTE_BINDINGS entities (%@) for the CMO_BINDING don't match the CMO '%@'.";
        NSString *msg = [NSString stringWithFormat:msgFmt,
                         [attrEntityDescriptions valueForKeyPath:@"self"], cmo.entity.name];

        *error = [NSError errorWithMessage:msg forAtom:self];
        result = NO;
    }

    // Verify CMO
    if (result) {
        if (![self.entityMatcher itemIsIncluded:cmo.entity.name context:context]) {
            NSString *msg = [NSString stringWithFormat:@"The entity %@ does not match any property descriptions for the property binding.", cmo.entity.name];

            *error = [NSError errorWithMessage:msg forAtom:self];

            result = NO;
        }
    }
    
    return result;
}

- (NSMutableDictionary *)_wrapJSON:(NSMutableDictionary *)json
                           context:(NSDictionary *)context
                             error:(NSError **)error {
    NSParameterAssert(json != nil);
    NSParameterAssert(context != nil);
    NSParameterAssert(error != nil);

    *error = nil;
    NSMutableDictionary *result = json;

    id<FOSExpression> wrapperKeyExpr = self.jsonSendWrapperKey == nil
        ? self.jsonWrapperKey
        : self.jsonSendWrapperKey;

    if (wrapperKeyExpr != nil) {
        NSString *wrapperKey = [wrapperKeyExpr evaluateWithContext:context error:error];
        if (wrapperKey != nil && *error == nil) {
            result = [NSMutableDictionary dictionary];
            json[wrapperKey] = result;
        }
    }

    if (*error != nil) {
        result = nil;
    }

    return result;
}

- (id<NSObject>)_unwrappedJSON:(id<NSObject>)json
                       context:(NSDictionary *)context
                         error:(NSError **)error {
    NSParameterAssert(json != nil);
    NSParameterAssert(context != nil);
    NSParameterAssert(error != nil);

    *error = nil;
    id<NSObject> result = json;

    id<FOSExpression> wrapperKeyExpr = self.jsonReceiveWrapperKey == nil
        ? self.jsonWrapperKey
        : self.jsonReceiveWrapperKey;

    if (wrapperKeyExpr != nil) {
        NSString *wrapperKey = [wrapperKeyExpr evaluateWithContext:context error:error];
        if (wrapperKey != nil && *error == nil) {
            result = [(NSObject *)json valueForKeyPath:wrapperKey];
        }

        if (result == nil && *error == nil) {
//            NSString *msgFmt = @"Unwrapping using JSON_WRAPPER_KEY '%@' lead to an empty result. Using the original JSON %@";
//
//            FOSLogPedantic(msgFmt, wrapperKey, [json description]);
            result = json;
        }
    }

    if (*error != nil) {
        result = nil;
    }

    return result;
}

@end
