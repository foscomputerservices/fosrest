//
//  FOSUser.m
//  FOSFoundation
//
//  Created by David Hunt on 12/23/12.
//  Copyright (c) 2012 FOS Computer Services. All rights reserved.
//

#import "FOSUser.h"
#import "FOSLoginManager_Internal.h"

@implementation FOSUser

@dynamic username;

@synthesize isLoginUser = _isLoginUser;
@synthesize password = _password;

#pragma mark - Class Methods

+ (instancetype)createLoginUser {

    NSManagedObjectContext *moc = [FOSLoginManager loginUserContext];
    FOSUser *result = [[self alloc] initWithEntity:[self entityDescription]
                    insertIntoManagedObjectContext:moc];
    result->_isLoginUser = YES;

    return result;
}

#pragma mark - Property Overrides

- (FOSJsonId)uid {
    return self.jsonIdValue;
}

@end
