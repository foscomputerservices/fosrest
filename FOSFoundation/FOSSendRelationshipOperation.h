//
//  FOSSendRelationshipOperation.h
//  FOSFoundation
//
//  Created by David Hunt on 4/10/14.
//  Copyright (c) 2014 FOS Computer Services. All rights reserved.
//

#import <FOSFoundation/FOSFoundation.h>

/*!
 * @class FOSSendRelationshipOperation
 *
 * An abstract class that manages sending the server records across relationships
 */
@interface FOSSendRelationshipOperation : FOSOperation

/*!
 * @methodgroup Class Methods
 */
#pragma mark - Class Methods

/*!
 * @method operationForCMO:forRelationship:
 */
+ (instancetype)operationForCMO:(FOSCachedManagedObject *)cmo
                forRelationship:(NSRelationshipDescription *)relDesc;

/*!
 * @group Properties
 */

/*!
 * @property cmo
 */
@property (nonatomic, readonly) FOSCachedManagedObject *cmo;

/*!
 * @property relDesc
 */
@property (nonatomic, readonly) NSRelationshipDescription *relDesc;

/*!
 * @methodgroup Initialization methods
 */
#pragma mark - Initialization Methods

- (id)initWithCMO:(FOSCachedManagedObject *)cmo
  forRelationship:(NSRelationshipDescription *)relDesc;

@end
