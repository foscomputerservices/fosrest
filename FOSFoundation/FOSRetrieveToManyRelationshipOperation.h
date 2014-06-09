//
//  FOSRetrieveToManyRelationshipOperation.h
//  FOSFoundation
//
//  Created by David Hunt on 12/31/12.
//  Copyright (c) 2012 FOS Computer Services. All rights reserved.
//

@interface FOSRetrieveToManyRelationshipOperation : FOSOperation

@property (nonatomic, readonly) NSRelationshipDescription *relationship;
@property (nonatomic, readonly) NSError *error;

+ (instancetype)fetchToManyRelationship:(NSRelationshipDescription *)relDesc
                              ownerJson:(id<NSObject>)ownerJson
                            ownerJsonId:(FOSJsonId)ownerJsonId
                               dslQuery:(NSString *)dslQuery
                           withBindings:(NSMutableDictionary *)bindings;

- (void)bindToOwner:(NSManagedObjectID *)ownerId;
- (void)finishOrdering;
- (void)finishValidation;
- (void)finishCleanup:(BOOL)forceDestroy;

@end
