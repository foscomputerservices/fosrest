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

/*!
 * @category NSRelationshipDescription (FOS)
 *
 * This category provides access to key-value pairs
 * provided in the NSRelationshipDescription's userInfo
 * NSDictionary.  The names of the properties in this
 * interface correspond directly to key names that
 * are to be provided in the userInfo dictionary.
 *
 * Normally these values are set in the database
 * model modified using Xcode's database modeling
 * tools.
 *
 * These properties work in conjunction with one another
 * to resolve the relationship beween an Owner Object
 * and its dependency.
 *
 * An Owner Object is the object in the relationship
 * that has its Delete Rule == (NSCascadeDeleteRule | NSDenyDeleteRule).
 *
 * There are three relationship styles to be considered:
 *    1) one-to-one
 *    2) one-to-many
 *    3) many-to-many
 *
 * Each of the samples below is based on the data model
 * provided in FOSFoundationTests/Test Data Model/RESTTests.xcdatamodeld.
 *
 * I) One-To-One Sample
 *
 * Owner Entity: User :: FOSParseUser :: FOSUser :: ...
 * Relationship: widgets
 * jsonRelationshipQuery:
 *          GET::1/classes/Role/$roleId$
 * jsonRelationshipIdProp: N/A
 *
 * Query JSON Result:
 *
 * {
 *     "results": [{    <-- jsonRelationshipArrayNames
 *         "role": "CEO",
 *         "createdAt": "2012-12-29T14:47:15.902Z",
 *         "updatedAt": "2012-12-29T14:47:29.419Z",
 *         "objectId": "ksLgJ136O6"
 *     }]
 * }
 *
 * II) One-To-Many InnerJoin Sample:
 *
 * Owner Entity: User :: FOSParseUser :: FOSUser :: ...
 * Relationship: widgets
 * jsonRelationshipQuery:
 *          GET::1/classes/Widget?where={"user":{"__type":"Pointer","className":"_User","objectId":"$[SELFID]$"}}'
 * jsonRelationshipIdProp: user.ObjectId
 *
 * Query JSON Result:
 *
 * {
 *     "results": [{    <-- jsonRelationshipArrayNames
 *         "info": {
 *             "__type": "Pointer",
 *             "className": "WidgetInfo",
 *             "objectId": "dkUNbf1roJ"
 *         },
 *         "user": <-- jsonRelationshipFragmentKey
 *         {  <-- jsonRelationshipFragment
 *             "__type": "Pointer",
 *             "className": "_User",
 *             "objectId": "JFipEfH9ko"   <-- jsonRelationshipIdProp
 *         },
 *         "name": "widget1",
 *         "ordinal" : "1", <-- jsonOrderProp
 *         "createdAt": "2012-12-28T19:04:18.560Z",
 *         "updatedAt": "2012-12-29T13:28:44.566Z",
 *         "objectId": "cTRpha2pu7"
 *     }]
 * }
 *
 * For create/update:
 *
 * jsonRelationshipFragment:  { "user" : { "__type" : "Pointer", "className" : "_User", "objectId" : "$user.objectId$" } }
 *
 * III) Many-To-Many Sample:
 *
 *  Not yet implemented
 */
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
 * @property jsonRelationshipFragmentKey
 *
 * The default is the receiver's name.
 */
@property (nonatomic, readonly) NSString *jsonRelationshipFragmentKey;

/*!
 * @property jsonRelationshipForcePull
 *
 * Determines when the relationship should be resolved between the owner
 * and child. See FOSForcePullType for full details. The default value
 * is FOSForcePullType_Never.
 */
@property (nonatomic, readonly) FOSForcePullType jsonRelationshipForcePull;

@end
