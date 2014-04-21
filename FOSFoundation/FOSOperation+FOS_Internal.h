//
//  FOSOperation+FOS_Internal.h
//  FOSFoundation
//
//  Created by David Hunt on 1/28/13.
//  Copyright (c) 2013 FOS Computer Services. All rights reserved.
//

#import <FOSFoundation/FOSFoundation.h>

@interface FOSOperation (FOS_Internal)

@property (nonatomic, readonly) NSSet *flattenedDependencies;

- (NSUInteger)calcFinishedOps;

@end

@interface FOSOperation ()

@property (nonatomic, weak) FOSOperationQueue *operationQueue;
@property (nonatomic, strong) FOSBeginOperation *beginOperation;

@end
