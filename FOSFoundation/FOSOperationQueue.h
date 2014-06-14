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

@interface FOSOperationQueue : NSOperationQueue {

@protected
    FOSManagedObjectContext *_moc;
}

@property (nonatomic, weak) FOSRESTConfig *restConfig;
@property (nonatomic, readonly) NSManagedObjectContext *managedObjectContext;
@property (nonatomic, readonly) FOSOperation *currentOperation;

@property (nonatomic, readonly) BOOL hasCancelledOperations;
@property (nonatomic, readonly) NSSet *cancelledOperations;

- (void)markOperationAsCancelled:(FOSOperation *)cancelledOperation;
- (void)clearCancelledOperations;

@end
