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
                                             ofRelationship:(NSRelationshipDescription *)relDesc
                                               withBindings:(NSMutableDictionary *)bindings
                                    andParentFetchOperation:(FOSRetrieveCMOOperation *)parentFetchOp {
    NSParameterAssert(fetchOp != nil);
    NSParameterAssert(bindings != nil);

    return [[self alloc] initWithDataOperation:fetchOp
                               isTopLevelFetch:NO
                             forLifecyclePhase:FOSLifecyclePhaseRetrieveServerRecordRelationship
                             forLifecycleStyle:nil
                                  withBindings:bindings
                       andParentFetchOperation:parentFetchOp];
}

+ (instancetype)fetchRelatedManagedObjectForEntity:(NSEntityDescription *)entity
                                    ofRelationship:(NSRelationshipDescription *)relDesc
                                            withId:(FOSJsonId)jsonId
                                      withBindings:(NSMutableDictionary *)bindings
                           andParentFetchOperation:(FOSRetrieveCMOOperation *)parentFetchOp {

    NSParameterAssert(entity != nil);
    NSParameterAssert(jsonId != nil);
    NSParameterAssert(bindings != nil);

    FOSRetrieveCMOOperation *result = [[self alloc] initForEntity:entity
                                                   ofRelationship:relDesc
                                                           withId:jsonId
                                                  isTopLevelFetch:NO
                                                forLifecyclePhase:FOSLifecyclePhaseRetrieveServerRecordRelationship
                                                forLifecycleStyle:nil
                                                     withBindings:bindings
                                          andParentFetchOperation:parentFetchOp];

    return result;
}

+ (instancetype)fetchRelatedManagedObjectForEntity:(NSEntityDescription *)entity
                                    ofRelationship:(NSRelationshipDescription *)relDesc
                                          withJson:(id<NSObject>)json
                                      withBindings:(NSMutableDictionary *)bindings
                           andParentFetchOperation:(FOSRetrieveCMOOperation *)parentFetchOp {

    NSParameterAssert(entity != nil);
    NSParameterAssert(json != nil);
    NSParameterAssert(bindings != nil);

    FOSRetrieveCMOOperation *result = [[self alloc] initForEntity:entity
                                                   ofRelationship:relDesc
                                                         withJson:(NSDictionary *)json
                                                  isTopLevelFetch:NO
                                                forLifecyclePhase:FOSLifecyclePhaseRetrieveServerRecordRelationship
                                                forLifecycleStyle:nil
                                                     withBindings:bindings
                                          andParentFetchOperation:parentFetchOp];

    return result;
}

@end
