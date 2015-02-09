//
//  FOSUpdateServerRecordOperation.h
//  FOSFoundation
//
//  Created by David Hunt on 4/8/14.
//  Copyright (c) 2014 FOS Computer Services. All rights reserved.
//

@import Foundation;
#import <FOSFoundation/FOSSendServerRecordOperation.h>

@class FOSCachedManagedObject;

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
 * @method updateOperationForCMO:withLifecycleStyle:
 */
+ (instancetype)updateOperationForCMO:(FOSCachedManagedObject *)cmo
                   withLifecycleStyle:(NSString *)lifecycleStyle;

@end
