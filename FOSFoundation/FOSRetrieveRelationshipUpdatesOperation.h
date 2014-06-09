//
//  FOSRetrieveRelationshipUpdatesOperation.h
//  FOSFoundation
//
//  Created by David Hunt on 6/3/14.
//  Copyright (c) 2014 FOS Computer Services. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface FOSRetrieveRelationshipUpdatesOperation : FOSOperation

#pragma mark - Class Methods

+ (instancetype)retrieveRealtionshipUpdatesForCMO:(FOSCachedManagedObject *)cmo
                                         dslQuery:(NSString *)dslQuery;

+ (instancetype)retrieveRealtionshipUpdatesForCMO:(FOSCachedManagedObject *)cmo
                                         dslQuery:(NSString *)dslQuery
                                         matching:(FOSItemMatcher *)relationshipNameMatcher;

#pragma mark - Initialization Methods

- (id)initForCMO:(FOSCachedManagedObject *)cmo dslQuery:(NSString *)dslQuery;
- (id)initForCMO:(FOSCachedManagedObject *)cmo
        dslQuery:(NSString *)dslQuery
forRelationships:(FOSItemMatcher *)relationshipNameMatcher;

#pragma mark - Properties

@property (nonatomic, strong) NSString *lifecycleStyle;

@end
