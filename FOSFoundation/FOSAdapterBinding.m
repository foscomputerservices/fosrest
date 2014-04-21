//
//  FOSAdapterBinding.m
//  FOSFoundation
//
//  Created by David Hunt on 3/19/14.
//  Copyright (c) 2014 FOS Computer Services. All rights reserved.
//

#import "FOSAdapterBinding.h"
#import "FOSAdapterBindingParser.h"

@implementation FOSAdapterBinding

#pragma mark - Class Methods

+ (instancetype)adapterBindingWithFields:(NSDictionary *)fields
                             urlBindings:(NSSet *)urlBindings
                    andSharedBindings:(NSDictionary *)sharedBindings {
    FOSAdapterBinding *result = [[FOSAdapterBinding alloc] init];

    result.adapterFields = fields;
    result.urlBindings = urlBindings;
    result.sharedBindings = sharedBindings;

    [result _resolveSharedBindingReferences];

    return result;
}

+ (instancetype)parseAdapterBindingDescription:(NSString *)bindings error:(NSError **)error {
    NSParameterAssert(bindings != nil);
    if (error != nil) { *error = nil; }

    FOSAdapterBinding *result = [FOSAdapterBindingParser parseAdapterBinding:bindings
                                                                       error:error];

    return result;
}

+ (instancetype)parseAdapterBindings:(NSURL *)url error:(NSError **)error {
    NSParameterAssert(url != nil);
    if (error != nil) { *error = nil; }

    FOSAdapterBinding *result = nil;

    NSError *localError = nil;
    NSString *adapterDesc = [NSString stringWithContentsOfURL:url
                                                     encoding:NSASCIIStringEncoding
                                                        error:&localError];
    if (adapterDesc && localError == nil) {
        result = [self parseAdapterBindingDescription:adapterDesc error:&localError];
    }

    if (localError != nil) {
        if (error != nil) {
            *error = localError;
        }

        result = nil;
    }

    return result;
}

#pragma mark - Public Methods

- (id)adapterFieldValueForKey:(NSString *)key error:(NSError **)error {
    id result = nil;
    if (error != nil) { *error = nil; }

    id<FOSExpression> fieldExpr = self.adapterFields[key];

    result = [fieldExpr evaluateWithContext:nil error:error];

    return result;
}

- (FOSURLBinding *)urlBindingForLifecyclePhase:(FOSLifecyclePhase)lifecyclePhase
                               forRelationship:(NSRelationshipDescription *)relDesc
                                     forEntity:(NSEntityDescription *)entity {
    NSParameterAssert(entity != nil);
    NSParameterAssert(lifecyclePhase != FOSLifecyclePhaseRetrieveServerRecordRelationship ||
                      relDesc != nil);
    FOSURLBinding *result = nil;

    NSMutableDictionary *context = [@{ @"ENTITY" : entity } mutableCopy];
    if (relDesc != nil) {
        context[@"RELDESC"] = relDesc;
    }

    for (FOSURLBinding *binding in self.urlBindings) {
        // Match the destination entity name, not the source for relationship bindings
        NSString *entityName = lifecyclePhase == FOSLifecyclePhaseRetrieveServerRecordRelationship
            ? relDesc.entity.name
            : entity.name;

        if ((binding.entityMatcher == nil ||
            [binding.entityMatcher itemIsIncluded:entityName context:context]) &&
            binding.lifecyclePhase == lifecyclePhase &&
            (relDesc == nil ||
             [binding.relationshipMatcher itemIsIncluded:relDesc.name context:context])) {

            result = binding;
            break;
        }
    }

    return result;
}

- (id<FOSTwoWayPropertyBinding>)twoWayBindingForProperty:(NSPropertyDescription *)propDesc
                                       forLifecyclePhase:(FOSLifecyclePhase)lifecyclePhase {
    NSParameterAssert(propDesc != nil);

    FOSAttributeBinding *result = nil;

    NSDictionary *context = @{
                              @"ENTITY" : propDesc.entity,
                              ([propDesc isKindOfClass:[NSAttributeDescription class]]
                                ? @"ATTRDESC"
                                : @"RELDESC")
                              : propDesc
                            };

    NSArray *entityMatches = @[propDesc.entity];
    NSArray *propertyMatches = @[propDesc];
    for (FOSURLBinding *urlBinding in self.urlBindings) {
        if (urlBinding.lifecyclePhase == lifecyclePhase) {
            FOSCMOBinding *cmoBinding = urlBinding.cmoBinding;

            if ([cmoBinding.entityMatcher matchedItems:entityMatches
                                         matchSelector:NSSelectorFromString(@"name")
                                               context:context]) {

                for (FOSAttributeBinding *attrBinding in cmoBinding.attributeBindings) {
                    if ([attrBinding.attributeMatcher matchedItems:propertyMatches
                                                     matchSelector:NSSelectorFromString(@"name")
                                                           context:context]) {
                        result = attrBinding;
                        break;
                    }
                }
            }
        }

        if (result != nil) {
            break;
        }
    }

    return result;
}

#pragma mark - Private Methods

- (void)_resolveSharedBindingReferences {
    for (FOSURLBinding *urlBinding in self.urlBindings) {
        FOSSharedBindingReference *bindingRef = urlBinding.sharedBindingReference;
        if (bindingRef != nil) {
            urlBinding.cmoBinding = [self _cmoBinderForSharedBindingRef:bindingRef];

            // TODO : This should turn into a user-visible error
            NSAssert(urlBinding.cmoBinding != nil, @"Missing binding???");
        }
    }
}

- (FOSCMOBinding *)_cmoBinderForSharedBindingRef:(FOSSharedBindingReference *)bindingRef {
    return self.sharedBindings[bindingRef.identifier];
}

@end
