//
//  FOSRetrieveToOneRelationshipOperation.h
//  FOSFoundation
//
//  Created by David Hunt on 12/31/12.
//  Copyright (c) 2012 FOS Computer Services. All rights reserved.
//

#import <FOSFoundation/FOSFoundation.h>

@interface FOSRetrieveToOneRelationshipOperation : FOSOperation

@property (nonatomic, readonly) NSRelationshipDescription *relationship;
@property (nonatomic, readonly) id<NSObject>jsonFragment;
@property (nonatomic, readonly) NSError *error;
@property (nonatomic, readonly) FOSRetrieveCMOOperation *parentFetchOp;

+ (instancetype)fetchToOneRelationship:(NSRelationshipDescription *)relDesc
                          jsonFragment:(id<NSObject>)jsonFragment
                          withBindings:(NSMutableDictionary *)bindings
               andParentFetchOperation:(FOSRetrieveCMOOperation *)parentFetchOp;

- (void)bindToOwner:(NSManagedObjectID *)ownerId;

@end
