//
//  FOSAdapterBinding.h
//  FOSFoundation
//
//  Created by David Hunt on 3/19/14.
//  Copyright (c) 2014 FOS Computer Services. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FOSURLBinding.h"

@class FOSAttributeBinding;

@interface FOSAdapterBinding : FOSCompiledAtom

/*!
 * @methodgroup Class Methods
 */
#pragma mark - Class Methods

/*!
 * @method adapterBindingWithFields:urlBindings:andSharedDefinitions:
 */
+ (instancetype)adapterBindingWithFields:(NSDictionary *)fields
                             urlBindings:(NSSet *)urlBindings
                    andSharedBindings:(NSDictionary *)sharedBindings;

/*!
 * @method parseAdapterBindingDescription:error:
 *
 * Parses the given binding description string.
 */
+ (instancetype)parseAdapterBindingDescription:(NSString *)bindings
                                         error:(NSError **)error;

/*!
 * @method parseAdapterBindings:error:
 *
 * Loads the Adapter Binding description using the given URL.  The file at the URL
 * is expected to be formatted in ASCII format.
 */
+ (instancetype)parseAdapterBindings:(NSURL *)url error:(NSError **)error;

/*!
 * @group Public Properties
 */
#pragma mark - Public Properties

/*!
 * @property adapterFields
 *
 * A dictionary of initialization values for a FOSRESTServiceAdapter instance.
 */
@property (nonatomic, strong) NSDictionary *adapterFields;

/*!
 * @property urlBindings
 *
 * A set of NSURLBinding instances that describe the two-way binding between
 * the REST Service and the Cached Managed Object Model.
 */
@property (nonatomic, strong) NSSet *urlBindings;

/*!
 * @property sharedBindings
 *
 * A dictionary of definitions that are shared between the urlBindings
 * definitions.
 */
@property (nonatomic, strong) NSDictionary *sharedBindings;

/*!
 * @methodgroup Public Methods
 */
#pragma mark - Public Methods

- (id)adapterFieldValueForKey:(NSString *)key error:(NSError **)error;

/*!
 * @method urlBindingForEntity:forLifecyclePhase:
 *
 * Returns the appropriate URL binding for the given entity, lifecyclePhase and lifecycleStyle.
 */
- (FOSURLBinding *)urlBindingForLifecyclePhase:(FOSLifecyclePhase)lifecyclePhase
                             forLifecycleStyle:(NSString *)lifecycleStyle
                               forRelationship:(NSRelationshipDescription *)relDesc
                                     forEntity:(NSEntityDescription *)entity;

/*!
 * @method twoWayBindingForProperty:forLifecyclePhase:
 *
 * Returns the appropriate two-way binding for the given property and lifecyclePhase.
 */
- (id<FOSTwoWayPropertyBinding>)twoWayBindingForProperty:(NSPropertyDescription *)propDesc
                                       forLifecyclePhase:(FOSLifecyclePhase)lifecyclePhase;

@end
