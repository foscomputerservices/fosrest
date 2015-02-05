//
//  FOSRetrieveRelationshipUpdatesOperation.h
//  FOSFoundation
//
//  Created by David Hunt on 6/3/14.
//  Copyright (c) 2014 FOS Computer Services. All rights reserved.
//

#import <FOSFoundation/FOSOperation.h>

@class FOSCachedManagedObject;
@class FOSItemMatcher;

@interface FOSRetrieveRelationshipUpdatesOperation : FOSOperation

#pragma mark - Class Methods

+ (instancetype)retrieveRealtionshipUpdatesForCMO:(FOSCachedManagedObject *)cmo
                                         dslQuery:(NSString *)dslQuery
                                     mergeResults:(BOOL)mergeResults;

+ (instancetype)retrieveRealtionshipUpdatesForCMO:(FOSCachedManagedObject *)cmo
                                         dslQuery:(NSString *)dslQuery
                                     mergeResults:(BOOL)mergeResults
                                         matching:(FOSItemMatcher *)relationshipNameMatcher;

#pragma mark - Initialization Methods

- (id)initForCMO:(FOSCachedManagedObject *)cmo
        dslQuery:(NSString *)dslQuery
    mergeResults:(BOOL)mergeResults;
- (id)initForCMO:(FOSCachedManagedObject *)cmo
        dslQuery:(NSString *)dslQuery
    mergeResults:(BOOL)mergeResults
forRelationships:(FOSItemMatcher *)relationshipNameMatcher;

#pragma mark - Properties

@property (nonatomic, strong) NSString *lifecycleStyle;

@end
