//
//  FOSBackgroundOperation.m
//  FOSFoundation
//
//  Created by David Hunt on 12/22/12.
//  Copyright (c) 2012 FOS Computer Services. All rights reserved.
//

#import <FOSBackgroundOperation.h>

@implementation FOSBackgroundOperation

#pragma mark - Class methods

+ (instancetype)backgroundOperationWithRequest:(FOSBackgroundRequest)request {
    return [[self alloc] initWithBackgroundRequest:request callRequestIfCancelled:NO];
}

+ (instancetype)backgroundOperationWithRequest:(FOSBackgroundRequest)request
                         callRequestIfCancelled:(BOOL)callRequestIfCancelled {
    return [[self alloc] initWithBackgroundRequest:request
                             callRequestIfCancelled:callRequestIfCancelled];
}

+ (instancetype)backgroundOperationWithRecoverableRequest:(FOSRecoverableBackgroundRequest)request {
    return [[self alloc] initWithBackgroundRecoverableRequest:request];
}

+ (instancetype)backgroundOperationWithMainThreadRequest:(FOSBackgroundRequest)request {
    return [[self alloc] initWithMainThreadRequest:request];
}

#pragma mark - Initialization Methods

- (id)initWithBackgroundRequest:(FOSBackgroundRequest)request
          callRequestIfCancelled:(BOOL)callRequestIfCancelled {
    if ((self = [super init]) != nil) {
        _backgroundRequest = request;
        _callRequestIfCancelled = callRequestIfCancelled;
        _recoveryOption = FOSRecoveryOption_NoRecovery;
    }

    return self;
}

- (id)initWithBackgroundRecoverableRequest:(FOSRecoverableBackgroundRequest)request {
    if ((self = [super init]) != nil) {
        _recoverableBackgroundRequest = request;
        _callRequestIfCancelled = YES;
        _recoveryOption = FOSRecoveryOption_NoRecovery;
    }

    return self;
}

- (id)initWithMainThreadRequest:(FOSBackgroundRequest)request {
    if ((self = [self initWithBackgroundRequest:request callRequestIfCancelled:YES]) != nil) {
        _callRequestOnMainThread = YES;
    }

    return self;
}

#pragma mark - Overrides

- (void)dealloc {
    if (_callRequestIfCancelled) {
        for (NSOperation *nextOp in self.dependencies) {
            [nextOp removeObserver:self forKeyPath:@"isCancelled"];
        }
    }
}

- (void)addDependency:(NSOperation *)op {
    NSParameterAssert(op != nil);
    
    [super addDependency:op];

    if (_callRequestIfCancelled) {
        [op addObserver:self forKeyPath:@"isCancelled" options:0 context:nil];
    }
}

- (BOOL)isCancelled {
    BOOL result = NO;

    if (_recoveryOption == FOSRecoveryOption_NoRecovery) {
        result = super.isCancelled;
    }

    return result;
}

- (NSError *)error {
    NSError *result = nil;

    if (_recoveryOption == FOSRecoveryOption_NoRecovery) {
        result = super.error;
    }

    return result;
}

- (void)main {
    NSParameterAssert(self.backgroundRequest != nil || self.recoverableBackgroundRequest != nil);

    [super main];

    BOOL isCancelled = self.isCancelled;
    if (_callRequestIfCancelled || !isCancelled) {
        if (_recoverableBackgroundRequest != nil) {
            _recoveryOption = _recoverableBackgroundRequest(isCancelled, self.error);
        }
        else if (_callRequestOnMainThread) {
            __block FOSBackgroundOperation *blockSelf = self;

            dispatch_sync(dispatch_get_main_queue(), ^{
                blockSelf->_backgroundRequest(isCancelled, self.error);
            });
        }
        else {
            _backgroundRequest(isCancelled, self.error);
        }
    }
}

#pragma mark - KVO

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    if ([keyPath isEqualToString:@"isCancelled"]) {
        if (_callRequestIfCancelled && self.isCancelled) {
            if (_recoverableBackgroundRequest != nil) {
                _recoveryOption = _recoverableBackgroundRequest(YES, nil);
            }
            else if (_callRequestOnMainThread) {
                __block FOSBackgroundOperation *blockSelf = self;

                dispatch_sync(dispatch_get_main_queue(), ^{
                    blockSelf->_backgroundRequest(YES, nil);
                });
            }
            else {
                _backgroundRequest(YES, nil);
            }
        }
    }
    else if ([super respondsToSelector:_cmd]) {
        [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
    }
}

@end
