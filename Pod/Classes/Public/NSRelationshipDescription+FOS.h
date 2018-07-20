//
//  NSRelationshipDescription+FOS.h
//  FOSRest
//
//  Created by David Hunt on 12/22/12.
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

@import CoreData;

/*!
 * @typedef FOSForcePullType
 *
 * @field FOSForcePullType_Never Never force the relationship to be resolved with the server (default). The relationship will only be resolved if either: a) Faulting is being used and the relationship is faulted, or b) The relationship is manually pulled via a manual search (FOSSearchOperation).
 *
 * @field FOSForcePullType_Always Always force the relationship to be resolved (ignores count). The relationship will be resolved immediately and automatically when the owner instance is pulled from the server.
 *
 * @field FOSForcePullType_UseCount Works like FOSForcePullType_Always, but consults the XXXCount_ count property on the owner instance to determine if there are any children to resolve.
 *
 * @discussion In the data model, the value of FOSForcePullType can be specified as either
 * the numerical value (e.g. 0, 1, 2), or the terminal name of the type (e.g. Never, Always, UseCount -- case insensitive).
 */

// NOTE: If any new values are added here, update the corresponding code in
// NSRelationshipDescription+FOS.m::jsonRelationshipForcePull!
typedef NS_ENUM(NSUInteger, FOSForcePullType) {
    FOSForcePullType_Never = 0,
    FOSForcePullType_Always = 1,
    FOSForcePullType_UseCount = 2,
};

@interface NSRelationshipDescription (FOS)

/*!
 * @property jsonOrderProp
 *
 * A string containing one or more comma separated names that identify
 * the keys by which the destination of the relationship should be ordered.
 *
 * If more than one property is specified, the consideration of the sort
 * will be from left to right with left-most property being the primary
 * sort key.
 */
@property (nonatomic, readonly) NSString *jsonOrderProp;

/*!
 * @property jsonRelationshipForcePull
 *
 * Determines when the relationship should be resolved between the owner
 * and child. See FOSForcePullType for full details. The default value
 * is FOSForcePullType_Never.
 */
@property (nonatomic, readonly) FOSForcePullType jsonRelationshipForcePull;

/*!
 * @property destinationLeafEntity
 *
 * Resolves to the leaf entity of this relationship as long as there is
 * exactly one leaf entity in the final tree.
 *
 * @discussion The issue is that the model often has relationships to entities that are not
 * abstract, but might have subtypes (possibly introduced in secondary models).
 * Thus, when we ask for the destinationEntity, we need the final subtype, not
 * just the intermediate type in the hierarcy.
 */
@property (nonatomic, readonly) NSEntityDescription *destinationLeafEntity;


@end
