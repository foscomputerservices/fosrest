//
//  FOSRetrieveToManyRelationshipOperation.h
//  FOSFoundation
//
//  Created by David Hunt on 12/31/12.
//  Copyright (c) 2012 FOS Computer Services. All rights reserved.
//

#import <FOSFoundation/FOSFoundation.h>

@interface FOSRetrieveToManyRelationshipOperation : FOSOperation

@property (nonatomic, readonly) NSRelationshipDescription *relationship;
@property (nonatomic, readonly) NSError *error;
@property (nonatomic, readonly) FOSRetrieveCMOOperation *parentFetchOp;

+ (instancetype)fetchToManyRelationship:(NSRelationshipDescription *)relDesc
                              ownerJson:(id<NSObject>)ownerJson
                            ownerJsonId:(FOSJsonId)ownerJsonId
                           withBindings:(NSMutableDictionary *)bindings
                andParentFetchOperation:(FOSRetrieveCMOOperation *)parentFetchOp;

- (void)bindToOwner:(NSManagedObjectID *)ownerId;
- (void)finishOrdering;
- (void)finishValidation;
- (void)finishCleanup:(BOOL)forceDestroy;

@end