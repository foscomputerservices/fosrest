//
//  FOSCacheManager.h
//  FOSRest
//
//  Created by David Hunt on 12/22/12.
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

@import CoreData;

#import "FOSHandlers.h"

@class FOSCachedManagedObject;
@class FOSWebServiceRequest;
@class FOSOperation;
@class FOSRESTConfig;
@class FOSBackgroundOperation;

@class FOSUser;

@interface FOSCacheManager : NSObject {
@private
    // TODO : Restore to __weak when Swift fixes bug
    /* __weak */ __unsafe_unretained FOSRESTConfig *_restConfig;
    BOOL _updatingMainThreadMOC;
    NSMutableSet *_skipServerDeletionIds; // Used in (CoreData) category
}

#pragma mark - Class methods

+ (NSPredicate *)isDirtyServerPredicate;
+ (NSPredicate *)isNotDirtyServerPredicate;

#pragma mark - Initialization methods

- (id)initWithCacheConfig:(FOSRESTConfig *)restConfig;

#pragma mark - Public Properties

@property (nonatomic, readonly) BOOL updatingMainThreadMOC;
@property (nonatomic, assign) BOOL pauseAutoSync;

#pragma mark - Public methods

/*!
 * @method flushCaches:
 *
 * Tells the server to immediately sync the local state to the server.
 *
 * @param completionHandler  Called when the synchronization has been completed
 *    and always called on the main thread.
 *
 */
- (void)flushCaches:(FOSBackgroundRequest)completionHandler;

/*!
 * @method queueOperations:
 *
 * Adds a set of operations to the appropriate operation queue for
 * processing.
 *
 * @param operation  The operation to add to the queue.  Must not be nil.
 *
 * @param finalOp  An optional operation that will be executed after operation and after
 *                 all changes have been saved to the database.  May be nil.
 *
 * @param groupName  An optional string that will be associated with operation (and its
 *                   dependencies that will be used for logging purposes).
 *
 * @discussion
 *
 * The set of operations is bracketed to ensure that a new
 * NSManagedObjectContext is added at the beginning and that
 * all changes made during the complete set of operations are
 * saved to the database when the operation set is complete.
 */
- (void)queueOperation:(FOSOperation *)operation withCompletionOperation:(FOSOperation *)finalOp
         withGroupName:(NSString *)groupName;

- (void)reQueueOperation:(FOSOperation *)operation;

/*!
 * @method cancelOutstandingPullOperations
 *
 * Searches throughout the operation queue and cancels any operations that are queued that
 * are marked as isPullOperation.
 */
- (void)cancelOutstandingPullOperations;


@end
