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
@interface FOSCMOBinding : NSObject<FOSTwoWayRecordBinding>

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
