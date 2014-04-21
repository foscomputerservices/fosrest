//
//  FOSSearchOperation.h
//  FOSFoundation
//
//  Created by David Hunt on 12/22/12.
//  Copyright (c) 2012 FOS Computer Services. All rights reserved.
//

#import "FOSSearchOperation.h"

@interface FOSSearchOperation : FOSOperation

#pragma mark - Subclass Helper Methods & Properties
@property (nonatomic, assign) BOOL saveIndividualResults;
- (FOSOperation *)processSearchResults:(FOSWebServiceRequest *)webRequest;

#pragma mark - Public methods
- (void)performSearch;
- (void)performSearchAndInform:(FOSCacheSearchHandler)searchHandler;

#pragma mark - Abstract methods/properties
@property (nonatomic, readonly) Class managedClass;
@property (nonatomic, readonly) NSSet *dependentSearchOperations;
@property (nonatomic, strong) NSSet *results;

@end
