//
//  FOSRetrieveToOneRelationshipOperation.h
//  FOSFoundation
//
//  Created by David Hunt on 12/31/12.
//  Copyright (c) 2012 FOS Computer Services. All rights reserved.
//

@import CoreData;
#import <FOSFoundation/FOSOperation.h>

@class NSRelationshipDescription;
@class FOSCMOBinding;

@interface FOSRetrieveToOneRelationshipOperation : FOSOperation

@property (nonatomic, readonly) NSRelationshipDescription *relationship;
@property (nonatomic, readonly) id<NSObject>jsonFragment;

+ (instancetype)fetchToOneRelationship:(NSRelationshipDescription *)relDesc
                          jsonFragment:(id<NSObject>)jsonFragment
                          withBindings:(NSMutableDictionary *)bindings
                   andParentCMOBinding:(FOSCMOBinding *)parentCMOBinding;

- (void)bindToOwner:(NSManagedObjectID *)ownerId;
- (NSError *)finishValidation;
- (void)finishCleanup:(BOOL)forceDestroy;

@end
