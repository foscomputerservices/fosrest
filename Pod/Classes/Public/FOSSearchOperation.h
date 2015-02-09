//
//  FOSSearchOperation.h
//  FOSFoundation
//
//  Created by David Hunt on 12/22/12.
//  Copyright (c) 2012 FOS Computer Services. All rights reserved.
//

#import <FOSFoundation/FOSOperation.h>
#import <FOSFoundation/FOSCacheManager.h>

@interface FOSSearchOperation : FOSOperation

#pragma mark - Public Properties
@property (nonatomic, assign) Class managedClass;
@property (nonatomic, assign) BOOL saveIndividualResults;
@property (nonatomic, strong) NSString *dslQuery;
@property (nonatomic, strong) NSSet *results;

#pragma mark - Public methods
- (void)performSearch;
- (void)performSearchAndInform:(FOSCacheSearchHandler)searchHandler;

@end
