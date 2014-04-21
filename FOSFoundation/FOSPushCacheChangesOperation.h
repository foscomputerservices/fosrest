//
//  FOSPushCacheChangesOperation.h
//  FOSFoundation
//
//  Created by David Hunt on 1/3/13.
//  Copyright (c) 2013 FOS Computer Services. All rights reserved.
//

#import <FOSFoundation/FOSFoundation.h>

@class FOSPushAllCacheChangesOperation;

@interface FOSPushCacheChangesOperation : FOSOperation

@property (nonatomic, readonly) FOSPushAllCacheChangesOperation *parentOperation;

+ (FOSPushCacheChangesOperation *)pushCacheChangesOperationWithParentOperation:(FOSPushAllCacheChangesOperation *)parentOperation;

@end
