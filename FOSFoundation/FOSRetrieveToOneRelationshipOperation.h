//
//  FOSRetrieveToOneRelationshipOperation.h
//  FOSFoundation
//
//  Created by David Hunt on 12/31/12.
//  Copyright (c) 2012 FOS Computer Services. All rights reserved.
//

@interface FOSRetrieveToOneRelationshipOperation : FOSOperation

@property (nonatomic, readonly) NSRelationshipDescription *relationship;
@property (nonatomic, readonly) id<NSObject>jsonFragment;
@property (nonatomic, readonly) NSError *error;

+ (instancetype)fetchToOneRelationship:(NSRelationshipDescription *)relDesc
                          jsonFragment:(id<NSObject>)jsonFragment
                          withBindings:(NSMutableDictionary *)bindings;

- (void)bindToOwner:(NSManagedObjectID *)ownerId;

@end
