//
//  FOSRelationshipBinding.h
//  FOSFoundation
//
//  Created by David Hunt on 4/11/14.
//  Copyright (c) 2014 FOS Computer Services. All rights reserved.
//

#import <Foundation/Foundation.h>

/*!
 * @class FOSRelationshipBinding
 *
 * Describes the two-way binding between a JSON Dictionary and
 * a CMO's relationship to another CMO.
 */
@interface FOSRelationshipBinding : FOSPropertyBinding<FOSTwoWayPropertyBinding>

/*!
 * @methodgroup Class Methods
 */
#pragma mark - Class Methods

/*!
 * @method bindingWithJsonBindings:destCMOBinding:relationshipMatcher:entityMatcher:
 */
+ (instancetype)bindingWithJsonBindings:(NSArray *)jsonBindingExpressions
                jsonIdBindingExpression:(id <FOSExpression>)destCMOBindingExpression
                    relationshipMatcher:(FOSItemMatcher *)relationshipMatcher
                          entityMatcher:(FOSItemMatcher *)entityMatcher;

/*!
 * @group Public Properties
 */
#pragma mark - Public Properties

/*!
 * @property jsonBindingExpressions
 *
 * An array of arrays that describe how to bind from the CMO to the JSON dictionary.
 * Each sub array of the primary array is a pair of id<FOSExpression> instances.
 *
 * The first entry in the sub array is an expression that describes the key in
 * the JSON dictionary.
 *
 * The second entry in the sub array is an expression that describes a keyPath
 * to apply to the CMO to retrieve the value to store in the JSON dictionary.
 *
 * Setting this property is required.
 */
@property (nonatomic, strong) NSArray *jsonBindingExpressions;

/*!
 * @property jsonIdBindingExpression
 *
 * An expression that describes the keyPath to apply to the JSON dictionary
 * to locate the jsonIdValue of the object to bind as the destination CMO
 * of the relationship.
 *
 * Setting this property is required.
 */
@property (nonatomic, strong) id<FOSExpression> jsonIdBindingExpression;

/*!
 * @property jsonWrapperKey
 *
 * The key that server expects objects to be wrapped under.  If the object is
 * not under any key, this value should be nil.
 *
 * @discussion
 *
 * This key is also used to look into parent-supplied results to see if parent
 * server queries might have provided the child's information.
 *
 * Setting this property is optional.
 */
@property (nonatomic, strong) id<FOSExpression> jsonWrapperKey;

/*!
 * @property relationshipMatcher
 *
 * A matcher that will match to NSRelationshipDescription.name to determine
 * which relationships the receiver describes.
 *
 * Setting this property is required.
 */
@property (nonatomic, strong) FOSItemMatcher *relationshipMatcher;

/*!
 * @property entityMatcher
 *
 * A matcher that will match NSEntityDescription.name to determine which
 * entities the receiver describes.
 *
 * Setting this property is required.
 */
@property (nonatomic, strong) FOSItemMatcher *entityMatcher;

/*!
 * @method unwrapJSON:context:error:
 *
 * If the receiver's jsonWrapperKey is specified, it will be evaluated against the
 * provided context and the resulting string will be used against (NSDictionary *)json
 * to return the inner wrapped json.
 *
 * If the receiver's jsonWrapperKey is nil, then json is returned unaltered.
 */
- (id<NSObject>)unwrapJSON:(id<NSObject>)json
                   context:(NSDictionary *)context
                     error:(NSError **)error;

@end
