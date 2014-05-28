//
//  FOSRetrieveCMOOperation+FOS_Internal.m
//  FOSFoundation
//
//  Created by David Hunt on 4/15/13.
//  Copyright (c) 2013 FOS Computer Services. All rights reserved.
//

#import "FOSRetrieveCMOOperation+FOS_Internal.h"
#import "FOSRESTConfig.h"

extern NSMutableDictionary *_outstandingFEORequests;

@implementation FOSRetrieveCMOOperation (FOS_Internal)

+ (instancetype)fetchRelatedManagedObjectUsingDataOperation:(FOSRetrieveCMODataOperation *)fetchOp
                                               withBindings:(NSMutableDictionary *)bindings
                                    andParentFetchOperation:(FOSRetrieveCMOOperation *)parentFetchOp {
    NSParameterAssert(fetchOp != nil);
    NSParameterAssert(bindings != nil);

    return [[self alloc] initWithDataOperation:fetchOp
                               isTopLevelFetch:NO
                             forLifecyclePhase:FOSLifecyclePhaseRetrieveServerRecord
                                  withBindings:bindings
                       andParentFetchOperation:parentFetchOp];
}

+ (instancetype)fetchRelatedManagedObjectForEntity:(NSEntityDescription *)entity
                                            withId:(FOSJsonId)jsonId
                                      withBindings:(NSMutableDictionary *)bindings
                           andParentFetchOperation:(FOSRetrieveCMOOperation *)parentFetchOp {
    
    NSParameterAssert(entity != nil);
    NSParameterAssert(jsonId != nil);
    NSParameterAssert(bindings != nil);

    FOSRetrieveCMOOperation *result = [[self alloc] initForEntity:entity
                                                           withId:jsonId
                                                  isTopLevelFetch:NO
                                                forLifecyclePhase:FOSLifecyclePhaseRetrieveServerRecord
                                                     withBindings:bindings
                                          andParentFetchOperation:parentFetchOp];

    return result;
}

+ (instancetype)fetchRelatedManagedObjectForEntity:(NSEntityDescription *)entity
                                          withJson:(id<NSObject>)json
                                      withBindings:(NSMutableDictionary *)bindings
                           andParentFetchOperation:(FOSRetrieveCMOOperation *)parentFetchOp {

    NSParameterAssert(entity != nil);
    NSParameterAssert(json != nil);
    NSParameterAssert(bindings != nil);

    FOSRetrieveCMOOperation *result = [[self alloc] initForEntity:entity
                                                         withJson:(NSDictionary *)json
                                                  isTopLevelFetch:NO
                                                forLifecyclePhase:FOSLifecyclePhaseRetrieveServerRecord
                                                     withBindings:bindings
                                          andParentFetchOperation:parentFetchOp];

    return result;
}

@end
