//
//  FOSCreateServerRecordOperation.h
//  FOSFoundation
//
//  Created by David Hunt on 4/10/14.
//  Copyright (c) 2014 FOS Computer Services. All rights reserved.
//

/*!
 * @class FOSCreateServerRecordOperation
 *
 * An FOSSendServerRecordOperation that corresponds to the
 * FOSLifecyclePhaseCreateServerRecord of the
 * @link FOSLifecyclePhase @/link.
 *
 * It creates a new record on the server that corresponds to
 * the receiver's CMO.
 */
@interface FOSCreateServerRecordOperation : FOSSendServerRecordOperation

/*!
 * @methodgroup Class Methods
 */
#pragma mark - Class Methods

/*!
 * @method createOperationForCMO
 */
+ (instancetype)createOperationForCMO:(FOSCachedManagedObject *)cmo;

@end
