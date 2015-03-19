//
//  FOSWebServiceRequest+FOS_Internal.h
//  FOSRest
//
//  Created by David Hunt on 1/30/13.
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
