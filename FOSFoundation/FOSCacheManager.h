//
//  FOSCacheManager.h
//  FOSFoundation
//
//  Created by David Hunt on 12/22/12.
//  Copyright (c) 2012 FOS Computer Services. All rights reserved.
//

#import <Foundation/Foundation.h>

@class FOSCachedManagedObject;
@class FOSWebServiceRequest;
@class FOSOperation;
@class FOSRESTConfig;
@class FOSBackgroundOperation;

typedef NS_ENUM(NSUInteger, FOSRecorveryOption) {
    FOSRecorveryOption_NoRecovery = 0,
    FOSRecorveryOption_Recovered = 1
};

typedef void (^FOSCacheErrorHandler)(NSError *error);
typedef void (^FOSCacheFetchHandler)(NSManagedObjectID *result, NSError *error);
typedef void (^FOSCacheSearchHandler)(NSSet *results, NSError *error);
typedef void (^FOSBackgroundRequest)(BOOL cancelled, NSError *error);
typedef FOSRecorveryOption (^FOSRecoverableBackgroundRequest)(BOOL cancelled, NSError *error);

typedef id<NSObject,NSCopying> FOSJsonId;

@class FOSUser;

@interface FOSCacheManager : NSObject

#pragma mark - Class methods

+ (NSPredicate *)isDirtyServerPredicate;
+ (NSPredicate *)isNotDirtyServerPredicate;

#pragma mark - Initialization methods

- (id)initWithCacheConfig:(FOSRESTConfig *)restConfig;

#pragma mark - Public Properties

@property (nonatomic, readonly) BOOL updatingMainThreadMOC;

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
 * @param groupName  An optional string that will be assocaited with operation (and its
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

- (void)requeueOperation:(FOSOperation *)operation;

/*!
 * @method cancelOutstandingPullOperations
 *
 * Searches throught the operation queue and cancels any operations that are queued that
 * are marked as isPullOperation.
 */
- (void)cancelOutstandingPullOperations;


@end
