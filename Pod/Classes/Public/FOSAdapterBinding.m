//
//  FOSAdapterBinding.m
//  FOSREST
//
//  Created by David Hunt on 3/19/14.
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

#import <FOSAdapterBinding.h>
#import "FOSREST_Internal.h"

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

+ (instancetype)parseAdapterBindingDescription:(NSString *)bindings
                                    forAdapter:(id<fosrestServiceAdapter>)serviceAdapter
                                         error:(NSError **)error {
    NSParameterAssert(bindings != nil);
    if (error != nil) { *error = nil; }

    FOSAdapterBinding *result = [FOSAdapterBindingParser parseAdapterBinding:bindings
                                                                  forAdapter:serviceAdapter
                                                                       error:error];

    return result;
}

+ (instancetype)parseAdapterBindings:(NSURL *)url
                          forAdapter:(id<fosrestServiceAdapter>)serviceAdapter
                               error:(NSError **)error {
    NSParameterAssert(url != nil);
    if (error != nil) { *error = nil; }

    FOSAdapterBinding *result = nil;

    NSError *localError = nil;
    NSString *adapterDesc = [NSString stringWithContentsOfURL:url
                                                     encoding:NSASCIIStringEncoding
                                                        error:&localError];
    if (adapterDesc && localError == nil) {
        result = [self parseAdapterBindingDescription:adapterDesc
                                           forAdapter:serviceAdapter
                                                error:&localError];
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
                             forLifecycleStyle:(NSString *)lifecycleStyle
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

    FOSBindingOptions bindingOptions = FOSBindingOptionsNone;

    if (relDesc != nil) {
        bindingOptions = relDesc.isToMany
            ? FOSBindingOptionsOneToManyRelationship
            : FOSBindingOptionsOneToOneRelationship;

        if (relDesc.isOrdered) {
            bindingOptions |= FOSBindingOptionsOrderedRelationship;
        }
        else {
            bindingOptions |= FOSBindingOptionsUnorderedRelationship;
        }
    }

    for (FOSURLBinding *binding in self.urlBindings) {
        // Match the destination entity name, not the source for relationship bindings
        NSString *entityName = lifecyclePhase == FOSLifecyclePhaseRetrieveServerRecordRelationship
            ? relDesc.destinationEntity.name
            : entity.name;

        if ((binding.entityMatcher == nil ||
            [binding.entityMatcher itemIsIncluded:entityName context:context]) &&
            binding.lifecyclePhase == lifecyclePhase &&
            (binding.bindingOptions & bindingOptions) == bindingOptions &&
            [binding.lifecycleStyle itemIsIncluded:lifecycleStyle context:context] &&
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

            if (urlBinding.cmoBinding == nil) {
                NSString *msgFmt = @"Unable to locate SHARED_BINDING named '%@'.";
                NSString *msg = [NSString stringWithFormat:msgFmt,
                                 urlBinding.sharedBindingReference.identifier];

                NSException *e = [NSException exceptionWithName:@"FOSREST"
                                                         reason:msg
                                                       userInfo:nil];

                @throw e;
            }
        }
    }

    NSMutableDictionary *updatedAdapterFields = [self.adapterFields mutableCopy];
    for (NSString *adapterKey in self.adapterFields.allKeys) {
        id adapterField = updatedAdapterFields[adapterKey];

        if ([adapterField isKindOfClass:[FOSSharedBindingReference class]]) {
            FOSSharedBindingReference *bindingRef = adapterField;

            adapterField = [self _cmoBinderForSharedBindingRef:bindingRef];

            // TODO : This should turn into a user-visible error
            NSAssert(adapterField != nil, @"Missing binding???");

            updatedAdapterFields[adapterKey] = adapterField;
        }
    }
    self.adapterFields = updatedAdapterFields;
}

- (FOSCMOBinding *)_cmoBinderForSharedBindingRef:(FOSSharedBindingReference *)bindingRef {
    return self.sharedBindings[bindingRef.identifier];
}

@end
