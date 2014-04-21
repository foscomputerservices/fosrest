//
//  FOSCMOBinding.m
//  FOSFoundation
//
//  Created by David Hunt on 3/15/14.
//  Copyright (c) 2014 FOS Computer Services. All rights reserved.
//

#import "FOSCMOBinding.h"

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

    NSPredicate *pred = [NSPredicate predicateWithFormat:@"isIdentityProperty == YES"];
    NSSet *identityProps = [_attributeBindings filteredSetUsingPredicate:pred];

    // TODO : This should be a compilation error
    NSAssert(identityProps.count <= 1, @"Multiple identity properties???");

    _identityBinding = identityProps.anyObject;

    [self didChangeValueForKey:@"identityBinding"];
    [self didChangeValueForKey:@"attributeBindings"];
}

#pragma mark - FOSTwoWayRecordBinding Methods

- (FOSJsonId)jsonIdFromJSON:(NSDictionary *)json
                  forEntity:(NSEntityDescription *)entity
                      error:(NSError **)error {
    NSParameterAssert(json != nil);
    NSParameterAssert(entity != nil);
    if (error != nil) { *error = nil; }

    FOSJsonId result = nil;
    NSError *localError = nil;

    id<FOSTwoWayPropertyBinding> identityBinding = self.identityBinding;

    if (identityBinding != nil) {
        NSDictionary *context = @{ @"ENTITY" : entity };

        result = [identityBinding jsonIdFromJSON:json
                                     withContext:context
                                           error:&localError];
    }
    else {
        NSString *msg = @"Missing identity binding!";

        localError = [NSError errorWithDomain:@"FOSFoundation" andMessage:msg];
    }
    

    if (localError != nil) {
        if (error != nil) { *error = nil; }

        result = nil;
    }

    return result;
}

- (FOSJsonId)jsonIdFromJSON:(NSDictionary *)json
            forRelationship:(NSRelationshipDescription *)relDesc
                      error:(NSError **)error {
    NSParameterAssert(json != nil);
    NSParameterAssert(relDesc != nil);
    if (error != nil) { *error = nil; }

    FOSJsonId result = nil;
    NSError *localError = nil;

    id<FOSTwoWayPropertyBinding> identityBinding = nil;
    NSDictionary *context = @{ @"ENTITY" : relDesc.destinationEntity, @"RELDESC" : relDesc };

    for (FOSRelationshipBinding *relBinding in self.relationshipBindings) {
        if ([relBinding.relationshipMatcher itemIsIncluded:relDesc.name context:context]) {
            identityBinding = relBinding;
            break;
        }
    }

    if (identityBinding != nil) {
        result = [identityBinding jsonIdFromJSON:json
                                     withContext:context
                                           error:&localError];
    }
    else {
        NSString *msg = @"Missing identity binding!";

        localError = [NSError errorWithDomain:@"FOSFoundation" andMessage:msg];
    }


    if (localError != nil) {
        if (error != nil) { *error = nil; }

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
                                               error:error];
                }

                if (!result) {
                    break;
                }
            }
        }

        // There's one extra special property on FOSUser...the password.
        // We don't store this in the data model as we don't want to store
        // the password in the database, so we'll handle it manually.
        if ([cmo isKindOfClass:[FOSUser class]] && ((FOSUser *)cmo).password.length > 0) {
            json[@"password"] = ((FOSUser *)cmo).password;
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
forLifecyclePhase:(FOSLifecyclePhase)lifecyclePhase
            error:(NSError **)error {
    NSError *localError = nil;

    BOOL result = [self _ensureCMO:cmo error:&localError];
    if (result) {
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
                     (((FOSAttributeBinding *)propBinding).isIdentityProperty ||
                      ((FOSAttributeBinding *)propBinding).isReadOnlyProperty)
                    )) {
                    result = [propBinding updateCMO:cmo
                                           fromJSON:json
                                        forProperty:propDesc
                                              error:&localError];
                }

                if (!result) {
                    break;
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

#pragma mark - Private Methods

- (NSSet *)_propertyBindings {
    NSMutableSet *propBindings = [self.attributeBindings mutableCopy];
    [propBindings unionSet:self.relationshipBindings];

    return propBindings;
}

- (NSMutableSet *)_propertyDescriptionsForCMO:(FOSCachedManagedObject *)cmo {
    NSMutableSet *result = [NSMutableSet setWithCapacity:20];


    for (id<FOSTwoWayPropertyBinding> propBinding in [self _propertyBindings]) {
        NSSet *propertyDescriptions = [propBinding propertyDescriptionsForEntity:cmo.entity];

        [result unionSet:propertyDescriptions];
    }

    return result;
}

- (BOOL)_ensureCMO:(FOSCachedManagedObject *)cmo
             error:(NSError **)error {
    NSParameterAssert(error != nil);
    BOOL result = YES;

    NSDictionary *context = @{ @"CMO" : cmo };

    // Verify propertyDescriptions match entityDescriptions
    NSMutableSet *propEntityDescriptions = [[self _propertyDescriptionsForCMO:cmo] valueForKey:@"entity"];
    if (![self.entityMatcher itemsAreIncluded:propEntityDescriptions context:context]) {

        NSString *msg = @"The propertyBindings are out of sync with the entityDescriptions.";

        *error = [NSError errorWithDomain:@"FOSFoundation" andMessage:msg];
        result = NO;
    }

    // Verify CMO
    if (result) {
        if (![self.entityMatcher itemIsIncluded:cmo.entity.name context:context]) {
            NSString *msg = [NSString stringWithFormat:@"The entity %@ does not match any property descriptions for the property binding.", cmo.entity.name];

            *error = [NSError errorWithDomain:@"FOSFoundation" andMessage:msg];

            result = NO;
        }
    }
    
    return result;
}

@end
