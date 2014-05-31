//
//  FOSSendServerRecordOperation.h
//  FOSFoundation
//
//  Created by David Hunt on 4/10/14.
//  Copyright (c) 2014 FOS Computer Services. All rights reserved.
//

@class FOSWebServiceRequest;

@interface FOSSendServerRecordOperation : FOSOperation
/*!
 * @group Public Properties
 */
#pragma mark - Public Properties

/*!
 * @property cmo
 *
 * The CMO that corresponds to the record to create on the server.
 *
 * @description
 *
 * The resulting CMO instance will belong to the receiver's
 * NSManagedObjectContext.
 */
@property (nonatomic, readonly) FOSCachedManagedObject *cmo;

/*!
 * @property lifecyclePhase
 *
 * The @link FOSLifecyclePhase @/link to which the receiver
 * corresponds.  The only valid values are @link FOSLifecyclePhaseCreateServerRecord @/link
 * and @link FOSLifecyclePhaseUpdateServerRecord @/link.
 */
@property (nonatomic, readonly) FOSLifecyclePhase lifecyclePhase;

/*!
 * @methodgroup Initialization Methods
 */
#pragma mark - Initialization Methods

/*!
 * @method initWithCMO:forLifecyclePhase:
 *
 * @discussion
 *
 * @link lifecyclePhase @/link can only be FOSLifecyclePhaseCreateServerRecord or
 * FOSLifecyclePhaseUpdateServerRecord.
 */
- (id)initWithCMO:(FOSCachedManagedObject *)cmo forLifecyclePhase:(FOSLifecyclePhase)lifecyclePhase;

@end
