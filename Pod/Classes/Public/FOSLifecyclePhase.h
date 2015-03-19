//
//  FOSLifecyclePhase.h
//  Pods
//
//  Created by David Hunt on 3/18/15.
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

#import "FOSLifecycleDirection.h"

/*!
 * @enum FOSLifecyclePhase
 *
 * @constant FOSLifecyclePhaseLogin Logs a user in to the REST Service (Adapter binding: LOGIN).
 *
 * @constant FOSLifecyclePhaseLogout Logs a user out of the REST Service (Adapter binding: LOGOUT).
 *
 * @constant FOSLifecyclePhasePasswordReset Resets the password for a user
 *           (Adapter binding: PASSWORD_RESET).
 *
 * @constant FOSLifecyclePhaseCreateServerRecord Create a record on the REST Service
 *           (Adapter binding: CREATE).
 *
 * @constant FOSLifecyclePhaseUpdateServerRecord Update a record on the REST Service
 *           (Adapter binding: UPDATE).
 *
 * @constant FOSLifecyclePhaseDestroyServerRecord Destroy a record on the REST Service
 *           (Adapter binding: DESTROY).
 *
 * @constant FOSLifecyclePhaseRetrieveServerRecord Retrieves information from the
 *           REST Service and creates or updates a CMO  (Adapter binding: RETRIEVE_SERVER_RECORD).
 *
 * @constant FOSLifecyclePhaseRetrieveServerRecords Retrieves information from the
 *           REST Service and creates or updates one or more CMOs
 *           (Adapter binding: RETRIEVE_SERVER_RECORDS).
 *
 * @constant FOSLifecyclePhaseRetrieveServerRecordCount Retrieves the count of
 *           records from the REST Service  (Adapter binding: RETRIEVE_SERVER_RECORD_COUNT).
 *
 * @constant FOSLifecyclePhaseRetrieveServerRecordRelationship Retrieves information from
 *           the REST service and creates or updates a relationship of a CMO
 *           (Adapter binding: RETRIEVE_RELATIONSHIP).
 */
typedef NS_ENUM(NSUInteger, FOSLifecyclePhase) {
    FOSLifecyclePhaseLogin                            = 0x01 | FOSLifecycleDirectionRetrieve,
    FOSLifecyclePhaseLogout                           = 0x02,
    FOSLifecyclePhasePasswordReset                    = 0x03,
    FOSLifecyclePhaseCreateServerRecord               = 0x04 | FOSLifecycleDirectionUpdate,
    FOSLifecyclePhaseUpdateServerRecord               = 0x05 | FOSLifecycleDirectionUpdate,
    FOSLifecyclePhaseDestroyServerRecord              = 0x06 | FOSLifecycleDirectionUpdate,
    FOSLifecyclePhaseRetrieveServerRecord             = 0x07 | FOSLifecycleDirectionRetrieve,
    FOSLifecyclePhaseRetrieveServerRecords            = 0x08 | FOSLifecycleDirectionRetrieve,
    FOSLifecyclePhaseRetrieveServerRecordCount        = 0x09 | FOSLifecycleDirectionRetrieve,
    FOSLifecyclePhaseRetrieveServerRecordRelationship = 0x0A | FOSLifecycleDirectionRetrieve
};
