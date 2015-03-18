//
//  FOSSendServerRecordOperation.h
//  FOSREST
//
//  Created by David Hunt on 4/10/14.
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

#import <FOSRest/FOSOperation.h>
#import <FOSRest/FOSURLBinding.h>

@class FOSCachedManagedObject;
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
 * @property parentSentIDs
 *
 * A set of NSManagedObjectID instances that have already been sent by
 * parent scopes.  This list is added to as scopes are processed to
 * terminate any cycles in the graph.
 */
@property (nonatomic, strong) NSSet *parentSentIDs;

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
