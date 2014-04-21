//
//  FOSRetrieveCMOOperation+FOS_Internal.h
//  FOSFoundation
//
//  Created by David Hunt on 4/15/13.
//  Copyright (c) 2013 FOS Computer Services. All rights reserved.
//

#import "FOSRetrieveCMOOperation.h"

@interface FOSRetrieveCMOOperation (FOS_Internal)

// These methods inhibit saves of the related objects until the entire graph is realized.
+ (instancetype)fetchRelatedManagedObjectUsingDataOperation:(FOSRetrieveCMODataOperation *)fetchOp
                                               withBindings:(NSMutableDictionary *)bindings
                                    andParentFetchOperation:(FOSRetrieveCMOOperation *)parentFetchOp;
+ (instancetype)fetchRelatedManagedObjectForEntity:(NSEntityDescription *)entity
                                            withId:(FOSJsonId)jsonId
                                      withBindings:(NSMutableDictionary *)bindings
                           andParentFetchOperation:(FOSRetrieveCMOOperation *)parentFetchOp;
+ (instancetype)fetchRelatedManagedObjectForEntity:(NSEntityDescription *)entity
                                          withJson:(id<NSObject>)json
                                      withBindings:(NSMutableDictionary *)bindings
                           andParentFetchOperation:(FOSRetrieveCMOOperation *)parentFetchOp;


@end
