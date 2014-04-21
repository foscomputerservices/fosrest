//
//  FOSOperation.h
//  FOSFoundation
//
//  Created by David Hunt on 12/22/12.
//  Copyright (c) 2012 FOS Computer Services. All rights reserved.
//

#import <Foundation/Foundation.h>

@class FOSBeginOperation;
@protocol FOSRESTServiceAdapter;

@interface FOSOperation : NSOperation {
@protected
    BOOL _mainCalled;
}

/*!
 * @property beginOperation
 *
 * Each FOSOperation that has been queued is queued has a begin operation
 * that manages the NSManagedObjectConext for the entire set of dependent
 * FOSOperations.
 */
@property (nonatomic, readonly) FOSBeginOperation *beginOperation;

/*!
 * @property groupName
 *
 * A string that is primarily used for debugging purposes that describes
 * the group of operations.
 *
 * @remarks
 *
 * This property is simply an alias for self.beginOperation.groupName;
 */
@property (nonatomic, readonly) NSString *groupName;

/*!
 * @property managedObjectContext
 *
 * Each closed set of FOSOperations that are interdepenent has a single
 * NSManagedObjectContext that is managed by the associated FOSBeginOperation.
 *
 * @remarks
 *
 * This property is simply an alias for [FOSOperation currentQueue].managedObjectContext.
 */
@property (nonatomic, readonly) NSManagedObjectContext *managedObjectContext;

/*!
 * @property error
 *
 * Traverses the entire dependency tree and returns the first error encountered,
 * or nil if none.
 */
@property (nonatomic, readonly) NSError *error;

/*!
 * @property isPullOperation
 *
 * The default value is NO.  Subclasses may override.
 */
@property (nonatomic, readonly) BOOL isPullOperation;

/*!
 * @property isQueued
 *
 * Once the receiver has been placed in the queue, this property returns YES.
 */
@property (nonatomic, assign) BOOL isQueued;

@property (nonatomic, readonly) FOSRESTConfig *restConfig;

@property (nonatomic, readonly) id<FOSRESTServiceAdapter> restAdapter;

/*!
 * @property totalDependentOperations
 *
 * Returns the total number operations that this operation is dependent upon.
 *
 * @remarks
 *
 * Due to the undirected graph nature of the dependencies, many operations
 * will be counted multiple times.  However the graph is always rooted
 * in a FOSBeginOperation, so the count stops at that point in the graph
 * and does terminate.  This count will just be much larger than
 * a 'distinct' count of the number of operations in the graph.
 *
 * This number is simply meant to be a number that can be used to calculate
 * a percentage along with finishedDependentOperations.
 *
 * This property is NOT KVO compliant.
 */
@property (nonatomic, readonly) NSUInteger totalDependentOperations;

/*!
 * @property finishedDependentOperations
 *
 * Returns the total number operations that this operation is dependent upon
 * that have been marked as isFinished == YES.
 *
 * @remarks
 *
 * This property is KVO compliant.
 */
@property (nonatomic, readonly) NSUInteger finishedDependentOperations;

@end
