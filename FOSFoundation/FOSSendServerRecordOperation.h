//
//  FOSSendServerRecordOperation.h
//  FOSFoundation
//
//  Created by David Hunt on 4/10/14.
//  Copyright (c) 2014 FOS Computer Services. All rights reserved.
//

#import <FOSFoundation/FOSFoundation.h>

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
 * The @link FOSLifecyclePhase @/link to which the receiver corresponds.  The only valid
 * values are @link FOSLifecyclePhaseCreateServerRecord @/link
 * and @link FOSLifecyclePhaseUpdateServerRecord @/link.
 */
@property (nonatomic, readonly) FOSLifecyclePhase lifecyclePhase;

/*!
 * @property lifecycleStyle
 *
 * A value to match to the @link FOSURLBinding.lifecycleStyle @/link when searching
 * for the correct binding to send the receiver's cmo (may be nil).
 */
@property (nonatomic, readonly) NSString *lifecycleStyle;

/*!
 * @methodgroup Initialization Methods
 */
#pragma mark - Initialization Methods

/*!
 * @method initWithCMO:forLifecyclePhase:withLifecycleStyle:
 *
 * @param lifecyclePhase Can only be FOSLifecyclePhaseCreateServerRecord or
 *                       FOSLifecyclePhaseUpdateServerRecord.
 */
- (id)initWithCMO:(FOSCachedManagedObject *)cmo
forLifecyclePhase:(FOSLifecyclePhase)lifecyclePhase
withLifecycleStyle:(NSString *)lifecycleStyle;

@end
