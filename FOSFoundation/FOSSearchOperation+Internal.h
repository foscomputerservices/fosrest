//
//  FOSSearchOperation+Internal.h
//  FOSFoundation
//
//  Created by David Hunt on 10/7/13.
//  Copyright (c) 2013 FOS Computer Services. All rights reserved.
//

@interface FOSSearchOperation ()

@property (nonatomic, readonly) NSSet *dependentSearchOperations;

- (FOSOperation *)processSearchResults:(FOSWebServiceRequest *)webRequest;
- (void)finalizeDependencies;

@end
