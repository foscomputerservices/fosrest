//
//  FOSUpdateServerRecordOperation.h
//  FOSFoundation
//
//  Created by David Hunt on 4/8/14.
//  Copyright (c) 2014 FOS Computer Services. All rights reserved.
//

#import <Foundation/Foundation.h>

/*!
 * @class FOSUpdateServerRecordOperation
 *
 * An FOSUpdateServerRecordOperation that corresponds to the
 * FOSLifecyclePhaseUpdateServerRecord of the
 * @link FOSLifecyclePhase @/link.
 *
 * It updates an existing record on the server that corresponds to
 * the receiver's CMO.
 */
@interface FOSUpdateServerRecordOperation : FOSSendServerRecordOperation

/*!
 * @methodgroup Class Methods
 */
#pragma mark - Class Methods

/*!
 * @method createOperationForCMO
 */
+ (instancetype)updateOperationForCMO:(FOSCachedManagedObject *)cmo;

@end
