//
//  FOSRelationshipBinding.h
//  FOSREST
//
//  Created by David Hunt on 4/11/14.
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

@import Foundation;
#import <FOSREST/FOSPropertyBinding.h>
#import <FOSREST/FOSTwoWayPropertyBinding.h>

@protocol FOSExpression;
@class FOSItemMatcher;

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
