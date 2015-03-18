//
//  FOSTwoWayRecordBinding.h
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
@import CoreData;
#import <FOSRest/FOSCachedManagedObject.h>
#import <FOSRest/FOSURLBinding.h>

@protocol FOSTwoWayRecordBinding <NSObject>

@required

/*!
 * @method jsonIdFromJSON:forEntity:error:
 *
 * Retrieves the jsonId from the given JSON for the ID_PROPERTY described
 * for the the given entity.
 */
- (FOSJsonId)jsonIdFromJSON:(id<NSObject>)json
                  forEntity:(NSEntityDescription *)entity
                      error:(NSError **)error;

/*!
 * @method jsonIdFromJSON:forRelationship:error:
 *
 * Retrieves the jsonId from the given JSON for the related object described
 * by the given relationship.
 */
- (FOSJsonId)jsonIdFromJSON:(id<NSObject>)json
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
         fromJSON:(id<NSObject>)json
forLifecyclePhase:(FOSLifecyclePhase)lifecyclePhase
            error:(NSError **)error;

@end
