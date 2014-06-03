//
//  NSEntityDescription+FOS_Internal.h
//  FOSFoundation
//
//  Created by David Hunt on 12/28/12.
//  Copyright (c) 2012 FOS Computer Services. All rights reserved.
//

#import <CoreData/CoreData.h>
#import "FOSCacheManager.h"
#import "FOSWebServiceRequest.h"
#import "FOSRetrieveCMOOperation.h"

@class FOSUser;

@interface NSEntityDescription (FOS_Internal)

#pragma mark - Public Properties
@property (nonatomic, readonly) BOOL isFOSEntity;

/*!
 * @property leafEntities
 *
 *
 */
@property (nonatomic, readonly) NSSet *leafEntities;
@property (nonatomic, readonly) NSSet *flattenedRelationships;
@property (nonatomic, readonly) BOOL hasMultipleOwnerRelationships;
@property (nonatomic, readonly) NSSet *ownerRelationships;
@property (nonatomic, readonly) NSSet *flattenedOwnershipRelationships;
@property (nonatomic, readonly) BOOL isStaticTableEntity;

/*!
 * @method nonFOSRelationships
 *
 * The set of properties that are of type NSAttributeDescription and
 * !relDesc.isFOSProperty.
 */
@property (nonatomic, readonly) NSSet *cmoAttibutes;

/*!
 * @method cmoRelationships
 *
 * The set of properties that are of type NSRelationshipDescription and
 * !relDesc.isFOSRelationship.
 */
@property (nonatomic, readonly) NSSet *cmoRelationships;

/*!
 * @method cmoToOneRelationships
 *
 * The set of properties that are of type NSRelationshipDescription and
 * !relDesc.isFOSRelationship && !relDesc.isToMany.
 */
@property (nonatomic, readonly) NSSet *cmoToOneRelationships;

/*!
 * @method cmoToManyRelationships
 *
 * The set of properties that are of type NSRelationshipDescription and
 * !relDesc.isFOSRelationship && relDesc.isToMany.
 */
@property (nonatomic, readonly) NSSet *cmoToManyRelationships;

/*!
 * @method cmoOwnedRelationships
 *
 * The set of properties that are of type NSRelationshipDescription and
 * !relDesc.isFOSRelationship && relDesc.isOwnershipRelationship.
 */
@property (nonatomic, readonly) NSSet *cmoOwnedRelationships;

/*!
 * @method cmoOwnedToManyRelationships
 *
 * The set of properties that are of type NSRelationshipDescription and
 * !relDesc.isFOSRelationship && relDesc.isOwnershipRelationship && relDesc.isToMany.
 */
@property (nonatomic, readonly) NSSet *cmoOwnedToManyRelationships;

#pragma mark - Public Methods

- (BOOL)isFOSEntityWithRestConfig:(FOSRESTConfig *)restConfig;
- (BOOL)isStaticTableEntityWithRestConfig:(FOSRESTConfig *)restConfig;

@end
