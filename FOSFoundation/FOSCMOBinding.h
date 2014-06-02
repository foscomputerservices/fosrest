//
//  FOSCMOBinding.h
//  FOSFoundation
//
//  Created by David Hunt on 3/15/14.
//  Copyright (c) 2014 FOS Computer Services. All rights reserved.
//

#import <Foundation/Foundation.h>

@class FOSURLBinding;
@class FOSItemMatcher;

/*!
 * @class FOSRESTBinding
 *
 * Describes how data is bound from an instance into a FOSWebServiceRequest.
 */
@interface FOSCMOBinding : FOSCompiledAtom<FOSTwoWayRecordBinding>

/*!
 * @methodgroup Class Methods
 */
#pragma mark - Class Methods

/*!
 * @method bindingWithAttributeBindings:relationshipBindings:andEntityMatcher:
 */
+ (instancetype)bindingWithAttributeBindings:(NSSet *)attributeBindings
                       relationshipBindings:(NSSet *)relationshipBindings
                           andEntityMatcher:(FOSItemMatcher *)entityMatcher;

/*!
 * @group Public Properties
 */
#pragma mark - Public Properties

/*!
 * @property jsonWrapperKey
 *
 * The key that server expects objects to be wrapped under.  If the object is
 * not under any key, this value should be nil.
 *
 * Setting this property is optional.
 */
@property (nonatomic, strong) id<FOSExpression> jsonWrapperKey;

/*!
 * @property jsonBindingExpressions
 *
 * An array of arrays that describe additional key/value pairs to be added
 * to the resulting json.
 *
 * Each sub array of the primary array is a pair of id<FOSExpression> instances.
 *
 * The first entry in the sub array is an expression that describes the key in
 * the JSON dictionary.
 *
 * The second entry in the sub array is an expression that describes a keyPath
 * to apply to the CMO to retrieve the value to store in the JSON dictionary.
 *
 * Setting this property is optional.
 *
 * @discussion
 *
 * This is a SEND-ONLY binding to add information to the JSON as additional
 * parametrization of the request.
 */
@property (nonatomic, strong) NSArray *jsonBindingExpressions;

/*!
 * @property identityBinding
 *
 */
@property (nonatomic, readonly) FOSAttributeBinding *identityBinding;

/*!
 * @property attributeBindings
 *
 * A set of two-way binding descriptions between attributes and the data
 * transmitted to/received by the REST service.
 *
 * Setting this property is required.
 */
@property (nonatomic, strong) NSSet *attributeBindings;

/*!
 * @property relationshipBindings
 *
 * A set of two-way binding descriptions between properties and the data
 * transmitted to/received by the REST service.
 *
 * Setting this property is optional.
 */
@property (nonatomic, strong) NSSet *relationshipBindings;

/*!
 * @property entityMatcher
 *
 * A matcher that will match NSEntityDescription.name to determine which
 * entities the receiver describes.
 *
 * Setting this property is required.
 */
@property (nonatomic, strong) FOSItemMatcher *entityMatcher;


@end
