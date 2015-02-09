//
//  FOSWebServiceRequest+FOS_Internal.h
//  FOSFoundation
//
//  Created by David Hunt on 1/30/13.
//  Copyright (c) 2013 FOS Computer Services. All rights reserved.
//

#import <FOSWebServiceRequest.h>

typedef void (^FOSRequestPostProcessor)(id<NSObject> originalJsonResult, id<NSObject> unwrappedJson);

@interface FOSWebServiceRequest (FOS_Internal)

- (void)setError:(NSError *)error;

/*!
 * @method setOriginalJsonResult:postProcessor:
 *
 * Binds the receiver's originalJsonResult property.  It also binds the
 * receiver's jsonResultPorperty to the unwrapped version of originalJsonResult
 * if the receiver's urlBinding is set.
 *
 * The receiver's NSOperation state is then changed to finished and the operation
 * is thus complete.
 *
 * @param originalJsonResult Either the true json data received from the server or an NSManagedObjectID
 *                           instance for fast-tracking.
 *
 * @param postProcessor A block that will be executed after the json results have been processed,
 *                      but before marking the operation as finished.
 *
 * @discussion
 *
 * Subclasses should be very careful about overriding this method.  Since this method
 * changes the operation's state to finished, this will allow any NSOperations that are
 * dependent upon this operation to start.  Those operations might be running on different
 * threads, so any code that is executed after calling this method must not be code
 * that those other operations might rely upon.
 *
 * In order to inject post processing code between what this method does and the
 * time in which it finishes the operation, provide a postProcessor callback.
 */
- (void)setOriginalJsonResult:(id<NSObject>)originalJsonResult
                postProcessor:(FOSRequestPostProcessor)postProcessor;

@end
