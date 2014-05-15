//
//  FOSRetrieveCMOOperation.h
//  FOSFoundation
//
//  Created by David Hunt on 12/31/12.
//  Copyright (c) 2012 FOS Computer Services. All rights reserved.
//

#import <FOSFoundation/FOSFoundation.h>
#import "FOSBackgroundOperation.h"

@class FOSRetrieveCMODataOperation;

@interface FOSRetrieveCMOOperation : FOSOperation

#pragma mark - Properties

@property (nonatomic, readonly) NSEntityDescription *entity;
@property (nonatomic, readonly) FOSJsonId jsonId;
@property (nonatomic, readonly) NSDictionary *json;
@property (nonatomic, readonly) NSManagedObjectID *managedObjectID;
@property (nonatomic, readonly) FOSCachedManagedObject *managedObject;
@property (nonatomic, readonly) BOOL isTopLevelFetch;
@property (nonatomic, readonly) NSMutableDictionary *bindings;
@property (nonatomic, readonly) FOSRetrieveCMOOperation *parentFetchOp;
@property (nonatomic, assign) BOOL allowFastTrack;

#pragma mark - Class Methods

+ (instancetype)retrieveCMOUsingDataOperation:(FOSOperation<FOSRetrieveCMODataOperationProtocol> *)fetchOp;
+ (instancetype)retrieveCMOForEntity:(NSEntityDescription *)entity
                              withId:(FOSJsonId)jsonId
                  andParentOperation:(FOSRetrieveCMOOperation *)parentFetchOp;
+ (instancetype)retrieveCMOForEntity:(NSEntityDescription *)entity
                              withId:(FOSJsonId)jsonId
                        withBindings:(NSMutableDictionary *)bindings
                  andParentOperation:(FOSRetrieveCMOOperation *)parentFetchOp;
+ (instancetype)retrieveCMOForEntity:(NSEntityDescription *)entity
                            withJson:(NSDictionary *)json
                  andParentOperation:(FOSRetrieveCMOOperation *)parentFetchOp;
+ (instancetype)retrieveCMOForEntity:(NSEntityDescription *)entity
                            withJson:(NSDictionary *)json
                        withBindings:(NSMutableDictionary *)bindings
                  andParentOperation:(FOSRetrieveCMOOperation *)parentFetchOp;

+ (NSMutableDictionary *)primeBindingsForEntity:(NSEntityDescription *)entity
                                    withJsonIDs:(NSArray *)jsonIds;
+ (FOSCachedManagedObject *)cmoForEntity:(NSEntityDescription *)entity
                              withJsonId:(FOSJsonId)jsonId
                            fromBindings:(NSDictionary *)bindings
               respectingPreviousLookups:(BOOL)respectPrevious;
- (FOSCachedManagedObject *)cmoForEntity:(NSEntityDescription *)entity
                                withJson:(NSDictionary *)json
                            fromBindings:(NSDictionary *)bindings
               respectingPreviousLookups:(BOOL)respectPrevious;

#pragma mark - Initialization Methods

- (id)initAsTopLevelFetch:(BOOL)isTopLevelFetch
                   entity:(NSEntityDescription *)entity
             withBindings:(NSMutableDictionary *)bindings
  andParentFetchOperation:(FOSRetrieveCMOOperation *)parentFetchOp;
- (id)initWithDataOperation:(FOSOperation<FOSRetrieveCMODataOperationProtocol> *)fetchOp
            isTopLevelFetch:(BOOL)isTopLevelFetch
               withBindings:(NSMutableDictionary *)bindings
    andParentFetchOperation:(FOSRetrieveCMOOperation *)parentFetchOp;
- (id)initForEntity:(NSEntityDescription *)entity
             withId:(FOSJsonId)jsonId
    isTopLevelFetch:(BOOL)isTopLevelFetch
       withBindings:(NSMutableDictionary *)bindings
andParentFetchOperation:(FOSRetrieveCMOOperation *)parentFetchOp;
- (id)initForEntity:(NSEntityDescription *)entity
           withJson:(NSDictionary *)json
    isTopLevelFetch:(BOOL)isTopLevelFetch
       withBindings:(NSMutableDictionary *)bindings
andParentFetchOperation:(FOSRetrieveCMOOperation *)parentFetchOp;

#pragma mark - Binding Methods

- (void)finishBinding;
- (void)finishOrdering;
- (void)finishValidation;
- (void)finishCleanup:(BOOL)forceDestroy;

@end