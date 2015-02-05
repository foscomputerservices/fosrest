//
//  FOSLoginOperation.h
//  FOSFoundation
//
//  Created by David Hunt on 1/1/13.
//  Copyright (c) 2013 FOS Computer Services. All rights reserved.
//

#import <FOSFoundation/FOSOperation.h>
#import <FOSFoundation/FOSCachedManagedObject.h>

@class FOSUser;

@interface FOSLoginOperation : FOSOperation

#pragma mark - Properties
@property (nonatomic, readonly) FOSUser *user;
@property (nonatomic, readonly) NSString *loginStyle;
@property (nonatomic, readonly) FOSJsonId loggedInUid;
@property (nonatomic, readonly) NSManagedObjectID *loggedInMOID;

#pragma mark - Class methods
+ (instancetype)loginOperationForUser:(FOSUser *)user withLoginStyle:(NSString *)loginStyle;

@end
