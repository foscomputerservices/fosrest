//
//  FOSRetrieveCMOOperation.h
//  FOSFoundation
//
//  Created by David Hunt on 12/31/12.
//  Copyright (c) 2012 FOS Computer Services. All rights reserved.
//

#import <FOSFoundation/FOSOperation.h>
#import <FOSFoundation/FOSCachedManagedObject.h>
#import <FOSFoundation/FOSURLBinding.h>

@protocol FOSRetrieveCMODataOperationProtocol;

@interface FOSRetrieveCMOOperation : FOSOperation

#pragma mark - Properties

@property (nonatomic, readonly) NSEntityDescription *entity;
@property (nonatomic, readonly) FOSJsonId jsonId;
@property (nonatomic, readonly) id<NSObject> json;
@property (nonatomic, readonly) NSManagedObjectID *managedObjectID;
@property (nonatomic, readonly) FOSCachedManagedObject *managedObject;
@property (nonatomic, readonly) BOOL isTopLevelFetch;
@property (nonatomic, assign) BOOL allowFastTrack;
@property (nonatomic, strong) NSString *dslQuery;
@property (nonatomic, assign) BOOL mergeResults;

#pragma mark - Class Methods

+ (instancetype)retrieveCMOUsingDataOperation:(FOSOperation<FOSRetrieveCMODataOperationProtocol> *)fetchOp
                            forLifecyclePhase:(FOSLifecyclePhase)lifecyclePhase
                            forLifecycleStyle:(NSString *)lifecycleStyle;

+ (instancetype)retrieveCMOForEntity:(NSEntityDescription *)entity
                              withId:(FOSJsonId)jsonId;

+ (instancetype)retrieveCMOForEntity:(NSEntityDescription *)entity
                            withJson:(NSDictionary *)json
                        withBindings:(NSMutableDictionary *)bindings;

+ (NSMutableDictionary *)primeBindingsForEntity:(NSEntityDescription *)entity
                                    withJsonIDs:(NSArray *)jsonIds;

+ (FOSCachedManagedObject *)cmoForEntity:(NSEntityDescription *)entity
                              withJsonId:(FOSJsonId)jsonId
                            fromBindings:(NSMutableDictionary *)bindings;

- (FOSCachedManagedObject *)cmoForEntity:(NSEntityDescription *)entity
                                withJson:(id<NSObject>)json
                            fromBindings:(NSMutableDictionary *)bindings;

#pragma mark - Initialization Methods

- (id)initAsTopLevelFetch:(BOOL)isTopLevelFetch
        forLifecyclePhase:(FOSLifecyclePhase)lifecyclePhase
        forLifecycleStyle:(NSString *)lifecycleStyle
                   entity:(NSEntityDescription *)entity
           ofRelationship:(NSRelationshipDescription *)relDesc
             withBindings:(NSMutableDictionary *)bindings;

- (id)initWithDataOperation:(FOSOperation<FOSRetrieveCMODataOperationProtocol> *)fetchOp
            isTopLevelFetch:(BOOL)isTopLevelFetch
          forLifecyclePhase:(FOSLifecyclePhase)lifecyclePhase
          forLifecycleStyle:(NSString *)lifecycleStyle
               withBindings:(NSMutableDictionary *)bindings;

- (id)initForEntity:(NSEntityDescription *)entity
     ofRelationship:(NSRelationshipDescription *)relDesc
             withId:(FOSJsonId)jsonId
    isTopLevelFetch:(BOOL)isTopLevelFetch
  forLifecyclePhase:(FOSLifecyclePhase)lifecyclePhase
  forLifecycleStyle:(NSString *)lifecycleStyle
       withBindings:(NSMutableDictionary *)bindings;

- (id)initForEntity:(NSEntityDescription *)entity
     ofRelationship:(NSRelationshipDescription *)relDesc
           withJson:(NSDictionary *)json
    isTopLevelFetch:(BOOL)isTopLevelFetch
  forLifecyclePhase:(FOSLifecyclePhase)lifecyclePhase
  forLifecycleStyle:(NSString *)lifecycleStyle
       withBindings:(NSMutableDictionary *)bindings;

#pragma mark - Binding Methods

- (void)finishBinding;
- (void)finishOrdering;
- (NSError *)finishValidation;
- (void)finishCleanup:(BOOL)forceDestroy;

@end
