//
//  NSRelationshipDescription+FOS.h
//  FOSFoundation
//
//  Created by David Hunt on 12/22/12.
//  Copyright (c) 2012 FOS Computer Services. All rights reserved.
//

#import <CoreData/CoreData.h>

/*!
 * @typedef FOSForcePullType
 *
 * @field FOSForcePullType_Never Never force the relationship to be resolved with the server (default). The relationship will only be resolved if either: a) Faulting is being used and the relationship is faulted, or b) The relationship is manually pulled via a manual search (FOSSearchOperation).
 *
 * @field FOSForcePullType_Always Always force the relationship to be resolved (ignores count). The relationship will be resolved immediately and automatically when the owner instance is pulled from the server.
 *
 * @field FOSForcePullType_UseCount Works like FOSForcePullType_Always, but consults the XXXCount_ count property on the owner instance to deteremine if there are any children to resolve.
 *
 * @discussion
 *
 * In the data model, the value of FOSForcePullType can be specified as either
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
 * the keys by which the destination of the relationship should be ordred.
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

@end
