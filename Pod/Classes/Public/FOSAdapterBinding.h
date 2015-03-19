//
//  FOSAdapterBinding.h
//  FOSRest
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

#import "FOSCompiledAtom.h"
#import "FOSURLBinding.h"

@protocol FOSTwoWayPropertyBinding;
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
                                    forAdapter:(id<FOSRESTServiceAdapter>)serviceAdapter
                                         error:(NSError **)error;

/*!
 * @method parseAdapterBindings:error:
 *
 * Loads the Adapter Binding description using the given URL.  The file at the URL
 * is expected to be formatted in ASCII format.
 */
+ (instancetype)parseAdapterBindings:(NSURL *)url
                          forAdapter:(id<FOSRESTServiceAdapter>)serviceAdapter
                               error:(NSError **)error;

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
