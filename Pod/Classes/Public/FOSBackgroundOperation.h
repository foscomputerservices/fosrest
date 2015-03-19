//
//  FOSBackgroundOperation.h
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

#import "FOSOperation.h"
#import "FOSCacheManager.h"

@interface FOSBackgroundOperation : FOSOperation

#pragma mark - Class Methods

+ (instancetype)backgroundOperationWithRequest:(FOSBackgroundRequest)request;
+ (instancetype)backgroundOperationWithRequest:(FOSBackgroundRequest)request
                         callRequestIfCancelled:(BOOL)callRequestIfCancelled;
+ (instancetype)backgroundOperationWithRecoverableRequest:(FOSRecoverableBackgroundRequest)request;

/*!
 * @method backgroundOperationWithMainThreadRequest
 *
 * Returns an instance of FOSBackgroundOperation that will ensure that request is
 * called back on the Main Thread. Additionally, callRequestIfCancelled is set to YES,
 * so the request will always be called.
 */
+ (instancetype)backgroundOperationWithMainThreadRequest:(FOSBackgroundRequest)request;

#pragma mark - Properties

@property (nonatomic, readonly) FOSBackgroundRequest backgroundRequest;
@property (nonatomic, readonly) FOSRecoverableBackgroundRequest recoverableBackgroundRequest;
@property (nonatomic, readonly) BOOL callRequestIfCancelled;
@property (nonatomic, readonly) BOOL callRequestOnMainThread;
@property (nonatomic, strong) id result;
@property (nonatomic, assign) FOSRecoveryOption recoveryOption;

#pragma mark - Initialization Methods

- (id)initWithBackgroundRequest:(FOSBackgroundRequest)request
         callRequestIfCancelled:(BOOL)callRequestIfCancelled;
- (id)initWithBackgroundRecoverableRequest:(FOSRecoverableBackgroundRequest)request;
- (id)initWithMainThreadRequest:(FOSBackgroundRequest)request;

@end
