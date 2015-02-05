//
//  FOSOperation+FOS_Internal.h
//  FOSFoundation
//
//  Created by David Hunt on 1/28/13.
//  Copyright (c) 2013 FOS Computer Services. All rights reserved.
//

#import "FOSFoundation_Internal.h"

@interface FOSOperation (FOS_Internal)

@property (nonatomic, readonly) NSSet *flattenedDependencies;

- (NSUInteger)calcFinishedOps;

@end

#ifdef CONFIGURATION_Debug
@interface FOSOperation (Testing)

- (void)setError:(NSError *)error;

@end
#endif

@interface FOSOperation ()

@property (nonatomic, weak) FOSOperationQueue *operationQueue;
@property (nonatomic, strong) FOSBeginOperation *beginOperation;

@end
