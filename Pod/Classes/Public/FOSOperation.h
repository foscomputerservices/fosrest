//
//  FOSOperation.h
//  FOSFoundation
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

@class FOSRESTConfig;
@class FOSBeginOperation;
@protocol FOSRESTServiceAdapter;

@interface FOSOperation : NSOperation {
@protected
    BOOL _mainCalled;

    // TODO: These variables should be formalized!
    __block BOOL _ignoreDependentErrors;
    __block BOOL _finishedErrorPass;
    __block NSError *_error;
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
 * Each closed set of FOSOperations that are interdependent has a single
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
