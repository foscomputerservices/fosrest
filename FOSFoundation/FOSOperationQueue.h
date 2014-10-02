//
//  FOSOperationQueue.h
//  FOSFoundation
//
//  Created by David Hunt on 12/22/12.
//  Copyright (c) 2012 FOS Computer Services. All rights reserved.
//

#import <Foundation/Foundation.h>

@class FOSRESTConfig;
@class FOSManagedObjectContext;

@interface FOSOperationQueue : NSOperationQueue

/*!
 * @methodgroup Class Methods
 */
#pragma mark - Class methods

+ (instancetype)queueWithRestConfig:(FOSRESTConfig *)restConfig;

/*!
 * @methodgroup Public Properties
 */
#pragma mark - Public Properties
@property (nonatomic, weak) FOSRESTConfig *restConfig;
@property (nonatomic, readonly) NSManagedObjectContext *managedObjectContext;
@property (nonatomic, readonly) FOSOperation *currentOperation;

@property (nonatomic, readonly) BOOL hasCancelledOperations;
@property (nonatomic, readonly) NSSet *cancelledOperations;

/*!
 * @methodgroup Initialization Methods
 */
- (id)initWithRestConfig:(FOSRESTConfig *)restConfig;

/*!
 * @methodgroup Public Methods
 */
#pragma mark - Public Methods
- (void)markOperationAsCancelled:(FOSOperation *)cancelledOperation;
- (void)clearCancelledOperations;

@end
