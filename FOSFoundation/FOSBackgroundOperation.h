//
//  FOSBackgroundOperation.h
//  FOSFoundation
//
//  Created by David Hunt on 12/22/12.
//  Copyright (c) 2012 FOS Computer Services. All rights reserved.
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
