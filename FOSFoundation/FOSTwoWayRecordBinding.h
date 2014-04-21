//
//  FOSTwoWayRecordBinding.h
//  FOSFoundation
//
//  Created by David Hunt on 4/11/14.
//  Copyright (c) 2014 FOS Computer Services. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol FOSTwoWayRecordBinding <NSObject>

@required

/*!
 * @method jsonIdFromJSON:forEntity:error:
 *
 * Retrieves the jsonId from the given JSON for the ID_PROPERTY described
 * for the the given entity.
 */
- (FOSJsonId)jsonIdFromJSON:(NSDictionary *)json
                  forEntity:(NSEntityDescription *)entity
                      error:(NSError **)error;

/*!
 * @method jsonIdFromJSON:forRelationship:error:
 *
 * Retrieves the jsonId from the given JSON for the related object described
 * by the given relationship.
 */
- (FOSJsonId)jsonIdFromJSON:(NSDictionary *)json
            forRelationship:(NSRelationshipDescription *)relationship
                      error:(NSError **)error;

/*!
 * @method updateJson:fromCMO:forLifecyclePhase:error:
 *
 * Uses the receiver's @link propertyBindings %/link to update the JSON
 * dictionary values (and structure) from the CMO's property values.
 */
- (BOOL)updateJson:(NSMutableDictionary *)json
           fromCMO:(FOSCachedManagedObject *)cmo
 forLifecyclePhase:(FOSLifecyclePhase)lifecyclePhase
             error:(NSError **)error;

/*!
 * @method updateJson:fromCMO:error:
 *
 * Uses the receiver's @link propertyBindings %/link to update the CMO's
 * property values from the JSON dictionary values.
 */
- (BOOL)updateCMO:(FOSCachedManagedObject *)cmo
         fromJSON:(NSDictionary *)json
forLifecyclePhase:(FOSLifecyclePhase)lifecyclePhase
            error:(NSError **)error;

@end
