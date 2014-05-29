//
//  FOSTwoWayPropertyBinding.h
//  FOSFoundation
//
//  Created by David Hunt on 4/12/14.
//  Copyright (c) 2014 FOS Computer Services. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol FOSTwoWayPropertyBinding <NSObject>

@required

/*!
 * @method propertyDescriptionsForEntity:
 *
 * Returns the set of NSPropertyDescription instances from the given entity that can be bound
 * by the receiver.
 */
- (NSSet *)propertyDescriptionsForEntity:(NSEntityDescription *)entity;

/*!
 * @method jsonIdFromJSON:forEntity:error:
 *
 */
- (FOSJsonId)jsonIdFromJSON:(id<NSObject>)json
                withContext:(NSDictionary *)context
                      error:(NSError **)error;

/*!
 * @method updateJSON:fromCMO:forProperty:forLifecyclePhase:error:
 *
 * Uses the result of @link cmoKeyPathExpression @/link as a keyPath and applies that to the provided
 * CMO to obtain a value to place in the json dictionary.
 *
 * The CMO's value is passed through @link FOSRESTServiceAdapter/encodeCMOValueToJSON:error: @/link to ensure that
 * it's properly encoded for json.
 *
 * The @link jsonKeyExpression @/link is then evaluated and used as a keyPath to set the
 * encoded CMO value.
 *
 * Result is YES if the property was updated and NO otherwise.  Note that a result of NO
 * does not mean that there was an error, it could be any of the following:
 *
 *   - The new and original value where the same
 *   - The property is modified locally (thus we don't want to overwrite it)
 *
 * Check *error to determine if an error occurred.
 */
- (BOOL)updateJSON:(NSMutableDictionary *)json
           fromCMO:(FOSCachedManagedObject *)cmo
       forProperty:(NSPropertyDescription *)propDesc
 forLifecyclePhase:(FOSLifecyclePhase)lifecyclePhase
             error:(NSError **)error;

/*!
 * @method updateCMO:fromJSON:forProperty:error:
 *
 * Uses the result of @link jsonKeyExpression @/link as a keyPath and applies that to the
 * provide json dictionary.
 *
 * The CMO's value is passed through @link FOSRESTServiceAdapter/decodeJSONValueToCMO:error: @/link to ensure that
 * it's properly encoded for json.
 *
 * The @link cmoKeyPathExpression @/link is then evaluate and used as keyPath to set the
 * decoded json value.
 */
- (BOOL)updateCMO:(FOSCachedManagedObject *)cmo
         fromJSON:(id<NSObject>)json
      forProperty:(NSPropertyDescription *)propDesc
            error:(NSError **)error;

@end
